





















OpenServerV3MainDlg = DlgMgr.DefineDialog("OpenServerV3MainDlg", "Operation/[UC]OpenServerV3/open_server_v3_main_dlg", DlgBase);

local OpenServerV3PanelView = require("Feature/Operation/OpenServerV3/OpenServerV3PanelView");
local OpenServerV3TabEntryView = require("Feature/Operation/OpenServerV3/OpenServerV3TabEntryView");
local OpenServerV3CheckInView = require("Feature/Operation/OpenServerV3/CheckIn/OpenServerV3CheckInView");
local OpenServerV3MissionView = require("Feature/Operation/OpenServerV3/Mission/OpenServerV3MissionView");
local OpenServerV3StageView = require("Feature/Operation/OpenServerV3/Stage/OpenServerV3StageView");
local OpenServerV3GiftPackageView = require("Feature/Operation/OpenServerV3/GiftPackage/OpenServerV3GiftPackageView");
local EventLogOpenServerContext = CS.Torappu.EventTrack.EventLogTrace.EventLogOpenServerContext;
local ItemRepoPage = CS.Torappu.UI.ItemRepo.ItemRepoPage;
local luaUtils = CS.Torappu.Lua.Util;

local DEFAULT_CAMPAIGN_STAGE_ID = CS.Torappu.UI.Campaign.CampaignConsts.DEFAULT_PERMANENT_STAGE_ID;

function OpenServerV3MainDlg:OnInit()
  self:AddButtonClickListener(self._btnClose, self._EventOnCloseClicked);
  self:AddButtonClickListener(self._btnClaim, self._EventOnClaimClicked);

  self.m_viewModel = self:CreateViewModel(OpenServerV3MainDlgViewModel);
  self.m_viewModel:LoadData();
  if self._pnlClaim ~= nil then
    SetGameObjectActive(self._pnlClaim, self.m_viewModel.showClaim);
  end
  self:_ActivateSelectedTab();

  if self._tabPanel ~= nil then
    self.m_panelView = self:CreateWidgetByGO(OpenServerV3PanelView, self._tabPanel);
  end
  self.m_tabEntryViews = self:_CreateTabEntryViews();
  self.m_contentViews = self:_CreateContentViews();
  if self.m_panelView ~= nil then
    self.m_panelView:SetTabEntryViews(self.m_tabEntryViews);
    self.m_panelView:SetContentViews(self.m_contentViews);
  end

  local isClickedStr = self:GetData(CS.Torappu.UI.Home.OpenServerV3Consts.OPEN_SERVER_V3_ENTER_CLICKED_KEY);
  if isClickedStr ~= nil then
    local isClicked = tonumber(isClickedStr) > 0;
    CS.Torappu.GameAnalytics.RecordOpenServerV3EntryClicked(isClicked, self.m_viewModel.tabState);
  end

  self.m_viewModel:NotifyUpdate();
  self:_UpdateAllTrackPoints();
end

function OpenServerV3MainDlg:OnResume()
  local model = self.m_viewModel;
  if model == nil then
    return;
  end
  model:RefreshPlayerData();
  model:NotifyUpdate();
  self:_UpdateAllTrackPoints();
end



function OpenServerV3MainDlg:_CreateTabEntryViews()
  local tabLayoutList = {
    { layout = self._tabCheckIn, tabState = OpenServerV3TabState.STATE_TAB_CHECK_IN },
    { layout = self._tabMission, tabState = OpenServerV3TabState.STATE_TAB_MISSION },
    { layout = self._tabStage, tabState = OpenServerV3TabState.STATE_TAB_STAGE },
    { layout = self._tabGiftPackage, tabState = OpenServerV3TabState.STATE_TAB_GIFT_PACKAGE },
  };
  local tabEntryViews = {};
  for _, tabConfig in ipairs(tabLayoutList) do
    if tabConfig.layout ~= nil then
      local entryView = self:CreateWidgetByGO(OpenServerV3TabEntryView, tabConfig.layout);
      entryView:Init(tabConfig.tabState, Event.Create(self, self._EventOnTabClicked));
      entryView:BindTrackPoint(self:_GetTabTrackPoint(tabConfig.tabState));
      table.insert(tabEntryViews, entryView);
    end
  end
  return tabEntryViews;
