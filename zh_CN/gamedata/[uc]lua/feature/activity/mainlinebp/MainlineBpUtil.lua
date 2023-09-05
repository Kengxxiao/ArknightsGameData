local luaUtils = CS.Torappu.Lua.Util;

MainlineBpUtil = Class("MainlineBpUtil");



function MainlineBpUtil.LoadGameData(actId)
  if actId == nil or actId == "" then
    luaUtils.LogError("[ActMainlineBp] activity Id is empty.");
    return nil;
  end
  local suc, jObject = CS.Torappu.ActivityDB.data.dynActs:TryGetValue(actId);
  if not suc then
    luaUtils.LogError("[ActMainlineBp] Can't find gamedata of [".. actId .. "]");
    return nil;
  end
  return luaUtils.ConvertJObjectToLuaTable(jObject);
end



function MainlineBpUtil.LoadPlayerData(actId)
  if actId == nil or actId == "" then
    luaUtils.LogError("[ActMainlineBp] activity Id is empty.");
    return nil;
  end
  local suc, jObject = CS.Torappu.PlayerData.instance.data.activity.mainlineBpActivityList:TryGetValue(actId);
  if not suc then
    luaUtils.LogError("[ActMainlineBp] Can't find gamedata of [".. actId .. "]");
    return nil;
  end
  return luaUtils.ConvertJObjectToLuaTable(jObject);
end



function MainlineBpUtil.GetCurrentPeriodId(data)
  if data == nil or data.periodDataList == nil then
    return "";
  end
  local currTs = CS.Torappu.DateTimeUtil.timeStampNow;
  for index, model in pairs(data.periodDataList) do
    if model == nil then
      break;
    end
    if currTs >= model.startTime and currTs <= model.endTime then
      return model.id;
    end
  end
  return "";
end




function MainlineBpUtil.CheckIfContainPeriod(periodIdList, periodId)
  if periodIdList == nil or periodId == nil or periodId == "" then
    return false;
  end
  for index, period in pairs(periodIdList) do
    if periodId == period then
      return true;
    end
  end
  return false;
end





function MainlineBpUtil.GetMissionData(missionList, missionId, actId)
  if missionList == nil or 
      missionId == nil or
      missionId == "" or 
      actId == nil or
      actId == "" then
    return nil;
  end

  for idx, cur in pairs(missionList) do
    if cur.id == missionId and cur.missionGroup == actId then
      return cur;
    end
  end
  return nil;
end




function MainlineBpUtil.GetPeriodData(periodList, periodId)
  if periodList == nil or periodId == nil or periodId == "" then
    return nil;
  end
  for index, period in pairs(periodList) do
    if periodId == period.id then
      return period;
    end
  end
  return nil;
end



function MainlineBpUtil.CompareMissionItemModel(a, b)
  if a.groupSortId ~= b.groupSortId then
    return a.groupSortId < b.groupSortId;
  end
  
  local isAMission = a.itemType == MainlineBpMissionItemType.MISSION;
  local isBMission = b.itemType == MainlineBpMissionItemType.MISSION;
  if isAMission and isBMission and a.missionState ~= b.missionState then
    return a.missionState < b.missionState;
  end
  return a.innerSortId < b.innerSortId;
end



function MainlineBpUtil.CheckIfUncomplete(actId) 
  local gameData = MainlineBpUtil.LoadGameData(actId);
  local periodId = MainlineBpUtil.GetCurrentPeriodId(gameData);
  local playerData = MainlineBpUtil.LoadPlayerData(actId);
  if periodId == nil or periodId == "" then
    return false;
  end

  return MainlineBpUtil.CheckIfShowMissionTrackPoint(gameData, periodId) or
      MainlineBpUtil.CheckIfShowBpTrackPoint(gameData, periodId, playerData) or
      not MainlineBpUtil.IsPeriodChecked(actId, periodId);
end




