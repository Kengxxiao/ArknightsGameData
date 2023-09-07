local luaUtils = CS.Torappu.Lua.Util;

MainlineBuffUtil = Class("MainlineBuffUtil");

local CACHE_KEY_FORMAT = "{0}_{1}";




function MainlineBuffUtil.IsPeriodChecked(actId, periodId)
  if actId == nil or actId == "" or periodId == nil or periodId == "" then
    return false;
  end

  local cacheKey = luaUtils.Format(CACHE_KEY_FORMAT, actId, periodId);
  return CS.Torappu.Activity.ActLocalCacheHandler.GetParamFromCache(cacheKey) <= 0;
end



function MainlineBuffUtil.SetPeriodChecked(actId, periodId)
  if actId == nil or actId == "" or periodId == nil or periodId == "" then
    return;
  end

  local cacheKey = luaUtils.Format(CACHE_KEY_FORMAT, actId, periodId);
  CS.Torappu.Activity.ActLocalCacheHandler.SaveParamToCache(cacheKey, 1);
end



function MainlineBuffUtil.GetCurrMainlineBuffActPeriodData(actId)
  if actId == nil or actId == "" then
    return nil;
  end
  local currentTime = luaUtils.GetCurrentTs();
  local suc, gameData = CS.Torappu.ActivityDB.data.activity.mainlineBuffData:TryGetValue(actId);
  if not suc or gameData.periodDataList == nil then
    return nil;
  end
  for i = 0, gameData.periodDataList.Count - 1 do
    local periodData = gameData.periodDataList[i];
    if currentTime >= periodData.startTime and currentTime < periodData.endTime then
      return periodData;
    end
  end
  return nil;
end



function MainlineBuffUtil.GetCurrMainlineBuffActPeriodId(actId)
  local data = MainlineBuffUtil.GetCurrMainlineBuffActPeriodData(actId);
  if data == nil then
    return "";
  else
    return data.id;
  end
end



function MainlineBuffUtil.CheckIfMissionGroupNeedComplete(actId)
  if actId == nil or actId == "" then
    return false;
  end

  local missionPlayer = CS.Torappu.PlayerData.instance.data.mission.missions.Activity;
  local suc, gameData = CS.Torappu.ActivityDB.data.activity.mainlineBuffData:TryGetValue(actId);
  if not suc or gameData.missionGroupList == nil then
    return false;
  end

  for i = 0, gameData.missionGroupList.Count - 1 do
    local missionList = gameData.missionGroupList[i].Value.missionIdList;
    if missionList == nil then
      break;
    end
    for j = 0, missionList.Count - 1 do
      local missionId = missionList[j];
      local suc, playerMission = missionPlayer:TryGetValue(missionId);
      if suc and playerMission.state == CS.Torappu.MissionHoldingState.CONFIRMED then
        local progress = playerMission.progress[0];
        if progress ~= nil and progress.value >= progress.target then
          return true;
        end
      end
    end
  end
  return false;
end