end




function OpenServerV3MainDlg:_GetTabTrackPoint(tabState)
  if tabState == OpenServerV3TabState.STATE_TAB_CHECK_IN then
    return OpenServerV3CheckInTrackPoint;
  end
  if tabState == OpenServerV3TabState.STATE_TAB_MISSION then
    return OpenServerV3MissionTabTrackPoint;
  end
  return nil;
end


function OpenServerV3MainDlg:_UpdateRootTrackPoint()
  TrackPointModel.me:UpdateNode(OpenServerV3TrackPoint);
end


function OpenServerV3MainDlg:_UpdateCheckInTrackPoints()
  self:_UpdateRootTrackPoint();
  TrackPointModel.me:UpdateNode(OpenServerV3CheckInTrackPoint);
end


function OpenServerV3MainDlg:_UpdateMissionTrackPoints()
  self:_UpdateRootTrackPoint();
  TrackPointModel.me:UpdateSubTree(OpenServerV3MissionTabTrackPoint);
end


function OpenServerV3MainDlg:_UpdateAllTrackPoints()
  self:_UpdateRootTrackPoint();
  TrackPointModel.me:UpdateNode(OpenServerV3CheckInTrackPoint);
  TrackPointModel.me:UpdateSubTree(OpenServerV3MissionTabTrackPoint);
end



function OpenServerV3MainDlg:_CreateContentViews()
  local contentViews = {};
  local checkInView = self:_TryCreateContentView(
      OpenServerV3CheckInView, self._prefabCheckIn, self._checkInContainer);
  if checkInView ~= nil then
    checkInView.onItemClicked = Event.Create(self, self._EventOnCheckInItemClicked);
    checkInView.onCharacterItemClicked = Event.Create(self, self._EventOnCheckInCharacterItemClicked);
    checkInView.onSpecialRewardClicked = Event.Create(self, self._EventOnCheckInSpecialRewardClicked);
    contentViews[OpenServerV3TabState.STATE_TAB_CHECK_IN] = checkInView;
  end

  local missionView = self:_TryCreateContentView(
      OpenServerV3MissionView, self._prefabMission, self._missionContainer);
  if missionView ~= nil then
    missionView.onPageTabClicked = Event.Create(self, self._EventOnMissionPageTabClicked);
    missionView.onStageClicked = Event.Create(self, self._EventOnMissionStageClicked);
    missionView.onTaskClicked = Event.Create(self, self._EventOnMissionTaskClicked);
    missionView.onTaskJumpClicked = Event.Create(self, self._EventOnMissionTaskJumpClicked);
    missionView.onClaimAllClicked = Event.Create(self, self._EventOnMissionClaimAllClicked);
    missionView.onMilestoneItemClicked = Event.Create(self, self._EventOnMilestoneItemClicked);
    missionView.onMilestoneClaimAllClicked = Event.Create(self, self._EventOnMilestoneClaimAllClicked);
    missionView.onMilestonePreviewCharClicked = Event.Create(self, self._EventOnCheckInCharacterItemClicked);
    contentViews[OpenServerV3TabState.STATE_TAB_MISSION] = missionView;
  end

  local stageView = self:_TryCreateContentView(
      OpenServerV3StageView, self._prefabStage, self._stageContainer);
  if stageView ~= nil then
    stageView.onStoryMainClicked = Event.Create(self, self._EventOnStageStoryMainClicked);
    stageView.onStoryExtraClicked = Event.Create(self, self._EventOnStageStoryExtraClicked);
    stageView.onCampaignMainClicked = Event.Create(self, self._EventOnStageCampaignMainClicked);
    stageView.onStageCampaignClicked = Event.Create(self, self._EventOnStageCampaignBtnClicked);
    stageView.onResourceClicked = Event.Create(self, self._EventOnStageResourceClicked);
    stageView.onPermModeClicked = Event.Create(self, self._EventOnStagePermModeClicked);
    contentViews[OpenServerV3TabState.STATE_TAB_STAGE] = stageView;
  end

  local giftPackageView = self:_TryCreateContentView(
      OpenServerV3GiftPackageView, self._prefabGiftPackage, self._giftPackageContainer);
  if giftPackageView ~= nil then
    giftPackageView.onGiftPackageClicked = Event.Create(self, self._EventOnGiftPackageClicked);
    contentViews[OpenServerV3TabState.STATE_TAB_GIFT_PACKAGE] = giftPackageView;
  end
  return contentViews;
