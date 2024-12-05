local luaUtils = CS.Torappu.Lua.Util;

CheckinVideoUtil = Class("CheckinVideoUtil");



function CheckinVideoUtil.LoadGameData(actId)
  if string.isNullOrEmpty(actId) then
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



function CheckinVideoUtil.LoadPlayerData(actId)
  if string.isNullOrEmpty(actId) then
    luaUtils.LogError("[CheckinVideoUtil] activity Id is empty.");
    return nil;
  end
  local suc, jObject = CS.Torappu.PlayerData.instance.data.activity.checkinVideoActivityList:TryGetValue(actId);
  if not suc then
    luaUtils.LogError("[CheckinVideoUtil] Can't find gamedata of [".. actId .. "]");
    return nil;
  end
  return luaUtils.ConvertJObjectToLuaTable(jObject);
end