local luaUtils = CS.Torappu.Lua.Util;

TeamQuestUtil = Class("TeamQuestUtil", nil)

TeamQuestUtil.ACT_LOCAL_CACHE_NO_TEAM_HINT = "NO_TEAM_HINT"



function TeamQuestUtil.GetPlayerData(actId)
	  local playerActs = CS.Torappu.PlayerData.instance.data.activity.teamQuestActivityList
  if playerActs == nil then
    luaUtils.LogError("[ActTeamQuest] Cannot load player data List.")
    return nil
  end

  local suc, jObject = playerActs:TryGetValue(actId)
  if not suc then
    luaUtils.LogError("[ActTeamQuest] Cannot load player data.")
    return nil
  end

  local playerData = luaUtils.ConvertJObjectToLuaTable(jObject)
  if playerData == nil then
    return nil
  end 

  return playerData
end

function TeamQuestUtil.IsSearchHintChecked(activityId) 
  local cacheKey = luaUtils.Format("{0}_{1}", activityId, TeamQuestUtil.ACT_LOCAL_CACHE_NO_TEAM_HINT);
  return CS.Torappu.Activity.ActLocalCacheHandler.GetParamFromCache(cacheKey) > 0;
end

function TeamQuestUtil.SetSearchHintChecked(activityId) 
  local cacheKey = luaUtils.Format("{0}_{1}", activityId, TeamQuestUtil.ACT_LOCAL_CACHE_NO_TEAM_HINT);
  CS.Torappu.Activity.ActLocalCacheHandler.SaveParamToCache(cacheKey, 1);
end

return TeamQuestUtil