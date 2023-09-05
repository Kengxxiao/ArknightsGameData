local luaUtils = CS.Torappu.Lua.Util;









local UniqueOnlyItemCardViewModel = Class("UniqueOnlyItemCardViewModel")

function UniqueOnlyItemCardViewModel:ctor() 
  self.rewardItem = nil
  self.itemId = nil
  self.itemType = nil
  self.needStorageCheck = false
  self.hasItemGot = false
  self.useItemNameIcon = false
  self.itemNameIconId = nil
end






local UniqueOnlyViewModel = Class("UniqueOnlyViewModel")

function UniqueOnlyViewModel:ctor()
  self.actId = nil
  self.itemList = {}
  self.canClaimReward = false
  self.endTime = 0
end

function UniqueOnlyViewModel:LoadData(actId)
  if actId == nil then
    return
  end
  self.actId = actId

  local suc, basicData = CS.Torappu.ActivityDB.data.basicInfo:TryGetValue(self.actId);
  if not suc then
    return;
  end

  local suc, jObject = CS.Torappu.ActivityDB.data.dynActs:TryGetValue(self.actId);
  if not suc then
    return;
  end
  local actData = luaUtils.ConvertJObjectToLuaTable(jObject)

  self.endTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(basicData.endTime);
  local luaItemList = actData.itemList;
  for luaIndex = 1, #luaItemList do
    local itemModel = UniqueOnlyItemCardViewModel.new();
    local jsonItemModel = luaItemList[luaIndex];
    local jsonRewardItemModel = jsonItemModel.rewardItem;

    if jsonRewardItemModel ~= nil then
      itemModel.itemId = jsonRewardItemModel.id;
      itemModel.itemType = CS.Torappu.ItemType.__CastFrom(jsonRewardItemModel.type);
      local itemCount = jsonRewardItemModel.count;
      itemModel.rewardItem = CS.Torappu.ItemBundle(itemModel.itemId, itemModel.itemType, itemCount);
      itemModel.needStorageCheck = jsonItemModel.needStorageCheck;
      itemModel.useItemNameIcon = jsonItemModel.useItemNameIcon;
      itemModel.itemNameIconId = jsonItemModel.itemNameIconId;

      table.insert(self.itemList, itemModel);
    end
  end
end

function UniqueOnlyViewModel:RefreshData()
  self.canClaimReward = UniqueOnlyUtil.CheckIfHaveRewardCanClaimByActId(self.actId);

  for idx = 1, #self.itemList do
    local itemModel = self.itemList[idx];
    if itemModel.needStorageCheck then
      local haveItem = UniqueOnlyUtil.CheckIfHaveItem(itemModel.itemId, itemModel.itemType);
      itemModel.hasItemGot = haveItem;
    else 
      
      itemModel.hasItemGot = false;
    end
  end
end

return UniqueOnlyViewModel