local luaUtils = CS.Torappu.Lua.Util;









local BlessOnlyBlessItemModel = Class("BlessOnlyBlessItemModel");

function BlessOnlyBlessItemModel:LoadData(fesCharId, actGameData)
  if actGameData == nil then
    return;
  end

  self.fesCharId = fesCharId;
  local charInfo = actGameData.festivalCharInfos[fesCharId];
  if charInfo == nil then 
    return;
  end

  self.charId = charInfo.charId;
  self.charSkinId = charInfo.charSkinId;
  self.charName = charInfo.charName;
  self.charBlessing = charInfo.charBlessing;
  self.sortId = charInfo.sortId;
  
  local suc, charSkinData = CS.Torappu.SkinDB.instance:TryGetCharSkin(self.charSkinId);
  if not suc then 
    self.charAvatarId = self.charId;
  else 
    self.charAvatarId = charSkinData:GetAvatarId();
  end
end






local BlessOnlyCheckInModel = Class("BlessOnlyCheckInModel");


function BlessOnlyCheckInModel:LoadData(checkInInfo)
  self.order = checkInInfo.order;
  self.keyItem = checkInInfo.keyItem;
  self.checkInState = BlessOnlyCheckInState.DISABLE;
  self.rewardList = {};
  for luaIndex = 1, #checkInInfo.itemList do
    local reward = checkInInfo.itemList[luaIndex];
    local viewModel = CS.Torappu.UI.UIItemViewModel();
    viewModel:LoadGameData(reward.id, reward.type);
    viewModel.itemCount = reward.count;
    table.insert(self.rewardList, viewModel);
  end
end


function BlessOnlyCheckInModel:UpdateData(state)
  self.checkInState = state;
end



















local BlessOnlyPacketModel = Class("BlessOnlyPacketModel");


function BlessOnlyPacketModel:LoadData(festivalInfo, actGameData)
  self.order = festivalInfo.order;
  self.festivalId = festivalInfo.festivalId;
  self.festivalTitle = festivalInfo.festivalTitle;
  self.absoluteTime = festivalInfo.absoluteTime;
  self.relativeDate = festivalInfo.relativeDate;
  self.fesTitleText = festivalInfo.fesTitleText;
  self.diamondRewardCnt = festivalInfo.rewardCnt;
  self.adTips = festivalInfo.adTips;
  
  self.blessingGroup = festivalInfo.fesBlessingGroup;

  self.curIndex = 1;
  self.defaultFesCharId = "";
  self.defaultFesCharAvatarId = "";
  self.defaultFesCharIndex = 0;
  self.curBlessItemModel = nil;
  self.checkInState = BlessOnlyCheckInState.DISABLE;

  local charList = festivalInfo.charList;

  self.blessItemList = {};
  for luaI = 1, #charList do
    local blessItem = BlessOnlyBlessItemModel.new();
    local fesCharId = charList[luaI];
    blessItem:LoadData(fesCharId, actGameData);
    table.insert(self.blessItemList, blessItem);
  end

  table.sort(self.blessItemList, function(a, b)
    return a.sortId < b.sortId;
  end)   

end




function BlessOnlyPacketModel:UpdateState(state, fesCharId, checkInDay)
  self.checkInState = state;

  self.isOverTime = luaUtils.GetCurrentTs() > self.absoluteTime;
  local restDayCnt = self.relativeDate - checkInDay;
  if restDayCnt > 1 then
    self.overTimeTips = luaUtils.Format(StringRes.BLESSONLY_REST_DAY_RECEIVE, restDayCnt);
  elseif restDayCnt == 1 then
    self.overTimeTips = StringRes.BLESSONLY_TOMORROW_RECEIVE;
  end

  if string.isNullOrEmpty(fesCharId) then
    self.defaultFesCharId = "";
    self.defaultFesCharAvatarId = "";
    self.defaultFesCharIndex = 0;
  else
    self.defaultFesCharId = fesCharId;
    
    for luaIndex = 1, #self.blessItemList do
      local blessItem = self.blessItemList[luaIndex];
      if blessItem.fesCharId == self.defaultFesCharId then
        self.defaultFesCharIndex = luaIndex;
        self.defaultFesCharAvatarId = blessItem.charAvatarId;
      end
    end
  end
end