end






function OpenServerV3MainDlg:_TryCreateContentView(viewCls, prefab, container)
  if prefab == nil or container == nil then
    return nil;
  end
  return self:CreateWidgetByPrefab(viewCls, prefab, container);
end



function OpenServerV3MainDlg:_EventOnTabClicked(tabState)
  if self.m_viewModel == nil then
    return;
  end
  if self.m_viewModel.tabState == tabState or
      CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  CS.Torappu.GameAnalytics.RecordOpenServerV3TabSwitch(tabState);
  self.m_viewModel:SetTabState(tabState);
  self:_ActivateSelectedTab();
  self.m_viewModel:RefreshPlayerData();
  self.m_viewModel:NotifyUpdate();
end


function OpenServerV3MainDlg:_EventOnCloseClicked()
  self:Close();
end


function OpenServerV3MainDlg:_EventOnClaimClicked()
  if self.m_viewModel == nil or not self.m_viewModel.showClaim then
    return;
  end
  local subSignal = self.m_viewModel.claimGuidebookSubSignal;
  if subSignal == nil or subSignal == "" then
    subSignal = self._guideSubSignal;
  end
  if subSignal == nil or subSignal == "" then
    return;
  end
  CS.Torappu.UI.UIGuideController.ConsumeGuideAutoShow(
      CS.Torappu.UIGuideTarget.OPEN_SERVER_V3, subSignal, true);
end



function OpenServerV3MainDlg:_EventOnCheckInItemClicked(index)
  if self.m_viewModel == nil then
    return;
  end
  if self.m_viewModel.tabState ~= OpenServerV3TabState.STATE_TAB_CHECK_IN or
      CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  local checkInModel = self.m_viewModel.checkinViewModel;
  if checkInModel == nil then
    return;
  end
  local itemModel = checkInModel.itemList[index + 1];
  if itemModel == nil or itemModel.state ~= OpenServerV3CheckInItemState.COMPLETE then
    return;
  end
  itemModel.state = OpenServerV3CheckInItemState.CONFIRMED;
  UISender.me:SendRequest(OpenServerV3ServiceCode.GET_CHECK_IN_REWARD, {
        index = index,
      },
      {
        onProceed = Event.Create(self, self._HandleGetCheckInRewardResponse),
      }
    );
end


function OpenServerV3MainDlg:_HandleGetCheckInRewardResponse(response)
  if response and response.items and #response.items > 0 then
    UIMiscHelper.ShowGainedItems(response.items);
  end
  self.m_viewModel:RefreshPlayerData();
  self.m_viewModel:NotifyUpdate();
  self:_UpdateCheckInTrackPoints();
end



function OpenServerV3MainDlg:_EventOnMissionPageTabClicked(pageState)
  if self.m_viewModel == nil or self.m_viewModel.missionViewModel == nil then
    return;
  end
  local missionViewModel = self.m_viewModel.missionViewModel;
  local changed = missionViewModel:SetPageState(pageState);
  if not changed then
    return;
  end
  self:_ConsumeSelectedMissionPageNewTip();
  self.m_viewModel:RefreshPlayerData();
  if pageState == OpenServerV3MissionPageState.TASK then
    missionViewModel:SelectRecommendedStage();
  end
  self.m_viewModel:NotifyUpdate();
