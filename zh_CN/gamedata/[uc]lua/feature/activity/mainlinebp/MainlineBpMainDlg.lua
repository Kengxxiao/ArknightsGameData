local luaUtils = CS.Torappu.Lua.Util;














MainlineBpMainDlg = Class("MainlineBgMainDlg", DlgBase);

local MainlineBpViewModel = require("Feature/Activity/MainlineBp/MainlineBpViewModel");
local MainlineBpMissionView = require("Feature/Activity/MainlineBp/MainlineBpMissionView");
local MainlineBpBpView = require("Feature/Activity/MainlineBp/MainlineBpBpView");
local MainlineBpMainView = require("Feature/Activity/MainlineBp/MainlineBpMainView");
local MainlineBpBpUpDetailView = require("Feature/Activity/MainlineBp/MainlineBpBpUpDetailView");

function MainlineBpMainDlg:OnInit()
  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnClose);
  self:AddButtonClickListener(self._btnClose, self._EventOnCloseClick);

  local actId = self.m_parent:GetData("actId");
  self.m_viewModel = self:CreateViewModel(MainlineBpViewModel);
  self.m_viewModel.missionFocusCache = 0;
  self.m_viewModel:LoadData(actId);

  local bpDynImageFunc = function(actId, imgId)
    if actId == nil or actId == "" or imgId == nil or imgId == "" then
      return nil;
    end
    local hubPath = CS.Torappu.ResourceUrls.GetMainlineBpDynImageHubPath(actId);
    return self:LoadSpriteFromAutoPackHub(hubPath, imgId);
  end;
  local missionView = self:CreateWidgetByPrefab(MainlineBpMissionView, self._prefabMission, self._containerMission);
  missionView.loadDynImage = bpDynImageFunc;
  missionView.onConfirmAllMissionClicked = Event.Create(self, self._OnConfirmAllMissionClicked);
  missionView.onMissionClicked = Event.Create(self, self._OnMissionClicked);
  missionView.onJumpToZoneClicked = Event.Create(self, self._OnJumpToZoneClicked);
  missionView:InitEventFunc();

  local bpView = self:CreateWidgetByPrefab(MainlineBpBpView, self._prefabBp, self._containerBp);
  bpView.loadDynImage = bpDynImageFunc;
  bpView.onLimitRewardClaimClicked = Event.Create(self, self._OnBpLimitBpRewardItemClicked);
  bpView.onAllBpRewardClaimClicked = Event.Create(self, self._OnBpAllRewardBtnClicked);
  bpView.onUnlimitRewardClaimClicked = Event.Create(self, self._OnBpUnlimitBpRewardClicked);
  bpView.onBpUnlimitDetailClick = Event.Create(self, self._OnBpUnlimitDetailClick);
  bpView.onBpUnlimitDetailCloseClick = Event.Create(self, self._OnFloatPanelCloseBtnClick);
  bpView.onBigRewardPreviewBtnClick = Event.Create(self, self._OnBigRewardPreviewBtnClick);
  bpView:InitEventFunc();

  local mainView = self:CreateWidgetByPrefab(MainlineBpMainView, self._prefabMain, self._containerMain);
  mainView.onMissionTabClick = Event.Create(self, self._OnMissionTabBtnClick);
  mainView.onBpTabClick = Event.Create(self, self._OnBpTabBtnClick);
  mainView.onStageJumpBtnClick = Event.Create(self, self._OnCurrStageJumpBtnClick);
  mainView.onBpUpDetailClick = Event.Create(self, self._OnBpUpDetailClick);

  local bpUpView = self:CreateWidgetByPrefab(MainlineBpBpUpDetailView, self._prefabBpUp, self._containerBpUp);
  bpUpView.onCloseBtnClick = Event.Create(self, self._OnFloatPanelCloseBtnClick);

  MainlineBpUtil.SetPeriodChecked(actId, self.m_viewModel.currPeriodId);
  self.m_viewModel:NotifyUpdate();
end


function MainlineBpMainDlg:_EventOnCloseClick()
  self:Close()
end


function MainlineBpMainDlg:_OnMissionTabBtnClick()
  self:_SwitchTab(MainlineBpTabState.MISSION);
end