function MainlineBpUtil.CheckIfShowMissionTrackPoint(gameData, periodId)
  local playerData = CS.Torappu.PlayerData.instance.data.mission.missions.Activity;
  if gameData == nil then
    return false;
  end
  
  for groupId, missionGroupData in pairs(gameData.missionGroupMap) do
    if missionGroupData == nil then
      break;
    end
    if MainlineBpUtil.CheckIfContainPeriod(missionGroupData.showPeriodList, periodId) then
      for index, missionId in pairs(missionGroupData.missionIdList) do
        local suc, missionData = playerData:TryGetValue(missionId);
        if suc and missionData ~= nil and missionData.progress.Count > 0 then
          local progress = missionData.progress[0];
          if missionData.state == CS.Torappu.MissionHoldingState.CONFIRMED and
              progress.value >= progress.target then
            return true;
          end
        end
      end
    end
  end
  return false;
end





function MainlineBpUtil.CheckIfShowBpTrackPoint(gameData,periodId,playerData)
  if gameData == nil or playerData == nil then
    return false;
  end
  
  local limitBpRewardStateDict = playerData.rewardState;
  local playerHasLimitRewardState = limitBpRewardStateDict ~= nil;
  if playerHasLimitRewardState == true then
    for groupId, groupBpLimitData in pairs(gameData.mileStoneGroupMap) do
      local needShow = MainlineBpUtil.CheckIfContainPeriod(groupBpLimitData.showPeriodList, periodId);
      local canClaim = MainlineBpUtil.CheckIfContainPeriod(groupBpLimitData.getPeriodList, periodId);
      if needShow == true and canClaim == true then
        local bpLimitList = groupBpLimitData.bpDataList;
        if bpLimitList ~= nil then
          for i = 1, #bpLimitList do
            local bpId = bpLimitList[i].id;
            if limitBpRewardStateDict[bpId] == MainlineBpLimitBpItemRewardState.OPEN then
              return true;
            end
          end
        end
      end
    end
  end
  
  local periodData = MainlineBpUtil.GetPeriodData(gameData.periodDataList, periodId);
  local unlimitBpDataList = gameData.unlimitBpDataList;
  local unlimitBpDataCount = #unlimitBpDataList;
  local startIndex = playerData.nextRewardIndex + 1;
  if periodData ~= nil and periodData.canGetUnlimitBp == true and unlimitBpDataList ~= nil and startIndex >= 1 and startIndex <= unlimitBpDataCount then
    local unconfirmedUnlimitPoints = playerData.unconfirmedInfPoints;
    local startUnlimitData = unlimitBpDataList[startIndex];
    local needPoints = startUnlimitData.tokenNum;
    if needPoints <= unconfirmedUnlimitPoints then
      return true;
    end
  end
  return false;
end




function MainlineBpUtil.IsPeriodChecked(actId, periodId)
  if actId == nil or actId == "" or periodId == nil or periodId == "" then
    return false;
  end

  local typeStr = luaUtils.Format(CS.Torappu.LocalTrackTypes.ACT_MAINLINE_BP_TRACK, actId);
  return not CS.Torappu.LocalTrackStore.instance:CheckTrack(
      typeStr, periodId);
end



function MainlineBpUtil.SetPeriodChecked(actId, periodId)
  if actId == nil or actId == "" or periodId == nil or periodId == "" then
    return;
  end

  local typeStr = luaUtils.Format(CS.Torappu.LocalTrackTypes.ACT_MAINLINE_BP_TRACK, actId);
  return CS.Torappu.LocalTrackStore.instance:ConsumeTrack(
      typeStr, periodId);
end



function MainlineBpUtil.CompareLimitBpItemModel(a, b)
  if a.itemType ~= b.itemType then
    return a.itemType < b.itemType;
  end
  local isAReward = a.itemType == MainlineBpLimitBpItemType.REWARD;
  local isBReward = b.itemType == MainlineBpLimitBpItemType.REWARD;
  if isAReward and isBReward and a.groupSortId ~= b.groupSortId then
    return a.groupSortId < b.groupSortId;
  end
  return a.innerSortId < b.innerSortId;
end