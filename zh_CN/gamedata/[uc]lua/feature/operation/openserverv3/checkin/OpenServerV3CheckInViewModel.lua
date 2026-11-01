local luaUtil = CS.Torappu.Lua.Util;






local OpenServerV3CheckInItemViewModel = Class("OpenServerV3CheckInItemViewModel");












local OpenServerV3CheckInViewModel = Class("OpenServerV3CheckInViewModel");





function OpenServerV3CheckInViewModel:_CalcCompleteStatus(itemIndex, checkInHistory)
  if checkInHistory == nil then
    return OpenServerV3CheckInItemState.UNCOMPLETE;
  end

  local signCnt = checkInHistory.Count;
  if itemIndex >= signCnt then
    return OpenServerV3CheckInItemState.UNCOMPLETE;
  end

  local status = checkInHistory[itemIndex];
  if status == 1 then
    return OpenServerV3CheckInItemState.COMPLETE;
  else
    return OpenServerV3CheckInItemState.CONFIRMED;
  end
end



function OpenServerV3CheckInViewModel:_RefreshSpecialRewardState(checkInHistory)
  if self.m_specialRewardDay == nil or self.m_specialRewardDay <= 0 then
    self.specialRewardState = OpenServerV3CheckInSpecialRewardState.UNOWNED;
    return;
  end

  if checkInHistory == nil or checkInHistory.Count < self.m_specialRewardDay or
      checkInHistory[self.m_specialRewardDay - 1] > 0 then
    self.specialRewardState = OpenServerV3CheckInSpecialRewardState.UNOWNED;
    return;
  end

  if self.specialReward == nil or self.specialReward.itemId == nil then
    self.specialRewardState = OpenServerV3CheckInSpecialRewardState.USED;
    return;
  end

  local itemCount = CS.Torappu.UI.ItemUtil.CurrentCount(self.specialReward.itemId, self.specialReward.type);
  if itemCount > 0 then
    self.specialRewardState = OpenServerV3CheckInSpecialRewardState.OWNED;
  else
    self.specialRewardState = OpenServerV3CheckInSpecialRewardState.USED;
  end
end

function OpenServerV3CheckInViewModel:LoadData()
  self.itemList = {};
  self.charImgId = "";
  self.textTitle = "";
  self.textDesc = "";
  self.specialRewardState = OpenServerV3CheckInSpecialRewardState.UNOWNED;
  self.specialRewardDesc = "";
  self.charIdList = {};
  self.specialReward = nil;
  self.sequenceNum = 0;
  self.m_specialRewardDay = 0;

  local playerData = OpenServerV3Model.me:GetPlayerData();
  local gameData = OpenServerV3Model.me:GetGameData();
  if playerData == nil or playerData.checkIn == nil or playerData.checkIn.groupId == nil or
      playerData.checkIn.groupId == "" then
    return;
  end
  if gameData == nil or gameData.checkInData == nil then
    return;
  end

  local ok, checkInGroupData = gameData.checkInData:TryGetValue(playerData.checkIn.groupId);
  if not ok or checkInGroupData == nil then
    return;
  end

  self.charImgId = checkInGroupData.charImgId or "";
  self.textTitle = checkInGroupData.loginTitle or "";
  self.textDesc = checkInGroupData.loginDesc or "";
  if checkInGroupData.specialRewardItem ~= nil then
    self.specialReward = luaUtil.LoadItemFromItemBundle(checkInGroupData.specialRewardItem);
  end
  self.m_specialRewardDay = checkInGroupData.specialRewardDay or 0;
  self.specialRewardDesc = luaUtil.Format(
      I18NTextRes.COMMON_OPEN_SERVER_V3_CHECKIN_CONDITION,
      checkInGroupData.specialRewardDay);

  local charList = checkInGroupData.charList;
  if charList ~= nil then
    for index = 0, charList.Count - 1 do
      table.insert(self.charIdList, charList[index]);
    end
  end

  local checkInItemList = checkInGroupData.checkInItemList;
  if checkInItemList == nil or checkInItemList.Count <= 0 then
    self:RefreshPlayerData();
    return;
  end

  for index = 0, checkInItemList.Count - 1 do
    local itemData = checkInItemList[index];
    local itemModel = OpenServerV3CheckInItemViewModel.new();
    itemModel.index = index;
    itemModel.isKeyItem = itemData.isKeyItem;
    itemModel.rewardList = itemData.rewardList;
    table.insert(self.itemList, itemModel);
  end
  self:RefreshPlayerData();
end

function OpenServerV3CheckInViewModel:RefreshPlayerData()
  local playerData = OpenServerV3Model.me:GetPlayerData();
  if playerData == nil or playerData.checkIn == nil then
    return;
  end
  local history = playerData.checkIn.history;
  for _, itemModel in ipairs(self.itemList) do
    itemModel.state = self:_CalcCompleteStatus(itemModel.index, history);
  end
  self:_RefreshSpecialRewardState(history);
end


function OpenServerV3CheckInViewModel:GetFocusIndex()
  if self.itemList == nil or #self.itemList <= 0 then
    return 0;
  end
  for index, itemModel in ipairs(self.itemList) do
    if itemModel.state ~= OpenServerV3CheckInItemState.CONFIRMED then
      return index;
    end
  end
  return #self.itemList;
end

return OpenServerV3CheckInViewModel;