function MainlineBpMainDlg:_OnBpTabBtnClick()
  self:_SwitchTab(MainlineBpTabState.BP);
end


function MainlineBpMainDlg:_OnFloatPanelCloseBtnClick()
  self:_CloseFloatTab();
end


function MainlineBpMainDlg:_OnBigRewardPreviewBtnClick()
  local model = self.m_viewModel;
  if model == nil then
    return;
  end
  local bigRewardThemeId = model:GetLimitBpBigRewardAccordingUiId();
  if bigRewardThemeId == nil or bigRewardThemeId == "" then
    return;
  end
  CS.Torappu.UI.UIRouteUtil.RouteToHomeThemeState(bigRewardThemeId);
end


function MainlineBpMainDlg:_OnBpUpDetailClick()
  local model = self.m_viewModel;
  if model == nil then
    return;
  end
  self:_CloseFloatTab();
  model.showBpUpDetailPanel = true;
  model:NotifyUpdate();
end


function MainlineBpMainDlg:_OnBpUnlimitDetailClick()
  local model = self.m_viewModel;
  if model == nil then
    return;
  end
  self:_CloseFloatTab();
  model.showBpUnlimitDetailPanel = true;
  model:NotifyUpdate();
end



function MainlineBpMainDlg:_SwitchTab(tabState)
  local model = self.m_viewModel;
  if model == nil then
    return;
  end
  self:_CloseFloatTab()
  if model.tabState == tabState then
    return;
  end
  model.tabState = tabState;
  model:NotifyUpdate();
end


function MainlineBpMainDlg:_CloseFloatTab()
  local model = self.m_viewModel;
  if model == nil then
    return;
  end
  model.showBpUpDetailPanel = false;
  model.showBpUnlimitDetailPanel = false;
  model:NotifyUpdate();
end


function MainlineBpMainDlg:_OnCurrStageJumpBtnClick()
  local viewModel = self.m_viewModel;
  local stageId = viewModel.currStageId;
  local zoneId = viewModel.currStageZoneId;
  if stageId == nil or 
      stageId == "" or 
      zoneId == nil or 
      zoneId == "" or 
      viewModel == nil or 
      viewModel.mainlineViewModel == nil then
    return;
  end

  local zoneModel = viewModel.mainlineViewModel:FindZone(zoneId);
  if zoneModel == nil or not zoneModel.isUnlock or CS.Torappu.StageDataUtil.TryTriggerRecapAvg(zoneId) then
    return;
  end

  local option = CS.Torappu.UI.UIPageOption();
  option.savedInst = CS.Torappu.UI.Stage.StagePage.DataBundleToStage(zoneId, stageId);
  CS.Torappu.UI.UIPageController.OpenPage(CS.Torappu.UI.UIPageNames.STAGE, option);
end



function MainlineBpMainDlg:_OnMissionClicked(missionId)
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  if missionId == nil or missionId == "" then
    return;
  end
  local viewModel = self.m_viewModel;
  if viewModel == nil then
    return;
  end
  local missionModel = nil;
  for i = 1, #viewModel.missionGroupModelList do
    local model = viewModel.missionGroupModelList[i];
    if model.itemType == MainlineBpMissionItemType.MISSION and model.missionId == missionId then
      missionModel = model;
      break;
    end
  end
  if missionModel == nil then
    return;
  end
  if missionModel.missionState ~= MainlineBpMissionState.COMPLETE or
      missionModel.progressCurr < missionModel.progressTarget then
    return;
  end

  UISender.me:SendRequest(MainlineBpServiceCode.CONFIRM_MISSION,
  {
    activityId = viewModel.actId,
    missionId = missionId,
  },
  {
    onProceed = Event.Create(self, self._CreditClaimGetResponse),
    abortIfBusy = true
  });
end


function MainlineBpMainDlg:_OnConfirmAllMissionClicked()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  local viewModel = self.m_viewModel;
  if viewModel == nil then
    return;
  end
  local missionIdList = {};
  for i = 1, #viewModel.missionGroupModelList do
    local model = viewModel.missionGroupModelList[i];
    if model.itemType == MainlineBpMissionItemType.MISSION and 
        model.missionState == MainlineBpMissionState.COMPLETE then
      table.insert(missionIdList, model.missionId);
    end
  end
  if #missionIdList <= 0 then
    return;
  end

  UISender.me:SendRequest(MainlineBpServiceCode.CONFIRM_ALL_MISSION,
  {
    activityId = viewModel.actId,
    missionIds = missionIdList,
  },
  {
    onProceed = Event.Create(self, self._CreditClaimGetResponse),
    abortIfBusy = true
  });
