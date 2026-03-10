local luaUtils = CS.Torappu.Lua.Util;
local ReturnAllOpenType = CS.Torappu.ReturnAllOpenType;
local BackflowSpecialOpenType = CS.Torappu.EventTrack.EventLogTrace.EventLogBackflowTraceContext.BackflowSpecialOpenType;































ReturnMainDlg = DlgMgr.DefineDialog("ReturnMainDlg", "Operation/[UC]Returning/return_main_dlg", DlgBase);

local ReturnPanelView = require("Feature/Operation/Returning/ReturnPanelView");
local ReturnCheckinView = require("Feature/Operation/Returning/Checkin/ReturnCheckinView");
local ReturnMissionView = require("Feature/Operation/Returning/Mission/ReturnMissionView");
local ReturnNewsView = require("Feature/Operation/Returning/News/ReturnNewsView");
local ReturnSpecialOpenView = require("Feature/Operation/Returning/SpecialOpen/ReturnSpecialOpenView");
local ReturnPackageView = require("Feature/Operation/Returning/Package/ReturnPackageView")

function ReturnMainDlg:OnInit()
  self:AddButtonClickListener(self._btnBackPress, self._EventOnCloseClicked);
  self:AddButtonClickListener(self._btnClose, self._EventOnCloseClicked);
  self:AddButtonClickListener(self._btnCheckin, self._EventOnCheckinTabClicked);
  self:AddButtonClickListener(self._btnMission, self._EventOnMissionTabClicked);
  self:AddButtonClickListener(self._btnNews, self._EventOnNewsTabClicked);
  self:AddButtonClickListener(self._btnSpecialOpen, self._EventOnSpecialOpenTabClicked);
  self:AddButtonClickListener(self._btnPackage, self._EventOnPackageTabClicked);
  self:AddButtonClickListener(self._btnWelcome, self._EventOnWelcomeTabClicked);
  self:AddButtonClickListener(self._btnNotice, self._EventOnNoticeClicked);

  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnBackPress);
  
  self.m_viewModel = self:CreateViewModel(ReturnMainDlgViewModel);
  self.m_viewModel:LoadData();

  self:CreateWidgetByGO(ReturnPanelView, self._tabPanel);
  local missionView = self:CreateWidgetByPrefab(ReturnMissionView, self._prefabMission, self._missionContainer);
  missionView.eventOnMissionClicked = Event.Create(self, self._EventOnMissionGroupClicked);
  missionView.eventOnClaimAllClicked = Event.Create(self, self._EventOnMissionClaimAllClicked);
  missionView.eventOnPointDetailClicked = Event.Create(self, self._EventOnMissionPointDetailClicked);
  missionView.eventOnPointRewardClicked = Event.Create(self, self._EventOnMissionPointRewardClicked);
  local checkinView = self:CreateWidgetByPrefab(ReturnCheckinView, self._prefabCheckin, self._checkinContainer);
  checkinView.onItemClick = Event.Create(self, self._EventOnSignInItemClicked);
  local newsView = self:CreateWidgetByPrefab(ReturnNewsView, self._prefabNews, self._newsContainer);
  newsView.eventOnClicked = Event.Create(self, self._EventOnNewsItemClicked);
  local specialOpenView = self:CreateWidgetByPrefab(ReturnSpecialOpenView, self._prefabSpecialOpen, self._specialOpenContainer);
  specialOpenView.loadFunc = function(hubPath, spriteName)
    return self:LoadSpriteFromAutoPackHub(hubPath, spriteName);
  end;
  specialOpenView.onEntryClick = Event.Create(self, self._EventOnSpecialOpenEntryClicked);
  specialOpenView.onGotoClick = Event.Create(self, self._EventOnSpecialOpenGotoClicked);
  local packageView = self:CreateWidgetByPrefab(ReturnPackageView, self._prefabPackage, self._packageContainer);

  TrackPointModel.me:BindUI(ReturnCheckInTrackPoint, self._trackPointCheckIn);
  TrackPointModel.me:BindUI(ReturnMissionTrackPoint, self._trackPointMission);
  TrackPointModel.me:BindUI(ReturnNewsTrackPoint, self._trackPointNews);
  TrackPointModel.me:BindUI(ReturnSpecialOpenTrackPoint, self._trackPointSpecialOpen);
  TrackPointModel.me:BindUI(ReturnPackageTrackPoint, self._trackPointPackage);

  self.m_viewModel:NotifyUpdate();
end