end


function OpenServerV3MainDlg:_ActivateMissionTab()
  if self.m_viewModel == nil or self.m_viewModel.tabState ~= OpenServerV3TabState.STATE_TAB_MISSION or
      self.m_viewModel.missionViewModel == nil then
    return;
  end
  local missionViewModel = self.m_viewModel.missionViewModel;
  missionViewModel:FocusPageByRewardTrackPoint();
  if missionViewModel.pageState == OpenServerV3MissionPageState.MILESTONE and self.m_contentViews ~= nil then
    local missionView = self.m_contentViews[OpenServerV3TabState.STATE_TAB_MISSION];
    if missionView ~= nil then
      missionView:ResetMilestoneFocus();
    end
  end
  self:_ConsumeSelectedMissionPageNewTip();
  self.m_viewModel:RefreshPlayerData();
  missionViewModel:SelectRecommendedStage();
end


function OpenServerV3MainDlg:_ActivateSelectedTab()
  if self.m_viewModel == nil then
    return;
  end
  local tabState = self.m_viewModel.tabState;
  if tabState == OpenServerV3TabState.STATE_TAB_CHECK_IN then
    self:_ActivateCheckInTab();
  elseif tabState == OpenServerV3TabState.STATE_TAB_MISSION then
    self:_ActivateMissionTab();
  elseif tabState == OpenServerV3TabState.STATE_TAB_GIFT_PACKAGE then
    self:_ActivateGiftPackageTab();
  elseif tabState == OpenServerV3TabState.STATE_TAB_STAGE then
    self:_ActivateStageTab();
  end
end


function OpenServerV3MainDlg:_ActivateCheckInTab()
  if self.m_viewModel == nil or
      self.m_viewModel.tabState ~= OpenServerV3TabState.STATE_TAB_CHECK_IN or
      self.m_viewModel.checkinViewModel == nil then
    return;
  end
  self.m_viewModel.checkinViewModel.sequenceNum = self.m_viewModel.checkinViewModel.sequenceNum + 1;
end


function OpenServerV3MainDlg:_ActivateGiftPackageTab()
  if self.m_viewModel == nil or
      self.m_viewModel.tabState ~= OpenServerV3TabState.STATE_TAB_GIFT_PACKAGE then
    return;
  end
  if OpenServerV3Model.me:CheckIfHasGiftPackageNewTip() then
    OpenServerV3Model.me:ConsumeGiftPackageNewTip();
    self.m_viewModel:RefreshPlayerData();
  end
end


function OpenServerV3MainDlg:_ActivateStageTab()
  if self.m_viewModel == nil or self.m_viewModel.tabState ~= OpenServerV3TabState.STATE_TAB_STAGE then
    return;
  end
  if OpenServerV3Model.me:CheckIfHasStageNewTip() then
    OpenServerV3Model.me:ConsumeStageNewTip();
    self.m_viewModel:RefreshPlayerData();
  end
end



function OpenServerV3MainDlg:_ConsumeSelectedMissionPageNewTip()
  if self.m_viewModel == nil or self.m_viewModel.tabState ~= OpenServerV3TabState.STATE_TAB_MISSION or
      self.m_viewModel.missionViewModel == nil then
    return false;
  end
  local pageState = self.m_viewModel.missionViewModel.pageState;
  if pageState == OpenServerV3MissionPageState.TASK and OpenServerV3Model.me:CheckIfHasMissionNewTip() then
    OpenServerV3Model.me:ConsumeMissionNewTip();
    return true;
  elseif pageState == OpenServerV3MissionPageState.MILESTONE and OpenServerV3Model.me:CheckIfHasMilestoneNewTip() then
    OpenServerV3Model.me:ConsumeMilestoneNewTip();
    return true;
  end
  return false;
end



