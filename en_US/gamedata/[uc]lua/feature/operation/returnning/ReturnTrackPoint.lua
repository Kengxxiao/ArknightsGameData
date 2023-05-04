
ReturnEntryTrackPoint = TrackPointModel.DefineTrackPoint("ReturnEntryTrackPoint");


ReturnTaskTabTrackPoint = TrackPointModel.DefineTrackPoint("ReturnTaskTabTrackPoint", ReturnEntryTrackPoint);
function ReturnTaskTabTrackPoint:OnCheckStatus()
  local currentData = CS.Torappu.PlayerData.instance.data.backflow.current
  if not currentData then 
    return false
  end
  local mission = currentData.mission
  if mission == nil then
    return false
  end
  
  local creditCanClaim = self:_CreditCanClaim(mission)
  if creditCanClaim then 
    return true
  end
  
  local dailyList = ToLuaArray(mission.dailyList)
  local dailyTaskCanClaim = self:_TaskCanClaim(dailyList)
  if dailyTaskCanClaim then
    return true
  end
  
  local longTermList = ToLuaArray(mission.longList)
  local longTermTaskCanClaim = self:_TaskCanClaim(longTermList)
  if longTermTaskCanClaim then
    return true
  end
  
  return false
end



function ReturnTaskTabTrackPoint:_CreditCanClaim(missionData)
  local returnConst = CS.Torappu.OpenServerDB.returnData.constData
  local rewardClaimed = missionData.reward
  local curCreditPro = missionData.point
  local targetCreditPro = returnConst.needPoints
  local creditFull = targetCreditPro > 0 and curCreditPro >= targetCreditPro
  if creditFull and rewardClaimed == false then
    return true
  end
  return false
end

function ReturnTaskTabTrackPoint:_TaskCanClaim(playerDataList)
  for idx = 1, #playerDataList do
    local data = playerDataList[idx]
    if data.status == ReturnTaskState.STATE_TASK_DONE then
      return true
    end
  end
  return false
end


ReturnCheckInTabTrackPoint = TrackPointModel.DefineTrackPoint("ReturnCheckInTabTrackPoint", ReturnEntryTrackPoint);
function ReturnCheckInTabTrackPoint:OnCheckStatus()
  return self:_HasCheckableRewards()
end


function ReturnCheckInTabTrackPoint:_HasCheckableRewards()
  local currentData = CS.Torappu.PlayerData.instance.data.backflow.current
  if not currentData then 
    return false
  end
  local checkIn = currentData.checkIn
  if checkIn == nil then
    return false
  end
  local checkinHistoryList = checkIn.history
  if not checkinHistoryList then
    return false
  end
  local gameDataList = ToLuaArray(checkinHistoryList)
  local checkInPlayerDataCount = #gameDataList

  for idx = 1, checkInPlayerDataCount do
    local history = gameDataList[idx]
    if history == ReturnCheckInState.STATE_CHECKIN_AVAILABLE then
      return true
    end
  end

  return false
end


ReturnOpenTabTrackPoint = TrackPointModel.DefineTrackPoint("ReturnOpenTabTrackPoint");
function ReturnOpenTabTrackPoint:OnCheckStatus()
  return not ReturnModel.me:HasClickedAllOpenTab()
end