local luaUtils = CS.Torappu.Lua.Util











local CollectionSimpleTaskModel = Class("CollectionSimpleTaskModel")

CollectionSimpleTaskModel.MISSION_STATE = {
  HAS_REWARD = 0,
  NOT_COMPLETED = 1,
  CLAIMED = 2,
}



function CollectionSimpleTaskModel:LoadData(missionData, config)
  if missionData == nil or config == nil or missionData.rewards == nil or missionData.rewards.Count <= 0 then
    return
  end
  local missionReward = missionData.rewards[0]
  self.missionId = missionData.id
  self.sortId = missionData.sortId
  self.themeColor = config.baseColor
  self.desc = missionData.description
  self.missionState = CollectionSimpleTaskModel.MISSION_STATE.NOT_COMPLETED
  self.rewardPointCount = missionReward:GetItemCount()
end


function CollectionSimpleTaskModel:UpdateData(state)
  if state == nil or state.progress == nil or state.progress.Count <= 0 then
    return
  end
  local progress = state.progress[0]
  self.missionProgressCurr = progress.value
  self.missionProgressTarget = progress.target
  if state.state == CS.Torappu.MissionHoldingState.FINISHED then
    self.missionState = CollectionSimpleTaskModel.MISSION_STATE.CLAIMED
  elseif progress.value >= progress.target then
    self.missionState = CollectionSimpleTaskModel.MISSION_STATE.HAS_REWARD
  else
    self.missionState = CollectionSimpleTaskModel.MISSION_STATE.NOT_COMPLETED
  end
  self.hasMissionCompleted = self.missionState ~= CollectionSimpleTaskModel.MISSION_STATE.NOT_COMPLETED
  self.isMissionClaimed = self.missionState == CollectionSimpleTaskModel.MISSION_STATE.CLAIMED
end







local CollectionSimpleTaskListViewModel = Class("CollectionSimpleTaskListViewModel")



local function _CompareTaskItem(a, b)
  local aState = a.missionState
  local bState = b.missionState
  if not aState then
    aState = CollectionSimpleTaskModel.MISSION_STATE.CLAIMED
  end
  if not bState then
    bState = CollectionSimpleTaskModel.MISSION_STATE.CLAIMED
  end
  if aState ~= bState then
    return aState < bState
  end
  return a.sortId < b.sortId
end


function CollectionSimpleTaskListViewModel:LoadData(actId)
  if actId == nil then
    return
  end
  self.actConfig = CollectionActModel.me:GetActCfg(actId)
  local csMissionDataList = luaUtils.GenerateActMissionListByActId(actId)
  if csMissionDataList == nil then
    return
  end
  local luaMissionDataList = ToLuaArray(csMissionDataList)
  self.missionItemList = {}
  for index, missionData in pairs(luaMissionDataList) do
    
    local itemModel = CollectionSimpleTaskModel.new()
    itemModel:LoadData(missionData, self.actConfig)
    table.insert(self.missionItemList, itemModel)
  end
end


function CollectionSimpleTaskListViewModel:UpdateData(actId)
  if not actId then
    return
  end
  local playerMissionData = CS.Torappu.PlayerData.instance.data.mission.missions
  local typeMissionSuc, typeMissions = playerMissionData:TryGetValue(CS.Torappu.MissionPlayerDataGroup.MissionTypeString.ACTIVITY)
  if not typeMissionSuc then
    return
  end

  self.showClaimAllObject = false
  for index, missionItemModel in pairs(self.missionItemList) do
    
    local itemModel = missionItemModel
    local suc, state = typeMissions:TryGetValue(itemModel.missionId)
    if suc then
      itemModel:UpdateData(state)
      if itemModel.missionState == CollectionSimpleTaskModel.MISSION_STATE.HAS_REWARD then
        self.showClaimAllObject = true
      end
    end
  end

  table.sort(self.missionItemList, _CompareTaskItem)
end

return CollectionSimpleTaskListViewModel