function ReturnMainDlg:OnClose()
  TrackPointModel.me:UnbindUI(ReturnCheckInTrackPoint);
  TrackPointModel.me:UnbindUI(ReturnMissionTrackPoint);
  TrackPointModel.me:UnbindUI(ReturnNewsTrackPoint);
  TrackPointModel.me:UnbindUI(ReturnSpecialOpenTrackPoint);
  TrackPointModel.me:UnbindUI(ReturnPackageTrackPoint);
end



function ReturnMainDlg:_EventOnMissionGroupClicked(index)
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  if self.m_viewModel == nil or self.m_viewModel.missionViewModel == nil or
      self.m_viewModel.tabState ~= ReturnTabState.STATE_TAB_MISSION then
    return;
  end
  local missionModel = self.m_viewModel.missionViewModel;
  if missionModel.missionOnlyList == nil then
    return;
  end
  local missionGroupModel = missionModel.missionOnlyList[index];
  if missionGroupModel == nil or missionGroupModel.groupType ~= ReturnMissionGroupType.MISSION then
    return;
  end
  if missionGroupModel.state == ReturnMissionGroupState.HAS_REWARD then
    UISender.me:SendRequest(ReturnServiceCode.GET_MISSION_REWARD,
        {
          groupId = missionGroupModel.groupId,
        },
        {
          onProceed = Event.Create(self, self._HandleGetMissionRewardResponse),
        }
      );
  elseif missionGroupModel.isMultiMission then
    local missionList = self:GetGroup():AddChildDlg(ReturnMissionListDlg);
    if missionList ~= nil then
      missionList:Render(missionGroupModel);
    end
  end
end


function ReturnMainDlg:_EventOnMissionClaimAllClicked()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  if self.m_viewModel == nil or self.m_viewModel.missionViewModel == nil or
      self.m_viewModel.tabState ~= ReturnTabState.STATE_TAB_MISSION then
    return;
  end
  local missionModel = self.m_viewModel.missionViewModel;
  if missionModel.hasRewardCanClaim then
    UISender.me:SendRequest(ReturnServiceCode.AUTO_GET_REWARD,
        {
        },
        {
          onProceed = Event.Create(self, self._HandleGetMissionRewardResponse),
        }
      );
  end
end


function ReturnMainDlg:_HandleGetMissionRewardResponse(response)
  local this = self;
  local handler = CS.Torappu.UI.LuaUIMisc.ShowGainedItems(response.items, CS.Torappu.UI.UIGainItemFloatPanel.Style.DEFAULT, function()
    if this.m_viewModel == nil then
      return;
    end
    this.m_viewModel:RefreshPlayerData();
    TrackPointModel.me:UpdateNode(ReturnMissionTrackPoint);
    this.m_viewModel:NotifyUpdate();
  end);
  self:_AddDisposableObj(handler);
end


function ReturnMainDlg:_EventOnMissionPointDetailClicked()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  if self.m_viewModel == nil or self.m_viewModel.missionViewModel == nil or
      self.m_viewModel.tabState ~= ReturnTabState.STATE_TAB_MISSION then
    return;
  end
  local missionModel = self.m_viewModel.missionViewModel;
  if missionModel.hasPointRewardCanClaim then
    UISender.me:SendRequest(ReturnServiceCode.GET_POINT_REWARD,
        {
        },
        {
          onProceed = Event.Create(self, self._HandleGetMissionRewardResponse),
        }
      );
  else
    local detailDlg = self:GetGroup():AddChildDlg(ReturnPointDetailDlg);
    if detailDlg ~= nil then
      detailDlg:Render(missionModel);
    end
  end
end


function ReturnMainDlg:_EventOnMissionPointRewardClicked()
  self:_EventOnMissionPointDetailClicked();
end


function ReturnMainDlg:_EventOnCloseClicked()
  self:Close();
end


function ReturnMainDlg:_EventOnCheckinTabClicked()
  if self.m_viewModel.tabState == ReturnTabState.STATE_TAB_CHECKIN or
      CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  self.m_viewModel:SetCheckinTabStatus();
  self.m_viewModel:NotifyUpdate();

  local groupId = ReturnModel.me:GetCurrentGroupId();
  CS.Torappu.GameAnalytics.RecordBackflowTabClicked(groupId, 
      CS.Torappu.EventTrack.EventLogTrace.EventLogBackflowTraceContext.BACKFLOW_TAB_KEY_CHECKIN);
end


