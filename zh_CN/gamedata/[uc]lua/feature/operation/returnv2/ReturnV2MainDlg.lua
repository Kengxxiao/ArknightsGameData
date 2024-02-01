local luaUtils = CS.Torappu.Lua.Util;

























ReturnV2MainDlg = DlgMgr.DefineDialog("ReturnV2MainDlg", "Operation/ReturnV2/return_v2_main_dlg")
local ReturnV2Panel = require("Feature/Operation/ReturnV2/ReturnV2Panel")
local ReturnV2TaskView = require("Feature/Operation/ReturnV2/ReturnV2TaskView")
local ReturnV2SpecialOpenView = require("Feature/Operation/ReturnV2/ReturnV2SpecialOpenView")
local ReturnV2CheckinView = require("Feature/Operation/ReturnV2/ReturnV2CheckinView")
local ReturnV2MissionListPanel = require("Feature/Operation/ReturnV2/ReturnV2MissionListPanel")
local ReturnV2MissionTopBarDetailPanel = require("Feature/Operation/ReturnV2/ReturnV2MissionTopBarDetailPanel")

function ReturnV2MainDlg:OnInit()
  
  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnClose)
  self:AddButtonClickListener(self._btnClose, self._EventOnCloseClick)
  self:AddButtonClickListener(self._btnWelcome, self._EventOnWelcomeBtnClick)
  self:AddButtonClickListener(self._btnTabCheckin, self._EventOnCheckinTabClick)
  self:AddButtonClickListener(self._btnTabTask, self._EventOnTaskTabClick)
  self:AddButtonClickListener(self._btnTabSpecialOpen, self._EventOnSpecialOpenTabClick)

  
  TrackPointModel.me:BindUI(ReturnV2CheckInTabTrackPoint, self._trackPointCheckIn);
  TrackPointModel.me:BindUI(ReturnV2TaskTabTrackPoint, self._trackPointTask);
  TrackPointModel.me:BindUI(ReturnV2OpenTabTrackPoint, self._trackPointOpen);
  
  
  self.m_viewModel = self:CreateViewModel(ReturnV2MainDlgViewModel);
  self.m_viewModel:LoadData();

  
  self:CreateWidgetByGO(ReturnV2Panel, self._returnV2Panel)
  self.m_taskView = self:CreateWidgetByPrefab(ReturnV2TaskView, self._taskViewPrefab, self._rectTaskParent)
  self.m_checkinView = self:CreateWidgetByPrefab(ReturnV2CheckinView, self._checkinViewPrefab, self._rectCheckinParent)
  self:CreateWidgetByPrefab(ReturnV2SpecialOpenView, self._specialOpenViewPrefab, self._rectSpecialOpenParent)
  self.m_missionListPanel = self:CreateWidgetByPrefab(ReturnV2MissionListPanel, self._missionListPanelPrefab, self._rectMissionListParent)
  self.m_topBarDetailPanel = self:CreateWidgetByPrefab(ReturnV2MissionTopBarDetailPanel, self._topBarDetailPrefab, self._rectTopBarDetailParent)

  self.m_taskView.clickEvent = Event.Create(self, self._HandleMissionGroupTabClick)
  self.m_taskView.missionClaimEvent = Event.Create(self, self._HandleMissionClaimReward)
  self.m_taskView.claimAllEvent = Event.Create(self, self._HandleClaimAllReward)
  self.m_taskView.openMissionListEvent = Event.Create(self, self._HandleOpenMissionList)
  self.m_taskView.claimTopBarRewardEvent = Event.Create(self, self._HandleClaimPriceRewardAndDailySupply)
  self.m_taskView.openPriceRewardDetailEvent = Event.Create(self, self._HandleOpenTopBarDetail)
  self.m_missionListPanel.closePanelEvent = Event.Create(self, self._HandleCloseMissionList)
  self.m_topBarDetailPanel.closePanelEvent = Event.Create(self, self._HandleCloseTopBarDetail)
  self.m_checkinView.onSignItemClick = Event.Create(self, self._HandleSignItemClick)

  self.m_viewModel:NotifyUpdate()
