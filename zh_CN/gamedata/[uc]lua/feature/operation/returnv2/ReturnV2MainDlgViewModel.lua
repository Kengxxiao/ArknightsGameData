local ReturnV2MissionGroupViewModel = require("Feature/Operation/ReturnV2/ReturnV2TaskGroupViewModel")
local ReturnV2CheckinRewardModel = require("Feature/Operation/ReturnV2/ReturnV2CheckinRewardModel")





























ReturnV2MainDlgViewModel = Class("ReturnV2MainDlgViewModel", UIViewModel);

ReturnV2MainDlgViewModel.FULL_OPEN_STATE = {
  OPEN = 1,
  PAUSED = 2,
  CLOSED = 3
}

function ReturnV2MainDlgViewModel:LoadData()
  self.permMissionTime = CS.Torappu.OpenServerDB.returnV2Data.constData.permMissionTime
  self:_LoadMissionData()
  self:_LoadPointData()
  self:RefreshPlayerData()

  
  local isCheckinRewardNotConfirmed = TrackPointModel.me:IsShow(ReturnV2CheckInTabTrackPoint);
  if self.systemClose then
    self:SetSpecialOpenTabStatus();
  elseif isCheckinRewardNotConfirmed then
    self:SetCheckinTabStatus();
  else
    self:SetTaskTabStatus();
  end
end

function ReturnV2MainDlgViewModel:RefreshPlayerData()
  local playerData = CS.Torappu.PlayerData.instance.data.backflow;

  if playerData == nil or playerData.currentV2 == nil then
    self.startTs = 0;
  else
    self.startTs = playerData.currentV2.start;
  end

  self:_RefreshFullOpenData(playerData);
  self:_RefreshCheckInRewardList(playerData);

  self.systemClose = ReturnV2Model.me:CheckIfOnlyWeeklyOpen(playerData);
  self:_RefreshMissionData();
  self:_RefreshPointData();
  self:_RefreshClaimAllState();
end


function ReturnV2MainDlgViewModel:GetCheckInItemList()
  return self.m_checkInRewardList
end


function ReturnV2MainDlgViewModel:GetActiveCheckinCount()
  return self.m_activeCheckinCount
end



function ReturnV2MainDlgViewModel:_RefreshCheckInRewardList(playerReturn)
  self.m_activeCheckinCount = 0

  if playerReturn == nil or playerReturn.currentV2 == nil or playerReturn.currentV2.checkIn == nil then
    self.m_checkInRewardList = nil
    return
  end

  local playerCheckin = playerReturn.currentV2.checkIn
  if playerCheckin.groupId == nil then
    self.m_checkInRewardList = nil
    return
  end

  if playerCheckin.groupId ~= self.m_checkInGroupId then
    local checkInGroupData = self:_FindCheckInGroupData(playerCheckin.groupId)
    if checkInGroupData == nil or checkInGroupData.rewardList == nil then
      self.m_checkInRewardList = nil
      return
    end

    self.m_checkInGroupId = playerCheckin.groupId
    self.m_checkInRewardList = {}
    for i = 0, checkInGroupData.rewardList.Count-1 do
      local checkInRewardData = checkInGroupData.rewardList[i]
      local checkInRewardModel = ReturnV2CheckinRewardModel.new()
      checkInRewardModel:InitData(i, checkInRewardData)
      table.insert(self.m_checkInRewardList, checkInRewardModel)
    end
  end

  if playerCheckin ~= nil and playerCheckin.history ~= nil then
    self.m_activeCheckinCount = playerCheckin.history.Count
  end

  for _, checkInRewardModel in ipairs(self.m_checkInRewardList) do
    checkInRewardModel:UpdatePlayerData(playerCheckin)
  end
end



