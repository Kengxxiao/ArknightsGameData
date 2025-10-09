local luaUtils = CS.Torappu.Lua.Util;
RecruitOnlyUtil = Class("RecruitOnlyUtil");



function RecruitOnlyUtil.CheckIfRecruitOnlyConsumedByActId(actId)
  if actId == nil then
    return false;
  end

  local suc, actData = CS.Torappu.ActivityDB.data.activity.recruitOnlyData:TryGetValue(actId);
  if not suc then
    return false;
  end
  if actData.recruitData == nil then
    return false;
  end

  local suc, playerActData = CS.Torappu.PlayerData.instance.data.activity.recruitOnlyList:TryGetValue(actId);
  if not suc then
    return false;
  end

  return playerActData.used >= actData.recruitData.tagTimes;
end