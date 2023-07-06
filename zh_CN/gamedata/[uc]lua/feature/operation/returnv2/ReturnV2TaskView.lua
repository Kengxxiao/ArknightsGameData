local luaUtil = CS.Torappu.Lua.Util
local colorRes = CS.Torappu.ColorRes





























local ReturnV2TaskView = Class("ReturnV2TaskView", UIPanel)
local ReturnV2MissionGroupAdapter = require("Feature/Operation/ReturnV2/ReturnV2MissionGroupAdapter")
local ReturnV2MissionItem = require("Feature/Operation/ReturnV2/ReturnV2MissionItem")
local ReturnV2MissionPointPanel = require("Feature/Operation/ReturnV2/ReturnV2MissionPointPanel")
local ReturnV2DailySupplyPanel = require("Feature/Operation/ReturnV2/ReturnV2DailySupplyPanel")

function ReturnV2TaskView:OnInit()
  self.m_adapter = self:CreateCustomComponent(ReturnV2MissionGroupAdapter, self._objAdapter, self)
  self.m_adapter.loadSpriteFunc = function(hubPath, spriteId)
    return self:LoadSpriteFromAutoPackHub(hubPath, spriteId)
  end
  self.m_adapter.missionGroupList = {};
  self.m_displayMission = self:CreateWidgetByPrefab(ReturnV2MissionItem, self._displayMissionPrefab, self._rectMissionParent)
  self.m_pointPanel = self:CreateWidgetByGO(ReturnV2MissionPointPanel, self._missionPointPanel)
  self.m_dailySupplyPanel = self:CreateWidgetByGO(ReturnV2DailySupplyPanel, self._dailySupplyPanel)
  self:AddButtonClickListener(self._btnJump, self._JumpBtnClick)
  self:AddButtonClickListener(self._btnClaimAll, self._ClaimAllBtnClick)
end


function ReturnV2TaskView:OnViewModelUpdate(data)
  if data == nil or data.tabState ~= ReturnV2StateTabStatus.STATE_TAB_TASK then
    return
  end

  
  
  
  SetGameObjectActive(self._objDailySupplyPanel, data.haveCompletedPriceReward)
  SetGameObjectActive(self._objMissionPointPanel, not data.haveCompletedPriceReward)
  SetGameObjectActive(self._objClaimAllBtn, data.haveTaskTabReward)
  self.m_pointPanel:Render(data.points, data.canClaimPriceReward)
  self.m_pointPanel.openDetailEvent = self.openPriceRewardDetailEvent
  self.m_pointPanel.claimPriceRewardEvent = self.claimTopBarRewardEvent
  self.m_dailySupplyPanel:Render(data.dailySupplyStateList, data.canClaimDailySupplyReward, data.lastCompleteDayIndex)
  self.m_dailySupplyPanel.claimDailySupplyEvent = self.claimTopBarRewardEvent
  self.m_dailySupplyPanel.openDetailEvent = self.openPriceRewardDetailEvent

  
  self.m_adapter.clickEvent = self.clickEvent
  self.m_adapter.missionGroupList = data.missionGroupList
  self.m_adapter.activeMissionGroupId = data.activeMissionGroupId
  self.m_adapter:NotifyDataSourceChanged();

  local activeGroup = self:_GetGroup(data.missionGroupList, data.activeMissionGroupId)
  self._displayGroupDesc.text = activeGroup.desc
  self._displayGroupTitle.text = activeGroup.title
  local endTime = data.missionEndTime
  if endTime then
    local endt = CS.Torappu.DateTimeUtil.TimeStampToDateTime(endTime)
    self._textEndTime.text = CS.Torappu.FormatUtil.FormatDateTimeyyyyMMddHHmm(endt)
  end
  local hubPath = CS.Torappu.ResourceUrls.GetReturnV2MissionGroupImageHubPath();
  self._imgMissionGroup.sprite = self:LoadSpriteFromAutoPackHub(hubPath, activeGroup.imageId)
  local displayMission = activeGroup:GetDisplayMission()
  luaUtil.SetActiveIfNecessary(self._objDisplayMission, displayMission)
  if displayMission then
    self.m_displayMission:Render(displayMission, false, true, activeGroup:CanOpenMissionList())
    self.m_displayMission.openMissionListPanelClick = self.openMissionListEvent
    self.m_displayMission.claimRewardClick = self.missionClaimEvent

    local showJumpBtn = displayMission.jumpType ~= CS.Torappu.ReturnV2JumpType.NONE
    luaUtil.SetActiveIfNecessary(self._objJumpBtn, showJumpBtn)
    self.m_jumpType = displayMission.jumpType
    self.m_jumpParam = displayMission.jumpParam
  else
    luaUtil.SetActiveIfNecessary(self._objJumpBtn, false)
    self.m_jumpType = CS.Torappu.ReturnV2JumpType.NONE
    self.m_jumpParam = nil
  end
end




function ReturnV2TaskView:_GetGroup(missionGroupList, groupId)
  if missionGroupList == nil or groupId == nil or groupId == "" then
    return nil
  end

  local groupNum = #missionGroupList
  for idx = 1, groupNum do
    if missionGroupList[idx].groupId == groupId then
      return missionGroupList[idx]
    end
  end
  return nil
end

function ReturnV2TaskView:_JumpBtnClick()
  ReturnV2MainDlg.JumpToTarget(self.m_jumpType, self.m_jumpParam)
end

function ReturnV2TaskView:_ClaimAllBtnClick()
  if self.claimAllEvent then
    self.claimAllEvent:Call()
  end
end

return ReturnV2TaskView;