function ReturnMainDlg:_EventOnMissionTabClicked()
  if self.m_viewModel.tabState == ReturnTabState.STATE_TAB_MISSION or
      CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  self.m_viewModel:SetMissionTabStatus();
  self.m_viewModel:NotifyUpdate();

  local groupId = ReturnModel.me:GetCurrentGroupId();
  CS.Torappu.GameAnalytics.RecordBackflowTabClicked(groupId, 
      CS.Torappu.EventTrack.EventLogTrace.EventLogBackflowTraceContext.BACKFLOW_TAB_KEY_MISSION);
end


function ReturnMainDlg:_EventOnNewsTabClicked()
  if self.m_viewModel.tabState == ReturnTabState.STATE_TAB_NEWS or
      CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  self.m_viewModel:SetNewsTabStatus();
  ReturnModel.me:ConsumeTabNewsLocalTrack();
  self.m_viewModel:NotifyUpdate();

  local groupId = ReturnModel.me:GetCurrentGroupId();
  CS.Torappu.GameAnalytics.RecordBackflowTabClicked(groupId, 
      CS.Torappu.EventTrack.EventLogTrace.EventLogBackflowTraceContext.BACKFLOW_TAB_KEY_NEWS);
end


function ReturnMainDlg:_EventOnSpecialOpenTabClicked()
  if self.m_viewModel.tabState == ReturnTabState.STATE_TAB_SPECIAL_OPEN or
      CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  self.m_viewModel:SetSpecialOpenTabStatus();
  ReturnModel.me:ConsumeTabSpecialOpenLocalTrack();
  self.m_viewModel:NotifyUpdate();

  local groupId = ReturnModel.me:GetCurrentGroupId();
  CS.Torappu.GameAnalytics.RecordBackflowTabClicked(groupId, 
      CS.Torappu.EventTrack.EventLogTrace.EventLogBackflowTraceContext.BACKFLOW_TAB_KEY_SPECIAL_OPEN);
end


function ReturnMainDlg:_EventOnPackageTabClicked()
  if self.m_viewModel.tabState == ReturnTabState.STATE_TAB_PACKAGE or
      CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  self.m_viewModel:SetPackageTabStatus();
  ReturnModel.me:ConsumeTabPackageLocalTrack();
  self.m_viewModel:NotifyUpdate();
  
  local groupId = ReturnModel.me:GetCurrentGroupId();
  CS.Torappu.GameAnalytics.RecordBackflowTabClicked(groupId, 
      CS.Torappu.EventTrack.EventLogTrace.EventLogBackflowTraceContext.BACKFLOW_TAB_KEY_PACKAGE);
end


function ReturnMainDlg:_EventOnWelcomeTabClicked()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  self:GetGroup():AddChildDlg(ReturnWelcomeDlg);
end


function ReturnMainDlg:_EventOnNoticeClicked()
  self:GetGroup():AddChildDlg(ReturnNoticeDlg);
end


function ReturnMainDlg:_EventOnSignInItemClicked(index)
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  UISender.me:SendRequest(ReturnServiceCode.GET_SIGNIN_REWARD, { 
      index = index
    },
    { 
      onProceed = Event.Create(self, self._HandleGetSignInRewardResponse)
    }
  );
end

function ReturnMainDlg:_EventOnNewsItemClicked(id)
  if self.m_viewModel == nil or self.m_viewModel.newsViewModel == nil then
    return;
  end
  self.m_viewModel.newsViewModel:SetSelection(id);
  self.m_viewModel:NotifyUpdate();
end


function ReturnMainDlg:_HandleGetSignInRewardResponse(response)
  if response == nil then
    return;
  end
  CS.Torappu.Activity.ActivityUtil.DoShowGainedItems(response.items);
  self.m_viewModel:RefreshPlayerData();
  TrackPointModel.me:UpdateNode(ReturnCheckInTrackPoint);
  self.m_viewModel:NotifyUpdate();
end