function OpenServerV3MainDlg:_EventOnMissionStageClicked(stageIndex)
  if self.m_viewModel == nil or self.m_viewModel.missionViewModel == nil then
    return;
  end
  local changed, stageModel = self.m_viewModel.missionViewModel:SetSelectedStageIndex(stageIndex);
  if stageModel ~= nil and stageModel.locked then
    luaUtils.TextToast(I18NTextRes.COMMON_OPEN_SERVER_V3_MISSION_LOCK_TOAST);
    return;
  end
  if not changed then
    return;
  end
  self.m_viewModel:NotifyUpdate();
end



function OpenServerV3MainDlg:_EventOnMissionTaskClicked(missionId)
  if self.m_viewModel == nil or self.m_viewModel.tabState ~= OpenServerV3TabState.STATE_TAB_MISSION or
      CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  if not OpenServerV3Model.me:CheckIfMissionCanClaim(missionId) then
    return;
  end
  UISender.me:SendRequest(CS.Torappu.Network.ServiceCode.MISSION_CONFIRMMISSION,
      {
        missionId = missionId,
      },
      {
        onProceed = Event.Create(self, self._HandleGetMissionRewardResponse),
      }
    );
end


function OpenServerV3MainDlg:_EventOnMissionClaimAllClicked()
  if self.m_viewModel == nil or self.m_viewModel.tabState ~= OpenServerV3TabState.STATE_TAB_MISSION or
      self.m_viewModel.missionViewModel == nil or
      CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  local missionModel = self.m_viewModel.missionViewModel;
  if missionModel.selectedStage == nil or not missionModel.hasRewardCanClaim then
    return;
  end
  local missionIds = missionModel:GetClaimableMissionIdsInSelectedStage();
  if missionIds == nil or #missionIds <= 0 then
    return;
  end
  UISender.me:SendRequest(CS.Torappu.Network.ServiceCode.MISSION_CONFIRMMISSION_LIST,
      {
        missionIds = missionIds,
      },
      {
        onProceed = Event.Create(self, self._HandleGetMissionRewardResponse),
      }
    );
end



function OpenServerV3MainDlg:_HandleGetMissionRewardResponse(response)
  if response ~= nil and response.items ~= nil and #response.items > 0 then
    UIMiscHelper.ShowGainedItems(response.items);
  end
  self:_RefreshMissionAfterReward();
end



function OpenServerV3MainDlg:_EventOnMilestoneItemClicked(level)
  if self.m_viewModel == nil or self.m_viewModel.tabState ~= OpenServerV3TabState.STATE_TAB_MISSION or
      CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  if not OpenServerV3Model.me:CheckIfMilestoneCanClaim(level) then
    return;
  end
  self:_SendGetMilestoneRewardRequest({
    levels = {
      level,
    },
  });
end


function OpenServerV3MainDlg:_EventOnMilestoneClaimAllClicked()
  if self.m_viewModel == nil or self.m_viewModel.tabState ~= OpenServerV3TabState.STATE_TAB_MISSION or
      self.m_viewModel.missionViewModel == nil or
      CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  local levels = self.m_viewModel.missionViewModel:GetClaimableMilestoneLevels();
  if levels == nil or #levels <= 0 then
    return;
  end
  self:_SendGetMilestoneRewardRequest({
    levels = levels,
  });
end



function OpenServerV3MainDlg:_SendGetMilestoneRewardRequest(payload)
  UISender.me:SendRequest(OpenServerV3ServiceCode.GET_MILESTONE_REWARD,
      payload,
      {
        onProceed = Event.Create(self, self._HandleGetMilestoneRewardResponse),
      }
    );
end



function OpenServerV3MainDlg:_HandleGetMilestoneRewardResponse(response)
  if response ~= nil and response.items ~= nil and #response.items > 0 then
    UIMiscHelper.ShowGainedItems(response.items);
  end
  self:_RefreshMissionAfterReward();
end


