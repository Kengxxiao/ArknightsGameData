local luaUtils = CS.Torappu.Lua.Util;

BlessOnlyUtil = Class("BlessOnlyUtil");



function BlessOnlyUtil.LoadPlayerData(actId)
  if actId == nil or actId == "" then
    luaUtils.LogError("[BlessOnly] activity Id is empty.");
    return nil;
  end
  local suc, playerData = CS.Torappu.PlayerData.instance.data.activity.blessOnlyList:TryGetValue(actId);
  if not suc then
    luaUtils.LogError("[BlessOnly] Can't find playerData of [".. actId .. "]");
    return nil;
  end
  return playerData;
end



function BlessOnlyUtil.LoadGameData(actId)
  if actId == nil or actId == "" then
    luaUtils.LogError("[BlessOnly] activity Id is empty.");
    return nil;
  end
  local suc, jObject = CS.Torappu.ActivityDB.data.dynActs:TryGetValue(actId);
  if not suc then
    luaUtils.LogError("[BlessOnly] Can't find gamedata of [".. actId .. "]");
    return nil;
  end
  return luaUtils.ConvertJObjectToLuaTable(jObject);
end



function BlessOnlyUtil.CheckBlessActIsUncomplete(actId)
  local playerData = BlessOnlyUtil.LoadPlayerData(actId);
  if playerData == nil then
    return false;
  end
  local history = playerData.history;
  if history ~= nil then
    for csI = 0, history.Count - 1 do
      if history[csI] == 1 then
        return true;
      end
    end
  end

  local festivalHistory = playerData.festivalHistory;
  if festivalHistory ~= nil then
    for csI = 0, festivalHistory.Count - 1 do
      local fes = festivalHistory[csI];
      if fes ~= nil and fes.state == 1 then
        return true;
      end
    end
  end
  return false;
end



function BlessOnlyUtil.CheckBlessActIsFinished(actId)
  local playerData = BlessOnlyUtil.LoadPlayerData(actId);
  if playerData == nil then
    return false;
  end
  local festivalHistory = playerData.festivalHistory;
  local checkInHistory = playerData.history;
  if checkInHistory == nil or festivalHistory == nil then
    return false;
  end

  local actData = BlessOnlyUtil.LoadGameData(actId);
  if actData == nil or actData.festivalInfoList == nil or actData.checkInInfos == nil then
    return false;
  end
  
  local checkInCount = 0;
  for index, data in pairs(actData.checkInInfos) do
    checkInCount = checkInCount + 1;
  end
  if checkInHistory.Count ~= checkInCount then 
    return false;
  end

  local fesCount = 0;
  for index, data in pairs(actData.festivalInfoList) do
    fesCount = fesCount + 1;
  end
  if festivalHistory.Count ~= fesCount then 
    return false;
  end

  for csI = 0, festivalHistory.Count - 1 do
    local fes = festivalHistory[csI];
    if fes ~= nil and fes.state ~= 0 then   
      return false;
    end
  end

  for csI = 0, checkInHistory.Count - 1 do
    if checkInHistory[csI] ~= nil and checkInHistory[csI] ~= 0 then
      return false;
    end
  end

  return true;
end