function BlessOnlyPacketModel:CheckToDefaultChar()
  for luaIndex = 1, #self.blessItemList do
    local blessItem = self.blessItemList[luaIndex];
    if blessItem.fesCharId == self.defaultFesCharId then
      self.defaultFesCharIndex = luaIndex;
      self.curIndex = luaIndex;
      self.curBlessItemModel = blessItem;
    end
  end
end

function BlessOnlyPacketModel:MoveLeft()
  local index = self.curIndex - 1;
  if index < 1 then 
    index = #self.blessItemList;
  end
  self.curIndex = index;
  self.curBlessItemModel = self.blessItemList[index];
end

function BlessOnlyPacketModel:MoveRight()
  local index = self.curIndex + 1;
  if index > #self.blessItemList then 
    index = 1;
  end
  self.curIndex = index;
  self.curBlessItemModel = self.blessItemList[index];
end


function BlessOnlyPacketModel:CheckIsCurDay()
  local nextTimeStamp = luaUtils.ToTimeStamp(luaUtils.ToDateTime(self.absoluteTime):AddDays(1));
  local nowTimeStamp = luaUtils.GetCurrentTs();
  return nowTimeStamp > self.absoluteTime and nowTimeStamp < nextTimeStamp;
end
























local BlessOnlyViewModel = Class("BlessOnlyViewModel", UIViewModel);


function BlessOnlyViewModel:LoadData(actId)
  self.m_actId = actId;

  self.checkInItemList = {};
  self.m_packetList = {};
  self.isContinueOpenPacket = false;
  self.isBlessListState = false;
  self.blessListState = BlessOnlyBlessListState.HORIZONTAL;
  
  self.shareMissionId = CS.Torappu.UI.CrossAppShare.CrossAppShareUtil.LoadCrossAppShareMissionId(self.m_actId);

  local suc, basicData = CS.Torappu.ActivityDB.data.basicInfo:TryGetValue(self.m_actId)
  if suc then 
    local actEndDateTime = luaUtils.ToDateTime(basicData.endTime);
    local actEndTime = luaUtils.Format(CS.Torappu.StringRes.DATE_FORMAT_YYYY_MM_DD_HH_MM,
        actEndDateTime.Year, actEndDateTime.Month, actEndDateTime.Day, actEndDateTime.Hour, actEndDateTime.Minute);
    self.actEndTimeDesc = CS.Torappu.Lua.Util.Format(StringRes.BLESSONLY_ACT_END_DATE, actEndTime);
  end

  local actGameData = BlessOnlyUtil.LoadGameData(self.m_actId);
  if actGameData == nil then
    return;
  end

  
  local status = CS.Torappu.PlayerData.instance.data.status;
  self.playerName = status.nickName;
  self.playerNameId = status.nickNumber;
  self.playerLevel = status.level;
  self.playerId = CS.U8.SDK.U8SDKInterface.Instance.uid;
  self.avatarInfo = status.avatar;

  
  local apSupplyDict = actGameData.apSupplyOutOfDateDict;
  if apSupplyDict then
    for apid, endtime in pairs(apSupplyDict) do
      local apItemData = CS.Torappu.UI.UIItemViewModel();
      apItemData:LoadGameData(apid, CS.Torappu.ItemType.NONE);
      local dateTime = luaUtils.ToDateTime(endtime);
      local timedesc = CS.Torappu.Lua.Util.Format(CS.Torappu.StringRes.DATE_FORMAT_YYYY_MM_DD_HH_MM,
          dateTime.Year, dateTime.Month, dateTime.Day, dateTime.Hour, dateTime.Minute);
      local strFormat = StringRes.ACTIVITY_3D5_APTIME_DESC;
      self.apSupplyEndTimeDesc = CS.Torappu.Lua.Util.Format(strFormat, apItemData.name, timedesc);
      break;
    end
  end

  
  local checkInInfoList = actGameData.checkInInfos;
  if checkInInfoList ~= nil then
    for checkInIndex, checkIninfo in pairs(checkInInfoList) do
      local checkInModel = BlessOnlyCheckInModel.new();
      checkInModel:LoadData(checkIninfo);
      table.insert(self.checkInItemList, checkInModel);
    end
    table.sort(self.checkInItemList, function(a, b)
      return a.order < b.order;
    end);
  end

  
  local festivalInfoList = actGameData.festivalInfoList;
  if festivalInfoList ~= nil then
    for luaIndex = 1, #festivalInfoList do
      local festivalInfo = festivalInfoList[luaIndex];
      local packetModel = BlessOnlyPacketModel.new();
      packetModel:LoadData(festivalInfo, actGameData);
      table.insert(self.m_packetList, packetModel);
    end
    table.sort(self.m_packetList, function(a,b)
      return a.order < b.order;
    end)
  end

  self:UpdateData();
  
  self:_SetDefaultPanelState();
