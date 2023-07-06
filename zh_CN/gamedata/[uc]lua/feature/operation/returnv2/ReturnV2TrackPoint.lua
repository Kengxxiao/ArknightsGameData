
ReturnV2EntryTrackPoint = TrackPointModel.DefineTrackPoint("ReturnV2EntryTrackPoint");


ReturnV2TaskTabTrackPoint = TrackPointModel.DefineTrackPoint("ReturnV2TaskTabTrackPoint", ReturnV2EntryTrackPoint);
function ReturnV2TaskTabTrackPoint:OnCheckStatus()
  local currentData = CS.Torappu.PlayerData.instance.data.backflow.currentV2;
  if currentData == nil then
    return false;
  end
  local mission = currentData.mission;
  if mission == nil then
    return false;
  end
  
  local stageAwardCanClaim = self:_CheckIfTaskCanClaim(mission.stageAward);
  if stageAwardCanClaim then
    return true;
  end
  local dailySupplyCanClaim = self:_CheckIfTaskCanClaim(mission.dailySupply);
  if dailySupplyCanClaim then
    return true;
  end
  local missionCanClaim = self:_CheckIfMissionCanClaim(mission.missionDict);
  if missionCanClaim then
    return true;
  end
  return false;
end



function ReturnV2TaskTabTrackPoint:_CheckIfTaskCanClaim(playerDataList)
  if playerDataList == nil then
    return false;
  end
  local dailySupplyArray = ToLuaArray(playerDataList);
  for index = 1, #dailySupplyArray do
    if dailySupplyArray[index] == ReturnV2TaskState.TASK_CAN_CLAIM then
      return true;
    end
  end
  return false;
end



function ReturnV2TaskTabTrackPoint:_CheckIfMissionCanClaim(missionData)
  for groupId, groupData in pairs(missionData) do
    if groupData == nil then
      break;
    end
    local groupArray = ToLuaArray(groupData);
    for index = 1, #groupArray do
      if groupArray[index].status == ReturnV2TaskState.TASK_CAN_CLAIM then
        return true;
      end
    end
  end
  return false;
end


ReturnV2CheckInTabTrackPoint = TrackPointModel.DefineTrackPoint("ReturnV2CheckInTabTrackPoint", ReturnV2EntryTrackPoint);
function ReturnV2CheckInTabTrackPoint:OnCheckStatus()
  local currentData = CS.Torappu.PlayerData.instance.data.backflow.currentV2;
  if currentData == nil then
    return false;
  end
  local checkIn = currentData.checkIn;
  if checkIn == nil then
    return false;
  end
  local historyList = checkIn.history;
  if historyList == nil then
    return false;
  end

  local historyArray = ToLuaArray(historyList);
  for index = 1, #historyArray do
    local history = historyArray[index];
    if history == ReturnV2CheckInState.STATE_CHECKIN_AVAILABLE then
      return true;
    end
  end
  return false;
end


ReturnV2OpenTabTrackPoint = TrackPointModel.DefineTrackPoint("ReturnV2OpenTabTrackPoint");
function ReturnV2OpenTabTrackPoint:OnCheckStatus()
  return not ReturnV2Model.me:HasClickedAllOpenTab();
end