end

function ReturnV2MainDlg:OnClose()
  TrackPointModel.me:UnbindUI(ReturnV2CheckInTabTrackPoint);
  TrackPointModel.me:UnbindUI(ReturnV2TaskTabTrackPoint);
  TrackPointModel.me:UnbindUI(ReturnV2OpenTabTrackPoint);
end



function ReturnV2MainDlg:_HandleSignItemClick(idx)
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return
  end

  UISender.me:SendRequest(ReturnV2ServiceCode.GET_SIGNIN_REWARD, 
      {
        index = idx
      }, 
      {
        onProceed = Event.Create(self, self._HandleGetSignRewardRsp)
      }
  )
end



function ReturnV2MainDlg:_HandleGetSignRewardRsp(response)
  self.m_viewModel:RefreshPlayerData()
  self.m_viewModel:NotifyUpdate()
  TrackPointModel.me:UpdateNode(ReturnV2CheckInTabTrackPoint)

  if response.items ~= nil and #response.items > 0 then
    UIMiscHelper.ShowGainedItems(response.items)
  end
end

function ReturnV2MainDlg:_EventOnWelcomeBtnClick()
  local dlg = self:GetGroup():AddChildDlg(ReturnV2WelcomeDlg)
end

function ReturnV2MainDlg:_EventOnCheckinTabClick()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return
  end
  self.m_viewModel:SetCheckinTabStatus()
  self.m_viewModel:NotifyUpdate()
end

function ReturnV2MainDlg:_EventOnTaskTabClick()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return
  end
  self.m_viewModel:SetTaskTabStatus()
  self.m_viewModel:NotifyUpdate()
end

function ReturnV2MainDlg:_EventOnSpecialOpenTabClick()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return
  end
  self.m_viewModel:SetSpecialOpenTabStatus()
  self.m_viewModel:NotifyUpdate()

  
  ReturnV2Model.me:SetAllOpenTabClicked(true);
  TrackPointModel.me:UpdateNode(ReturnV2OpenTabTrackPoint)
end

function ReturnV2MainDlg:_EventOnCloseClick()
  local viewModel = self.m_viewModel
  if viewModel ~= nil and viewModel.showMissionListPanel then
    self:_HandleCloseMissionList()
    return
  end
  if viewModel ~= nil and viewModel.showTopBarDetailPanel then
    self:_HandleCloseTopBarDetail()
    return
  end
  self:Close()
end


function ReturnV2MainDlg:_HandleMissionGroupTabClick(clickedMissionGroupId)
  self.m_viewModel:SetActiveMissionGroupId(clickedMissionGroupId)
  self.m_viewModel:NotifyUpdate()
end


function ReturnV2MainDlg:_HandleMissionClaimReward(claimMissionGroupId)
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return
  end

  UISender.me:SendRequest(ReturnV2ServiceCode.GET_MISSION_REWARD,
  {
    groupId = claimMissionGroupId,
  }, 
  {
    onProceed = Event.Create(self, self._HandleRewardClaimed)
  });
end

function ReturnV2MainDlg:_HandleClaimAllReward()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return
  end

  if not self.m_viewModel.haveTaskTabReward then
    return
  end

  UISender.me:SendRequest(ReturnV2ServiceCode.AUTO_GET_REWARD,
  {
  }, 
  {
    onProceed = Event.Create(self, self._HandleRewardClaimed)
  });
end

function ReturnV2MainDlg:_HandleRewardClaimed(response)
  TrackPointModel.me:UpdateNode(ReturnV2TaskTabTrackPoint);
  CS.Torappu.Activity.ActivityUtil.DoShowGainedItems(response.items)
  self.m_viewModel:RefreshPlayerData()
  self.m_viewModel:NotifyUpdate()
end