end

function BlessOnlyViewModel:UpdateData()
  local playerData = BlessOnlyUtil.LoadPlayerData(self.m_actId);
  if playerData == nil then
    return;
  end

  local checkInHistory = playerData.history;
  if checkInHistory == nil then
    return;
  end

  for csIndex = 0, checkInHistory.Count - 1 do 
    local checkInState = checkInHistory[csIndex];
    local checkInModel = self.checkInItemList[csIndex + 1];
    if checkInModel ~= nil then
      checkInModel:UpdateData(checkInState);
    end
  end

  local packetHistory = playerData.festivalHistory;
  if packetHistory == nil then
    return;
  end
  
  for csIndex = 0, packetHistory.Count - 1 do
    local packetItem = packetHistory[csIndex];
    if packetItem ~= nil then
      local packetModel = self.m_packetList[csIndex + 1];
      if packetModel ~= nil then
        packetModel:UpdateState(packetItem.state, packetItem.charId, checkInHistory.Count);
      end
    end
  end
end

function BlessOnlyViewModel:_SetDefaultPanelState()
  if self:_CheckHasNoPacketToOpen() then
    self.playHomeEntryAnim = true;
    self.panelState = BlessOnlyPanelState.HOME;
    self.openFestivalId = "";
    self.openFestivalOrder = 0;
    self.openPacketModel = nil;
  else
    self.panelState = BlessOnlyPanelState.PACKET;
    self.openFestivalId = self.highPriorityFestivalId;
    self.openFestivalOrder = self.highPriorityFestivalOrder;
    self.openPacketModel = self.m_packetList[self.highPriorityFestivalOrder];
  end
end

function BlessOnlyViewModel:_CheckHasNoPacketToOpen()
  self:_SetHighPriorityFestivalId();
  return string.isNullOrEmpty(self.highPriorityFestivalId);
end

function BlessOnlyViewModel:_SetHighPriorityFestivalId()
  if self.m_packetList == nil then
    return
  end

  
  for luaI = 1, #self.m_packetList do
    local packetModel = self.m_packetList[luaI];
    if packetModel ~= nil then 
      if packetModel:CheckIsCurDay() and packetModel.checkInState == BlessOnlyCheckInState.AVAIL then
        self.highPriorityFestivalId = packetModel.festivalId;
        self.highPriorityFestivalOrder = packetModel.order;
        return;
      end  
    end
  end

  
  for luaI = 1, #self.m_packetList do 
    local packetModel = self.m_packetList[luaI];
    if packetModel ~= nil then
      if packetModel.checkInState == BlessOnlyCheckInState.AVAIL then
        self.highPriorityFestivalId = packetModel.festivalId;
        self.highPriorityFestivalOrder = packetModel.order;
        return;  
      end
    end
  end

  self.highPriorityFestivalId = "";
  self.highPriorityFestivalOrder = 0;
end

function BlessOnlyViewModel:_ReturnToHomeState()
  self.openFestivalId = "";
  self.openPacketModel = nil;
  self.openFestivalOrder = 0;
  self.panelState = BlessOnlyPanelState.HOME;
  self.isContinueOpenPacket = false;
  self:UpdateData();
end


function BlessOnlyViewModel:GetReceivedPacketCnt()
  local resCnt = 0;
  for luaI = 1, #self.m_packetList do
    local packetModel = self.m_packetList[luaI];
    if packetModel ~= nil and packetModel.checkInState == BlessOnlyCheckInState.RECEIVED then
      resCnt = resCnt + 1;
    end
  end
  return resCnt;
end


function BlessOnlyViewModel:GetFirstAvailCheckInIndex()
  for luaI = 1, #self.checkInItemList do
    local checkInItem = self.checkInItemList[luaI];
    if checkInItem.checkInState == BlessOnlyCheckInState.AVAIL then
      return luaI - 1;
    end
  end 
  return 0;
