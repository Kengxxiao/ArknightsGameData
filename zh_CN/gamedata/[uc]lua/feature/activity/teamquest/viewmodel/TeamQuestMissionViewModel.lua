








local TeamQuestMissionViewModel = Class("TeamQuestMissionViewModel", nil)


function TeamQuestMissionViewModel:InitData(missionData)
  self.id = missionData.id
  self.sortId = missionData.sortId
  self.desc = missionData.description
  self.normalRewardCnt = missionData.normalRewardCnt
  self.teamRewardCnt = missionData.teamRewardCnt
end


function TeamQuestMissionViewModel:RefreshPlayerData(playerActData)
  if playerActData == nil or playerActData.mission == nil then
    return
  end

  local missionDict = playerActData.mission.missions
  if missionDict == nil then
    return
  end

  local playerMission = missionDict[self.id]
  self.statusType = self:_CalcStatusType(playerMission)

  local currVal = 0
  local maxVal = 0
  if playerMission ~= nil and playerMission.progress ~= nil then
    currVal = playerMission.progress[1]
    maxVal = playerMission.progress[2]
  end
  self.progressCurr = currVal
  self.progressMax = maxVal
end



function TeamQuestMissionViewModel:_CalcStatusType(playerMission)
  if playerMission == nil or playerMission.progress == nil or playerMission.state == nil then
    return TeamQuestMissionStatusType.UNCOMPLETE
  end

  if playerMission == nil or playerMission.progress == nil or playerMission.state == nil then
    return TeamQuestMissionStatusType.UNCOMPLETE
  end

  if playerMission.state == 1 then
    return TeamQuestMissionStatusType.COMPLETE
  end

  if playerMission.state == 0 and playerMission.progress[1] >= playerMission.progress[2] then
    return TeamQuestMissionStatusType.AVAIL
  end

  return TeamQuestMissionStatusType.UNCOMPLETE
end

return TeamQuestMissionViewModel