function ReturnV2MainDlgViewModel:_FindCheckInGroupData(groupId)
  local checkInGroupList = CS.Torappu.OpenServerDB.returnV2Data.checkInRewardData
  if checkInGroupList == nil then
    return nil
  end

  for i = 0, checkInGroupList.Count-1 do
    local checkInGroup = checkInGroupList[i]
    if checkInGroup.groupId == groupId then
      return checkInGroup
    end
  end

  return nil
end



function ReturnV2MainDlgViewModel:_RefreshFullOpenData(playerReturn)
  if playerReturn == nil or playerReturn.currentV2 == nil or playerReturn.currentV2.fullOpen == nil then
    self.fullOpenRemain = 0
    self.isTodayFullOpen = false
  end

  self.fullOpenRemain = playerReturn.currentV2.fullOpen.remain
  self.isTodayFullOpen = playerReturn.currentV2.fullOpen.today
  self.fullOpenState = self:_UpdateFullOpenState(playerReturn)
end



function ReturnV2MainDlgViewModel:_UpdateFullOpenState(playerReturn)
  if playerReturn == nil or playerReturn.open == false then
    return self.FULL_OPEN_STATE.CLOSED
  end

  if playerReturn.currentV2 == nil or playerReturn.currentV2.fullOpen == nil then
    return self.FULL_OPEN_STATE.CLOSED
  end

  local playerFullOpen = playerReturn.currentV2.fullOpen
  local isFinish = playerFullOpen.remain <= 0 and playerFullOpen.today == false
  if isFinish then
    return self.FULL_OPEN_STATE.CLOSED
  end

  if playerFullOpen.today == false then
    return self.FULL_OPEN_STATE.PAUSED
  else
    return self.FULL_OPEN_STATE.OPEN
  end
end

function ReturnV2MainDlgViewModel:_SetFirstMissionGroupSelected()
  if self.missionGroupList == nil or #self.missionGroupList <= 0 then
    self.activeMissionGroupId = nil
    return
  end
  self:SetActiveMissionGroupId(self.missionGroupList[1].groupId)
end


function ReturnV2MainDlgViewModel:SetActiveMissionGroupId(groupId)
  if groupId == nil then
    return
  end
  self.activeMissionGroupId = groupId
  local activeMissionGroup = self:GetMissionGroup(groupId)
  activeMissionGroup:SetMissionGroupTabClicked(true)
end

function ReturnV2MainDlgViewModel:SetCheckinTabStatus()
  self.tabState = ReturnV2StateTabStatus.STATE_TAB_CHECKIN
end

function ReturnV2MainDlgViewModel:SetTaskTabStatus()
  self.tabState = ReturnV2StateTabStatus.STATE_TAB_TASK
  self:_SetFirstMissionGroupSelected()
end

function ReturnV2MainDlgViewModel:SetSpecialOpenTabStatus()
  self.tabState = ReturnV2StateTabStatus.STATE_TAB_ALL_OPEN
end

function ReturnV2MainDlgViewModel:_SortGroupList()
  table.sort(self.missionGroupList, function(a, b)
    local groupAStateWeight = 0
    local groupBStateWeight = 0
    if a.groupState == ReturnV2TaskGroupState.ALL_COMPLETED then
      groupAStateWeight = 1
    end
    if b.groupState == ReturnV2TaskGroupState.ALL_COMPLETED then
      groupBStateWeight = 1
    end
    if groupAStateWeight ~= groupBStateWeight then
      return groupAStateWeight < groupBStateWeight
    elseif a.sortId ~= b.sortId then
      return a.sortId < b.sortId
    end
    return a.groupId < b.groupId
  end)
end

function ReturnV2MainDlgViewModel:_LoadMissionData()
  self.missionEndTime = ReturnV2Model.me:GetSystemEndTime()
  self.missionGroupList = {}
  local missionGroupList = ReturnV2Model.me:GetReturnV2MissionDBData()
  if missionGroupList ~= nil and #missionGroupList ~= 0 then
    for idx = 1, #missionGroupList do
      local csMissionGroupData = missionGroupList[idx]
      local csMissionProgressDataList = ReturnV2Model.me:GetReturnV2MissionPlayerData(csMissionGroupData.groupId)
      if csMissionProgressDataList ~= nil then
        local missionGroup = ReturnV2MissionGroupViewModel.new()
        missionGroup:LoadData(csMissionGroupData, csMissionProgressDataList)
        table.insert(self.missionGroupList, missionGroup)
      end
    end
  end
  self:_SortGroupList()
