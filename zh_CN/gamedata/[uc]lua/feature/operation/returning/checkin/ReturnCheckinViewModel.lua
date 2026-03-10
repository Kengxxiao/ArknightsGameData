local luaUtil = CS.Torappu.Lua.Util;





local ReturnCheckinItemViewModel = Class("ReturnCheckinItemViewModel", nil)


function ReturnCheckinItemViewModel:IsKeyItem()
  if self.itemData == nil then
    return false;
  end
  return self.itemData.isKeyItem;
end


function ReturnCheckinItemViewModel:GetRewardList()
  if self.itemData == nil then
    return nil;
  end
  return self.itemData.rewardList;
end










local ReturnCheckinViewModel = Class("ReturnCheckinViewModel", nil);




function ReturnCheckinViewModel:_CalcCompleteStatus(itemIndex, checkinHistory)
  if checkinHistory == nil then
    return ReturnCheckinItemState.UNCOMPLETE;
  end

  local signCnt =  checkinHistory.Count
  if itemIndex >= signCnt then
    return ReturnCheckinItemState.UNCOMPLETE;
  end

  local status = checkinHistory[itemIndex];
  if status == 1 then
    return ReturnCheckinItemState.COMPLETE;
  else
    return ReturnCheckinItemState.CONFIRMED;
  end
end

function ReturnCheckinViewModel:LoadData()
  self.itemList = {};
  self.checkinDays = 0;
  self.allOpenDays = 0;
  self.finishTs = 0;
  self.checkinProgress = 0;
  self.fillAmount = 0;

  local playerData = ReturnModel.me:GetPlayerData();
  local gameData = ReturnModel.me:GetGameData();
  if gameData == nil or playerData == nil or 
     playerData.currentV2 == nil or playerData.currentV2.groupId == nil or
     playerData.currentV2.checkIn == nil or playerData.currentV2.checkIn.groupId == nil then
    return;
  end
  self.finishTs = playerData.currentV2.finishTs;
  local dateTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(self.finishTs);
  self.finishDateTimeText = CS.Torappu.Lua.Util.Format(CS.Torappu.StringRes.DATE_FORMAT_YYYY_MM_DD_HH_MM, 
      dateTime.Year, dateTime.Month, dateTime.Day, dateTime.Hour, dateTime.Minute);

  local returnGroupId = playerData.currentV2.groupId;
  local playerCheckin = playerData.currentV2.checkIn;
  local checkinId = playerCheckin.groupId;

  local groupDataMap = gameData.groupDataMap;
  local checkinDataMap = gameData.checkinDataMap;
  if groupDataMap == nil or checkinDataMap == nil then
    return;
  end

  local ok, returnGroupData = gameData.groupDataMap:TryGetValue(returnGroupId);
  if not ok or returnGroupData == nil then
    return;
  end
  if returnGroupData.allOpenDays ~= nil then
    self.allOpenDays = returnGroupData.allOpenDays;
  end

  local ok, checkinGroupData = checkinDataMap:TryGetValue(checkinId);
  if not ok or checkinGroupData == nil then
    return;
  end

  local checkinItemList = checkinGroupData.checkinItemList;
  if checkinItemList == nil or checkinItemList.Count <= 0 then
    return;
  end

  for index = 0, checkinItemList.Count - 1 do
    local itemModel = ReturnCheckinItemViewModel.new();
    itemModel.itemData = checkinItemList[index];
    itemModel.index = index;
    table.insert(self.itemList, itemModel);
  end
  self:RefreshItemStatus();
end

function ReturnCheckinViewModel:RefreshItemStatus()
  local playerData = ReturnModel.me:GetPlayerData();
  if playerData == nil or playerData.currentV2 == nil or playerData.currentV2.checkIn == nil or 
      playerData.currentV2.checkIn.history == nil then
    return;
  end
  local history = playerData.currentV2.checkIn.history;
  for _, itemModel in ipairs(self.itemList) do
    itemModel.state = self:_CalcCompleteStatus(itemModel.index, history);
  end
  self.checkinProgress = history.Count;
  self.checkinDays = #self.itemList;
  if(self.checkinDays > 1) then
    self.fillAmount = (self.checkinProgress - 1) / (self.checkinDays - 1);
  else
    self.fillAmount = 0;
  end
  self.titleText = CS.Torappu.Lua.Util.Format(I18NTextRes.COMMON_RETURN_SIGN_MESSAGE, 
      self.checkinDays, self.allOpenDays, self.allOpenDays);
end


return ReturnCheckinViewModel;