end


function BlessOnlyViewModel:CheckIsAllPacketReceived()
  local receivedCnt = self:GetReceivedPacketCnt();
  return receivedCnt == #self.m_packetList;
end



function BlessOnlyViewModel:GetPacketByOrder(order)
  return self.m_packetList[order];
end


function BlessOnlyViewModel:GetPacketCnt()
  return #self.m_packetList;
end


function BlessOnlyViewModel:GetActId()
  return self.m_actId;
end

function BlessOnlyViewModel:CloseBlessList()
  if self.openPacketModel ~= nil then
    self.isBlessListState = false;
    self.openPacketModel.curIndex = 0;
  end
  if self.m_isFromHomeToBlessList then
    self.playHomeEntryAnim = false;
    self:_ReturnToHomeState();
  else
    self:_SetDefaultPanelState();
    self.isContinueOpenPacket = self.panelState == BlessOnlyPanelState.PACKET;
  end
end

function BlessOnlyViewModel:MoveBlessListLeft()
  if not(self.isBlessListState) or self.openPacketModel == nil then 
    return
  end
  self.openPacketModel:MoveLeft();
end 

function BlessOnlyViewModel:MoveBlessListRight()
  if not(self.isBlessListState) or self.openPacketModel == nil then 
    return
  end
  self.openPacketModel:MoveRight();
end

function BlessOnlyViewModel:SwitchBlessListHorOrVerType() 
  if self.blessListState == BlessOnlyBlessListState.HORIZONTAL then
    self.blessListState = BlessOnlyBlessListState.VERTICAL
  else 
    if self.blessListState == BlessOnlyBlessListState.VERTICAL then
      self.blessListState = BlessOnlyBlessListState.HORIZONTAL
    end
  end
end


function BlessOnlyViewModel:SwitchToReceivePacketState(fesOrder)
  if self.m_packetList == nil then
    return;
  end
  local packetModel = self.m_packetList[fesOrder];
  if packetModel == nil or packetModel.checkInState ~= BlessOnlyCheckInState.AVAIL then
    return;
  end
  
  self.openFestivalId = packetModel.festivalId;
  self.openPacketModel = packetModel;
  self.openFestivalOrder = packetModel.order;
  self.panelState = BlessOnlyPanelState.PACKET;
end


function BlessOnlyViewModel:SwitchToCheckBlessListState(fesOrder)
  if self.m_packetList == nil then
    return;
  end
  local packetModel = self.m_packetList[fesOrder];
  if packetModel == nil or packetModel.checkInState ~= BlessOnlyCheckInState.RECEIVED then
    return;
  end

  self.blessListState = BlessOnlyBlessListState.HORIZONTAL;
  self.openFestivalId = packetModel.festivalId;
  self.openPacketModel = packetModel;
  self.openFestivalOrder = packetModel.order;
  self:SwitchToOpenPacketBlessList(true);
end


function BlessOnlyViewModel:SwitchToOpenPacketBlessList(isFromHomeToBlessList)
  local playerData = BlessOnlyUtil.LoadPlayerData(self.m_actId);
  if playerData == nil then
    return;
  end

  local packetHistory = playerData.festivalHistory;
  if packetHistory == nil then
    return;
  end

  
  local playerPacketData = packetHistory[self.openFestivalOrder - 1];
  if playerPacketData == nil then
    return;
  end

  local checkInCnt = 0;
  if playerData.history ~= nil then
    checkInCnt = playerData.history.Count;
  end

  self.openPacketModel:UpdateState(playerPacketData.state, playerPacketData.charId, checkInCnt);
  self.openPacketModel:CheckToDefaultChar();
  self.isBlessListState = true;
  self.m_isFromHomeToBlessList = isFromHomeToBlessList;
end

function BlessOnlyViewModel:SwitchToBlessCollectionState()
  if self:CheckIsAllPacketReceived() then
    self.panelState = BlessOnlyPanelState.BLESS_COLLECTION;
  end
end

function BlessOnlyViewModel:ReturnToHomeStateFromPacket()
  self.playHomeEntryAnim = true;
  self:_ReturnToHomeState();
end


function BlessOnlyViewModel:CloseBlessCollection()
  self.playHomeEntryAnim = false;
  self.panelState = BlessOnlyPanelState.HOME;
end

return BlessOnlyViewModel;