end



function MainlineBpMainDlg:_OnBpLimitBpRewardItemClicked(milestoneId)
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  if milestoneId == nil or milestoneId == "" then
    return;
  end
  local viewModel = self.m_viewModel;
  if viewModel == nil then
    return;
  end

  UISender.me:SendRequest(MainlineBpServiceCode.CONFIRM_BP_LIMIT_REWARD,
  {
    activityId = viewModel.actId,
    milestoneId = milestoneId,
  },
  {
    onProceed = Event.Create(self, self._ConfirmBpRewardResponse),
    abortIfBusy = true
  });
end



function MainlineBpMainDlg:_OnBpAllRewardBtnClicked(unlimitBpRound)
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  local viewModel = self.m_viewModel;
  if viewModel == nil then
    return;
  end

  UISender.me:SendRequest(MainlineBpServiceCode.CONFIRM_BP_ALL_REWAED,
  {
    activityId = viewModel.actId,
    infMilestoneCnt = unlimitBpRound,
  },
  {
    onProceed = Event.Create(self, self._ConfirmBpRewardResponse),
    abortIfBusy = true
  });
end



function MainlineBpMainDlg:_OnBpUnlimitBpRewardClicked(unlimitBpRound)
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  local viewModel = self.m_viewModel;
  if viewModel == nil then
    return;
  end

  UISender.me:SendRequest(MainlineBpServiceCode.CONFIRM_BP_UNLIMIT_REWAED,
  {
    activityId = viewModel.actId,
    infMilestoneCnt = unlimitBpRound,
  },
  {
    onProceed = Event.Create(self, self._ConfirmBpRewardResponse),
    abortIfBusy = true
  });
end



function MainlineBpMainDlg:_OnJumpToZoneClicked(zoneId)
  local viewModel = self.m_viewModel;
  if zoneId == nil or zoneId == "" or viewModel == nil or viewModel.mainlineViewModel == nil then
    return;
  end

  local zoneModel = viewModel.mainlineViewModel:FindZone(zoneId);
  if zoneModel == nil then
    return;
  end

  local jumpToZoneMap = true;
  if zoneModel.isUnlock then
    jumpToZoneMap = true;
  
  else
    local zoneModel = viewModel.mainlineViewModel:FindLastUnlockZone();
    if zoneModel == nil then
      return;
    end
    zoneId = zoneModel.id;
    jumpToZoneMap = false;
  end

  
  if jumpToZoneMap and CS.Torappu.StageDataUtil.TryTriggerRecapAvg(zoneId) then
    return;
  end

  local option = CS.Torappu.UI.UIPageOption();
  if not jumpToZoneMap then
    option.savedInst = CS.Torappu.UI.Stage.StagePage.DataBundleToZoneOnZoneSelect(zoneId);
  else
    option.savedInst = CS.Torappu.UI.Stage.StagePage.DataBundleToStage(zoneId);
  end
  CS.Torappu.UI.UIPageController.OpenPage(CS.Torappu.UI.UIPageNames.STAGE, option);
end



function MainlineBpMainDlg:_CreditClaimGetResponse(response)
  if response.items ~= nil and #response.items > 0 then
    UIMiscHelper.ShowGainedItems(response.items)
  end

  self:_RefreshPlayerData();
  
  local model = self.m_viewModel;
  if model ~= nil then
    model:SetMissionAutoFocus();
  end
end


function MainlineBpMainDlg:_RefreshPlayerData()
  local model = self.m_viewModel;
  if model == nil then
    return;
  end
  model:RefreshPlayerData();
  model:NotifyUpdate();
end



function MainlineBpMainDlg:_ConfirmBpRewardResponse(response)
  if response.reward ~= nil and #response.reward > 0 then
    UIMiscHelper.ShowGainedItems(response.reward);
  end
  self:_RefreshPlayerData();
end