function ReturnMainDlg.JumpToTarget(type, param)
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  if type == CS.Torappu.ReturnJumpType.ZONE_GROUP then
    CS.Torappu.UI.UIRouteUtil.RouteToZoneViewType(CS.Torappu.UI.Stage.ZoneViewType.HOME);
  elseif type == CS.Torappu.ReturnJumpType.ROGUE then
    local lockTarget = CS.Torappu.UI.UILockTarget.PERM_MODE;
    if not _ToastIfLocked(lockTarget) then
      return;
    end
    if param == nil or param == "" then
      return;
    end
    CS.Torappu.UI.UIRouteUtil.RouteToRoguelikeTopic(param);
  elseif type == CS.Torappu.ReturnJumpType.SANDBOX then
    local lockTarget = CS.Torappu.UI.UILockTarget.PERM_MODE;
    if not _ToastIfLocked(lockTarget) then
      return;
    end
    if param == nil or param == "" then
      return;
    end
    CS.Torappu.UI.UIRouteUtil.RouteToSandboxPerm(param);
  elseif type == CS.Torappu.ReturnJumpType.CLIMB_TOWER then
    local toast = CS.Torappu.UI.ClimbTower.ClimbTowerUtil.GetClimbTowerFuncLockedToast();
    if toast ~= nil and toast ~= "" then
      luaUtils.TextToast(toast);
      return;
    end
    CS.Torappu.UI.UIRouteUtil.RouteToClimbTower();
  elseif type == CS.Torappu.ReturnJumpType.CAMPAIGN then
    local lockTarget = CS.Torappu.UI.UILockTarget.CAMPAIGN_ENTRY;
    if not _ToastIfLocked(lockTarget) then
      return;
    end
    local playerCampaign = CS.Torappu.PlayerData.instance.data.campaign;
    local stageId = playerCampaign.open.rotate;
    local zoneId = CS.Torappu.CampaignDataUtil.GetStageZone(stageId);
    if stageId == nil or stageId == "" or zoneId == nil or zoneId == "" then
      return;
    end
    CS.Torappu.UI.UIRouteUtil.RouteToCampaign(zoneId, stageId);
  elseif type == CS.Torappu.ReturnJumpType.BUILDING then
    local lockTarget = CS.Torappu.UI.UILockTarget.BUILDING_ENTRY;
    if not _ToastIfLocked(lockTarget) then
      return;
    end
    CS.Torappu.UI.UIRouteUtil.RouteToTarget(CS.Torappu.UI.UIRouteTarget.BUILDING);
  elseif type == CS.Torappu.ReturnJumpType.RECRUIT_BUILD then
    CS.Torappu.UI.UIRouteUtil.RouteToTarget(CS.Torappu.UI.UIRouteTarget.RECRUIT_BUILD);
  elseif type == CS.Torappu.ReturnJumpType.DAILY_MISSION then
    local lockTarget = CS.Torappu.UI.UILockTarget.MISSION_DAILY;
    if not _ToastIfLocked(lockTarget) then
      return;
    end
    CS.Torappu.UI.UIRouteUtil.RouteToMission(CS.Torappu.Mission.MissionPageType.DAILYMISSION);
  end
end

function _ToastIfLocked(lockTarget)
  local isUnlocked = CS.Torappu.UI.UIGuideController.CheckIfUnlocked(lockTarget);
  if not isUnlocked then
    CS.Torappu.UI.UIGuideController.ToastOnLockedItemClicked(lockTarget);
  end
  return isUnlocked;
end



function ReturnMainDlg:_EventOnSpecialOpenEntryClicked(openType)
  local model = self.m_viewModel.specialOpenViewModel;
  if model == nil then
    return;
  end
  model:SetOpenType(openType);
  self.m_viewModel:NotifyUpdate();
end


function ReturnMainDlg:_EventOnSpecialOpenGotoClicked()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  local model = self.m_viewModel.specialOpenViewModel;
  if model == nil then
    return;
  end

  local selectedType = model.selectedType;
  local groupId = ReturnModel.me:GetCurrentGroupId();
  if selectedType == ReturnAllOpenType.RESOURCE then
    local unlocked = CS.Torappu.UI.UIGuideController.CheckIfUnlocked(CS.Torappu.UI.UILockTarget.WEEKLY_MATERIAL) or
        CS.Torappu.UI.UIGuideController.CheckIfUnlocked(CS.Torappu.UI.UILockTarget.WEEKLY_EVOLVE);
    CS.Torappu.GameAnalytics.RecordBackflowSpecialOpenClicked(groupId, 
        BackflowSpecialOpenType.RESOURCE, unlocked);
    if not unlocked then
      CS.Torappu.UI.UIGuideController.ToastOnLockedItemClicked(CS.Torappu.UI.UILockTarget.WEEKLY_MATERIAL);
      return;
    end
    CS.Torappu.UI.UIRouteUtil.RouteToZoneViewType(CS.Torappu.UI.Stage.ZoneViewType.WEEKLY);
  elseif selectedType == ReturnAllOpenType.CAMP then
    local unlocked = _ToastIfLocked(CS.Torappu.UI.UILockTarget.CAMPAIGN_ENTRY);
    CS.Torappu.GameAnalytics.RecordBackflowSpecialOpenClicked(groupId, 
        BackflowSpecialOpenType.CAMPAIGN, unlocked);
    if not unlocked then
      return;
    end
    ReturnMainDlg.JumpToTarget(CS.Torappu.ReturnJumpType.CAMPAIGN);
  end
end