function OpenServerV3MainDlg:_RefreshMissionAfterReward()
  if self.m_viewModel == nil then
    return;
  end
  self.m_viewModel:RefreshPlayerData();
  self.m_viewModel:NotifyUpdate();
  self:_UpdateMissionTrackPoints();
end



function OpenServerV3MainDlg:_EventOnMissionTaskJumpClicked(missionId)
  if self.m_viewModel == nil or self.m_viewModel.tabState ~= OpenServerV3TabState.STATE_TAB_MISSION then
    return;
  end
  self:_JumpToMissionTarget(missionId);
end



function OpenServerV3MainDlg:_JumpToMissionTarget(missionId)
  local missionModel = self:_FindMissionTaskModel(missionId);
  if missionModel == nil or missionModel.jumpType == nil or missionModel.jumpType == OperationJumpType.NONE then
    return;
  end
  OperationJumpUtil.JumpToTarget(missionModel.jumpType, missionModel.jumpPlace);
end




function OpenServerV3MainDlg:_FindMissionTaskModel(missionId)
  if self.m_viewModel == nil or self.m_viewModel.missionViewModel == nil or missionId == nil then
    return nil;
  end
  local missionModel = self.m_viewModel.missionViewModel;
  for _, stageModel in ipairs(missionModel.stageList) do
    for _, taskModel in ipairs(stageModel.missionList) do
      if taskModel.missionId == missionId then
        return taskModel;
      end
    end
  end
  return nil;
end



function OpenServerV3MainDlg:_EventOnCheckInCharacterItemClicked(charId)
  if charId == nil or charId == "" then
    return;
  end
  if CS.Torappu.UI.UIPageController.isTransiting then
    return;
  end
  local charShowViewModel = CS.Torappu.UI.CharacterShowViewModel.CreateFullCultiChar(charId);
  local option = CS.Torappu.UI.UIPageOption();
  local param = CS.Torappu.UI.CharacterShow.CharacterShowPage.Params();
  param.viewModel = charShowViewModel;
  option.args = param;
  self:OpenPage3(CS.Torappu.UI.UIPageNames.CHAR_SHOW, option);
end



function OpenServerV3MainDlg:_EventOnCheckInSpecialRewardClicked(rewardObj)
  local model = self.m_viewModel;
  if model == nil then
    return;
  end
  local viewModel = model.checkinViewModel;
  if viewModel == nil or viewModel.specialReward == nil then
    return;
  end
  local reward = viewModel.specialReward;
  local itemId = reward.itemId;
  if viewModel.specialRewardState == OpenServerV3CheckInSpecialRewardState.OWNED then
    CS.Torappu.GameAnalytics.RecordOpenServerV3ItemJump(itemId);
    local routeParam = ItemRepoPage.RouteParam.CreateDefaultRouteRule(itemId, ItemRepoPage.RoutePageRule.SINGLE_ITEM_PREVIEW);
    CS.Torappu.UI.UIRouteUtil.RouteToItemRepo(routeParam);
  else
    CS.Torappu.UI.UIItemDescFloatController.ShowItemDesc(rewardObj, reward);
  end
end


function OpenServerV3MainDlg:_EventOnStageStoryMainClicked()
  CS.Torappu.GameAnalytics.RecordOpenServerV3StageTabClick(
      EventLogOpenServerContext.OpenServerV3StageClickType.MODULE_JUMP,
      EventLogOpenServerContext.OpenServerV3StageTabType.MIX_STORY,
      true);
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  CS.Torappu.UI.UIRouteUtil.RouteToMixStory(true);
end


function OpenServerV3MainDlg:_EventOnStageStoryExtraClicked()
  CS.Torappu.GameAnalytics.RecordOpenServerV3StageTabClick(
      EventLogOpenServerContext.OpenServerV3StageClickType.MODULE_DETAIL,
      EventLogOpenServerContext.OpenServerV3StageTabType.MIX_STORY,
      true);
  self:GetGroup():AddChildDlg(OpenServerV3StageStoryDlg);
end


