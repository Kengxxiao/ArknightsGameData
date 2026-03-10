local luaUtil = CS.Torappu.Lua.Util;




local ReturnPackagePicItemViewModel = Class("ReturnPackagePicItemViewModel");

function ReturnPackagePicItemViewModel:ctor()
  self.giftPackageId = "";
  self.giftPackagePic = "";
  self.sortId = 0;
end


function ReturnPackagePicItemViewModel:LoadData(giftPackagePicData)
  if giftPackagePicData == nil then
    return;
  end
  self.giftPackageId = giftPackagePicData.giftPackageId;
  self.giftPackagePic = giftPackagePicData.giftPackagePic;
  self.sortId = giftPackagePicData.sortId;
end



local ReturnPackageViewModel = Class("ReturnPackageViewModel");

function ReturnPackageViewModel:LoadData()
  self.giftPackagePicItemList = {};
end


function ReturnPackageViewModel:RefreshPlayerData(playerData)
  self.giftPackagePicItemList = {};
  if playerData == nil or playerData.currentV2 == nil then
    return;
  end
  local gameData = ReturnModel.me:GetGameData();
  local groupId = playerData.currentV2.groupId;
  if groupId == nil or groupId == "" then
    return;
  end
  local isVaild, groupData = gameData.groupDataMap:TryGetValue(groupId);
  if not isVaild then
    return;
  end
  local normalGiftList = groupData.giftPackageIdList;
  if normalGiftList ~= nil then
    for idx = 1, normalGiftList.Count do
      local canBuy = self:_CheckOnceGiftPackageAbleBuy(normalGiftList[idx - 1], playerData);
      local picIsValid, picData = gameData.giftPackagePicDataMap:TryGetValue(normalGiftList[idx - 1]);
      if canBuy and picIsValid then
        local picItemViewModel = ReturnPackagePicItemViewModel.new();
        picItemViewModel:LoadData(picData);
        table.insert(self.giftPackagePicItemList, picItemViewModel);
      end
    end
  end

  local checkInGroupId = groupData.checkinGpId;
  if checkInGroupId ~= nil then
    local checkRewardIsValid, CheckRewardData = gameData.checkinGpData:TryGetValue(checkInGroupId);
    if checkRewardIsValid then
      local checkInGpId = CheckRewardData.bindGPGoodId;
      if checkInGpId and checkInGpId ~= "" then
        local canBuy = self:_CheckLoginGiftPackageAblyBuy(playerData);
        local picIsValid, picData = gameData.giftPackagePicDataMap:TryGetValue(checkInGpId);
        if canBuy and picIsValid then
          local picItemViewModel = ReturnPackagePicItemViewModel.new();
          picItemViewModel:LoadData(picData);
          table.insert(self.giftPackagePicItemList, picItemViewModel);
        end
      end
    end
  end
  
  table.sort(self.giftPackagePicItemList,function(viewModelA, viewModelB)
    return viewModelA.sortId < viewModelB.sortId;
  end)
end

function ReturnPackageViewModel:CheckGroupGiftPackageAbleBuy()
  return #self.giftPackagePicItemList > 0;
end



function ReturnPackageViewModel:_CheckOnceGiftPackageAbleBuy(giftPackageId, playerData)
  if giftPackageId == nil or giftPackageId == "" or playerData == nil then
    return false;
  end
  local isVaild, gpRecord = playerData.currentV2.backGiftPack.packs:TryGetValue(giftPackageId);
  if not isVaild then
    return false;
  end 
  local currentTime = CS.Torappu.DateTimeUtil.timeStampNow;
  return currentTime <= gpRecord.saleEndAt and gpRecord.boughtCount == 0;
end



function ReturnPackageViewModel:_CheckLoginGiftPackageAblyBuy(playerData)
  if playerData == nil then
    return false;
  end
  local currentTime = CS.Torappu.DateTimeUtil.timeStampNow;
  return playerData.currentV2.loginPack ~= nil
      and currentTime <= playerData.currentV2.loginPack.gpSaleEndAt
      and not playerData.currentV2.loginPack.hasBought;
end

return ReturnPackageViewModel;