function ReturnV2MainDlg:_HandleOpenMissionList()
  self.m_viewModel.showMissionListPanel = true
  self.m_viewModel:NotifyUpdate()
end

function ReturnV2MainDlg:_HandleCloseMissionList()
  self.m_viewModel.showMissionListPanel = false
  self.m_viewModel:NotifyUpdate()
end

function ReturnV2MainDlg:_HandleClaimPriceRewardAndDailySupply()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return
  end

  UISender.me:SendRequest(ReturnV2ServiceCode.GET_POINT_REWARD,
  {
  }, 
  {
    onProceed = Event.Create(self, self._HandleRewardClaimed)
  });
end

function ReturnV2MainDlg:_HandleOpenTopBarDetail()
  self.m_viewModel.showTopBarDetailPanel = true
  self.m_viewModel:NotifyUpdate()
end

function ReturnV2MainDlg:_HandleCloseTopBarDetail()
  self.m_viewModel.showTopBarDetailPanel = false
  self.m_viewModel:NotifyUpdate()
end



local function _ToastIfLocked(lockTarget)
  local isUnlocked = CS.Torappu.UI.UIGuideController.CheckIfUnlocked(lockTarget);
  if not isUnlocked then
    CS.Torappu.UI.UIGuideController.ToastOnLockedItemClicked(lockTarget);
  end
  return isUnlocked;
end



function ReturnV2MainDlg.JumpToTarget(type, param)
  if type == CS.Torappu.ReturnV2JumpType.ZONE_GROUP then
    CS.Torappu.UI.UIRouteUtil.RouteToZoneViewType(CS.Torappu.UI.Stage.ZoneViewType.HOME);
  elseif type == CS.Torappu.ReturnV2JumpType.ROGUE then
    local lockTarget = CS.Torappu.UI.UILockTarget.PERM_MODE;
    if not _ToastIfLocked(lockTarget) then
      return;
    end
    if param == nil or param == "" then
      return;
    end
    CS.Torappu.UI.UIRouteUtil.RouteToRoguelikeTopic(param);
  elseif type == CS.Torappu.ReturnV2JumpType.SANDBOX then
    local lockTarget = CS.Torappu.UI.UILockTarget.PERM_MODE;
    if not _ToastIfLocked(lockTarget) then
      return;
    end
    if param == nil or param == "" then
      return;
    end
    CS.Torappu.UI.UIRouteUtil.RouteToSandboxPerm(param);
  elseif type == CS.Torappu.ReturnV2JumpType.CLIMB_TOWER then
    local toast = CS.Torappu.UI.ClimbTower.ClimbTowerUtil.GetClimbTowerFuncLockedToast();
    if toast ~= nil and toast ~= "" then
      luaUtils.TextToast(toast);
      return;
    end
    CS.Torappu.UI.UIRouteUtil.RouteToClimbTower();
  elseif type == CS.Torappu.ReturnV2JumpType.CAMPAIGN then
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
  elseif type == CS.Torappu.ReturnV2JumpType.BUILDING then
    local lockTarget = CS.Torappu.UI.UILockTarget.BUILDING_ENTRY;
    if not _ToastIfLocked(lockTarget) then
      return;
    end
    CS.Torappu.UI.UIRouteUtil.RouteToTarget(CS.Torappu.UI.UIRouteTarget.BUILDING);
  elseif type == CS.Torappu.ReturnV2JumpType.RECRUIT_BUILD then
    CS.Torappu.UI.UIRouteUtil.RouteToTarget(CS.Torappu.UI.UIRouteTarget.RECRUIT_BUILD);
  elseif type == CS.Torappu.ReturnV2JumpType.DAILY_MISSION then
    local lockTarget = CS.Torappu.UI.UILockTarget.MISSION_DAILY;
    if not _ToastIfLocked(lockTarget) then
      return;
    end
    CS.Torappu.UI.UIRouteUtil.RouteToMission(CS.Torappu.Mission.MissionPageType.DAILYMISSION);
  end
end