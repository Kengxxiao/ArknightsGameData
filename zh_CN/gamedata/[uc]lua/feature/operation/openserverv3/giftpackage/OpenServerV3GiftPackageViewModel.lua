local luaUtils = CS.Torappu.Lua.Util;





local OpenServerV3GiftPackageItemViewModel = Class("OpenServerV3GiftPackageItemViewModel");

function OpenServerV3GiftPackageItemViewModel:ctor()
  self.goodId = "";
  self.imgId = "";
  self.sortId = 0;
  self.isLimit = false;
end


function OpenServerV3GiftPackageItemViewModel:LoadData(data)
  if data == nil then
    return;
  end
  self.goodId = data.goodId;
  self.imgId = data.giftPackagePic;
  self.sortId = data.sortId;
  self.isLimit = data.isLimit;
end



local OpenServerV3GiftPackageViewModel = Class("OpenServerV3GiftPackageViewModel");

function OpenServerV3GiftPackageViewModel:LoadData()
  self.itemList = {};
end

function OpenServerV3GiftPackageViewModel:RefreshPlayerData()
  self.itemList = {};
  local gameData = OpenServerV3Model.me:GetGameData();
  if gameData == nil or gameData.giftPackageList == nil then
    return;
  end
  for index = 0, gameData.giftPackageList.Count - 1 do
    local data = gameData.giftPackageList[index];
    if data ~= nil and luaUtils.CheckIfGiftPackageAvailable(data.goodId) then
      local itemModel = OpenServerV3GiftPackageItemViewModel.new();
      itemModel:LoadData(data);
      table.insert(self.itemList, itemModel);
    end
  end

  table.sort(self.itemList, function(left, right)
    if left.sortId ~= right.sortId then
      return left.sortId < right.sortId;
    else
      return left.goodId < right.goodId;
    end
  end);
end

return OpenServerV3GiftPackageViewModel;