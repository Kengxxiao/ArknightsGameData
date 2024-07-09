local luaUtils = CS.Torappu.Lua.Util;

UniqueOnlyUtil = Class("UniqueOnlyUtil");



function UniqueOnlyUtil.CheckIfHaveRewardCanClaimByActId(actId)
  if actId == nil then
    return false;
  end

  
  local suc, playerActData = CS.Torappu.PlayerData.instance.data.activity.uniqueOnlyList:TryGetValue(actId);
  if not suc or playerActData.reward == 0 then
    return false;
  end

  local suc, jObject = CS.Torappu.ActivityDB.data.dynActs:TryGetValue(actId);
  if not suc then
    return false;
  end
  local actData = luaUtils.ConvertJObjectToLuaTable(jObject)
  local luaItemList = actData.itemList;
  for luaIndex = 1, #luaItemList do
    local jsonItemModel = luaItemList[luaIndex];
    local jsonRewardItemModel = jsonItemModel.rewardItem;

    if jsonRewardItemModel ~= nil then
      local itemId = jsonRewardItemModel.id;
      local itemType = CS.Torappu.ItemType.__CastFrom(jsonRewardItemModel.type);
      if not jsonItemModel.needStorageCheck or not UniqueOnlyUtil.CheckIfHaveItem(itemId, itemType) then
        return true;
      end
    end
  end

  return false;
end



function UniqueOnlyUtil.CheckIfHaveRewardClaimedByActId(actId)
  if actId == nil then
    return false;
  end
  local suc, playerActData = CS.Torappu.PlayerData.instance.data.activity.uniqueOnlyList:TryGetValue(actId);
  if not suc then
    return false;
  end
  return playerActData.reward == 0;
end




function UniqueOnlyUtil.CheckIfHaveItem(itemId, itemType)
  if itemId == nil or itemType == nil then
    return false
  end
  return CS.Torappu.UI.ItemUtil.CurrentCount(itemId, itemType) > 0;
end


function UniqueOnlyUtil.SetUniqueOnlyActClicked(actId)
  CS.Torappu.LocalTrackStore.instance:ConsumeTrack(
      CS.Torappu.LocalTrackTypes.UNIQUE_ONLY_TRACK, actId);
end



function UniqueOnlyUtil.GetUniqueOnlyActClicked(actId)
  return not CS.Torappu.LocalTrackStore.instance:CheckTrack(
      CS.Torappu.LocalTrackTypes.UNIQUE_ONLY_TRACK, actId);
end