end

function ReturnV2MainDlgViewModel:_RefreshMissionData()
  local missionGroupList = ReturnV2Model.me:GetReturnV2MissionDBData()
  if missionGroupList ~= nil and #missionGroupList ~= 0 then
    for idx = 1, #missionGroupList do
      local csMissionGroupData = missionGroupList[idx]
      local missionGroup = self:GetMissionGroup(csMissionGroupData.groupId)
      if missionGroup ~= nil then
        missionGroup:RefreshMissionPlayerData()
      end
    end
  end
  self:_SortGroupList()
end



function ReturnV2MainDlgViewModel:GetMissionGroup(missionGroupId)
  if self.missionGroupList == nil or missionGroupId == nil or missionGroupId == "" then
    return nil
  end
  for idx = 1, #self.missionGroupList do
    local missionGroup = self.missionGroupList[idx]
    if missionGroup.groupId == missionGroupId then
      return self.missionGroupList[idx]
    end
  end
  return nil
end

function ReturnV2MainDlgViewModel:_RefreshPointData()
  self.points = ReturnV2Model.me:GetPricePoint()
  self.priceRewardState = ToLuaArray(ReturnV2Model.me:GetPriceRewardState())
  self.canClaimPriceReward = false
  self.haveCompletedPriceReward = true
  for idx = 1, #self.priceRewardState do
    if self.priceRewardState[idx] == ReturnV2PriceRewardState.CAN_CLAIM then
      self.canClaimPriceReward = true
    end
    if self.priceRewardState[idx] ~= ReturnV2PriceRewardState.CLAIMED then
      self.haveCompletedPriceReward = false
    end
  end

  self.dailySupplyStateList = ToLuaArray(ReturnV2Model.me:GetDailySupplyState())
  self.canClaimDailySupplyReward = false
  self.lastCompleteDayIndex = 0
  for idx = 1, #self.dailySupplyStateList do
    local state = self.dailySupplyStateList[idx]
    if state == ReturnV2DailySupplyState.CAN_CLAIM then
      self.canClaimDailySupplyReward = true
    end
    if state ~= ReturnV2DailySupplyState.UNCOMPLETE then
      self.lastCompleteDayIndex = self.lastCompleteDayIndex + 1
    end
  end
end

function ReturnV2MainDlgViewModel:_LoadPointData()
  self.topBarDailySupplyDesc = ReturnV2Model.me:GetDailySupplyDesc()
  self.topBarPointRewardDesc = ReturnV2Model.me:GetPriceRewardDesc()

  local activePriceRewardGroup = ReturnV2Model.me:GetPriceRewardGroup()
  if activePriceRewardGroup ~= nil then
    self.topBarPointRewardGroupContent = ToLuaArray(activePriceRewardGroup.contentList)
  end

  local activeDailySupplyGroup = ReturnV2Model.me:GetDailySupplyGroup()
  if activeDailySupplyGroup ~= nil then
    self.topBarDailySupplyBundleList = ToLuaArray(activeDailySupplyGroup.rewardList)
  end
end

function ReturnV2MainDlgViewModel:_RefreshClaimAllState()
  self.haveTaskTabReward = false
  for idx = 1, #self.missionGroupList do
    local missionGroup = self.missionGroupList[idx]
    if missionGroup.groupState == ReturnV2TaskGroupState.HAVE_REWARD then
      self.haveTaskTabReward = true
      return
    end
  end
  self.haveTaskTabReward = self.canClaimDailySupplyReward or self.canClaimPriceReward
end