function OpenServerV3MainDlg:_EventOnStageCampaignMainClicked()
  local model = self.m_viewModel;
  if model == nil or model.stageViewModel == nil then
    return;
  end
  CS.Torappu.GameAnalytics.RecordOpenServerV3StageTabClick(
      EventLogOpenServerContext.OpenServerV3StageClickType.MODULE_JUMP,
      EventLogOpenServerContext.OpenServerV3StageTabType.CAMPAIGN,
      model.stageViewModel.isCampaignUnlock);
  local stageId = DEFAULT_CAMPAIGN_STAGE_ID;
  local playerData = CS.Torappu.PlayerData.instance.data;
  local playerCampaign = playerData ~= nil and playerData.campaign or nil;
  local rotateStageId = playerCampaign ~= nil and playerCampaign.open ~= nil and
      playerCampaign.open.rotate or nil;
  if rotateStageId ~= nil and rotateStageId ~= "" and
      CS.Torappu.CampaignDataUtil.IsStageUnlocked(rotateStageId) and
      not CS.Torappu.CampaignDataUtil.IsStageClosed(rotateStageId) then
    stageId = rotateStageId;
  end
  OperationJumpUtil.JumpToTarget(OperationJumpType.CAMPAIGN_STAGE, stageId);
end


function OpenServerV3MainDlg:_EventOnStageCampaignBtnClicked()
  local model = self.m_viewModel;
  if model == nil or model.stageViewModel == nil then
    return;
  end
  CS.Torappu.GameAnalytics.RecordOpenServerV3StageTabClick(
      EventLogOpenServerContext.OpenServerV3StageClickType.MODULE_DETAIL,
      EventLogOpenServerContext.OpenServerV3StageTabType.CAMPAIGN,
      model.stageViewModel.isCampaignUnlock);
  if not model.stageViewModel.isCampaignUnlock then
    return;
  end
  self:GetGroup():AddChildDlg(OpenServerV3StageCampaignDlg);
end




function OpenServerV3MainDlg:_EventOnGiftPackageClicked(goodId, imgId)
  if goodId == nil or goodId == "" or imgId == nil or imgId == "" then
    return;
  end
  CS.Torappu.GameAnalytics.RecordShopTitleClicked(CS.Torappu.ShopType.GIFTPACKAGE, CS.Torappu.UI.Shop.ShopPage.Referrer.OPENSERVER, imgId);
  CS.Torappu.GameAnalytics.RecordShopTabClicked("");
  CS.Torappu.GameAnalytics.RecordShopItemClicked(goodId);
  local param = CS.Torappu.UI.Shop.ShopPage.Params();
  param.targetShop = CS.Torappu.ShopRouteTarget.GIFTPACKAGE;
  param.targetGoodId = goodId;
  CS.Torappu.UI.UIRouteUtil.RouteToShopAndResetStack(param);
end


function OpenServerV3MainDlg:_EventOnStageResourceClicked()
  local model = self.m_viewModel;
  if model == nil or model.stageViewModel == nil then
    return;
  end
  CS.Torappu.GameAnalytics.RecordOpenServerV3StageTabClick(
      EventLogOpenServerContext.OpenServerV3StageClickType.MODULE_JUMP,
      EventLogOpenServerContext.OpenServerV3StageTabType.WEEKLY,
      model.stageViewModel.isResourceUnlock);
  OperationJumpUtil.JumpToTarget(OperationJumpType.WEEKLY);
end


function OpenServerV3MainDlg:_EventOnStagePermModeClicked()
  local model = self.m_viewModel;
  if model == nil or model.stageViewModel == nil then
    return;
  end
  CS.Torappu.GameAnalytics.RecordOpenServerV3StageTabClick(
      EventLogOpenServerContext.OpenServerV3StageClickType.MODULE_JUMP,
      EventLogOpenServerContext.OpenServerV3StageTabType.PERM_MODE,
      model.stageViewModel.isPermModeUnlock);
  OperationJumpUtil.JumpToTarget(OperationJumpType.PERM_MODE);
end