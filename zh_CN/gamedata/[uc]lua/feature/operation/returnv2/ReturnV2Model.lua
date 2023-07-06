




ReturnV2Model = ModelMgr.DefineModel("ReturnV2Model")

local CLICKED_ALL_OPEN_TAB_FLAG  = "ReturnV2AllOpen";
local PLAYER_RETURN_POP_TIME_KEY = "ReturnV2PopTime";

function ReturnV2Model:OnInit()
  self.m_clickedOpenTab = nil;
  self.m_clickedMissionGroup = {}
end


function ReturnV2Model:IsReturnV2Show(playerData)
  if playerData == nil then
    return false;
  end
  if not playerData.open or ReturnModel.me:GetReturnVersion() then
    return false;
  end
  return not self:_IsTimeOut(playerData) or self:_CheckIfFullOpen(playerData);
end


function ReturnV2Model:_IsTimeOut(playerData)
  if playerData == nil then
    return false;
  end
  local currentData = playerData.currentV2;
  if currentData == nil then
    return false;
  end
  local endTime = currentData.finishTs;
  local curTs = CS.Torappu.DateTimeUtil.timeStampNow;
  return curTs > endTime;
end


function ReturnV2Model:_CheckIfFullOpen(playerData)
  if playerData == nil then
    return false;
  end
  local currentData = playerData.currentV2;
  if currentData == nil then
    return false;
  end
  local fullOpenData = currentData.fullOpen;
  if fullOpenData == nil then
    return false;
  end
  return fullOpenData.today or fullOpenData.remain > 0;
end


function ReturnV2Model:CheckIfOnlyWeeklyOpen(playerData)
  return self:_CheckIfFullOpen(playerData) and self:_IsTimeOut(playerData);
end



function ReturnV2Model:_GetCheckinListCount(groupId)
  if groupId == nil or groupId == "" then
    return 0;
  end
  local returnV2GameData = CS.Torappu.OpenServerDB.returnV2Data;
  if returnV2GameData == nil then
    return 0;
  end
  local checkinGameData = returnV2GameData.checkInRewardData;
  if checkinGameData == nil then
    return 0;
  end
  for index, data in pairs(checkinGameData) do
    if data ~= nil and data.groupId == groupId and data.rewardList ~= nil then
      return data.rewardList.Count;
    end
  end
  return 0;
end

function ReturnV2Model:CheckIfPopupReturnPage()
  
  if self:HasOnceReward() then
    self.m_updatePopTime = true;
    return true;
  end

  
  local prePopTime = nil;
  local popupStamp = CS.Torappu.PlayerPrefsWrapper.GetUserInt(PLAYER_RETURN_POP_TIME_KEY, 0);
  if popupStamp ~= nil and popupStamp ~= 0 then
    prePopTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(popupStamp);
  end

  local current = CS.Torappu.DateTimeUtil.currentTime;
  if prePopTime and CS.Torappu.DateTimeUtil.IsSameDay(prePopTime, current) then
    return false;
  end
  
  local currentData = CS.Torappu.PlayerData.instance.data.backflow;
  if not currentData then
    return false;
  end

  
  if self:_IsTimeOut(currentData) then
    return false;
  end

  self.m_updatePopTime = true;
  return true;
end

function ReturnV2Model:CheckShowTrackPoint()
  return TrackPointModel.me:UpdateNode(ReturnV2EntryTrackPoint);
end

function ReturnV2Model:SetAlreadyPopup()
  if not self.m_updatePopTime then
    return;
  end
  local popupStamp = CS.Torappu.DateTimeUtil.timeStampNow;
  CS.Torappu.PlayerPrefsWrapper.SetUserInt(PLAYER_RETURN_POP_TIME_KEY, popupStamp);
end



function ReturnV2Model:GetReturnV2MissionPlayerData(missionGroupId)
  local currentData = CS.Torappu.PlayerData.instance.data.backflow.currentV2
  if currentData == nil or currentData.mission == nil or missionGroupId == nil then
    return nil
  end

  local suc, outMissionData = currentData.mission.missionDict:TryGetValue(missionGroupId)
  if suc then
    return outMissionData
  end
  return nil
end


function ReturnV2Model:GetReturnV2MissionDBData()
  return ToLuaArray(CS.Torappu.OpenServerDB.returnV2Data.missionGroupData)
end


function ReturnV2Model:HasOnceRewardGot()
  return self:GetOnceRewardStatus() == ReturnV2OnceRewardStatus.GOT
end


function ReturnV2Model:GetOnceRewardItemList()
  local currentData = CS.Torappu.PlayerData.instance.data.backflow.currentV2
  if currentData == nil then
    return nil
  end
  local systemStartTime = currentData.start
  local onceRewardList = CS.Torappu.OpenServerDB.returnV2Data.onceRewardData
  for i, onceRewardGroupItem in pairs(onceRewardList) do
    local endTime = onceRewardGroupItem.endTime
    local startTime = onceRewardGroupItem.startTime
    if systemStartTime <= endTime and startTime <= systemStartTime then
      return onceRewardGroupItem.rewardList
    end
  end
end


function ReturnV2Model:GetOnceRewardStatus()
  local playerData = CS.Torappu.PlayerData.instance.data.backflow;
  if playerData == nil then
    return ReturnV2OnceRewardStatus.ERROR;
  end
  local currentData = playerData.currentV2;
  if not currentData then
    return ReturnV2OnceRewardStatus.ERROR;
  end
  if currentData.hasOnceRewardGot then
    return ReturnV2OnceRewardStatus.GOT;
  end

  if self:_IsTimeOut(playerData) then
    return ReturnV2OnceRewardStatus.TIME_OUT;
  end

  return ReturnV2OnceRewardStatus.READY;
end

function ReturnV2Model:HasOnceReward()
  return self:GetOnceRewardStatus() == ReturnV2OnceRewardStatus.READY;
end

function ReturnV2Model:GetPriceRewardGroup()
  local currentData = CS.Torappu.PlayerData.instance.data.backflow.currentV2
  if currentData == nil then
    return nil
  end
  local systemStartTime = currentData.start
  local priceRewardList = CS.Torappu.OpenServerDB.returnV2Data.priceRewardData
  for idx = 1, priceRewardList.Count do
    local csIdx = idx - 1
    local priceRewardGroup = priceRewardList[csIdx]
    if priceRewardGroup.startTime <= systemStartTime and systemStartTime <= priceRewardGroup.endTime then
      return priceRewardGroup
    end
  end
  return nil
end


function ReturnV2Model:GetSystemEndTime()
  local currentData = CS.Torappu.PlayerData.instance.data.backflow.currentV2
  if not currentData then
    return nil
  end
  return currentData.finishTs;
end


function ReturnV2Model:GetPricePoint()
  local currentData = CS.Torappu.PlayerData.instance.data.backflow.currentV2
  if not currentData then
    return 0
  end

  return currentData.mission.point
end


function ReturnV2Model:GetPriceRewardState()
  local currentData = CS.Torappu.PlayerData.instance.data.backflow.currentV2
  if not currentData then
    return nil
  end

  return currentData.mission.stageAward
end


function ReturnV2Model:GetDailySupplyState()
  local currentData = CS.Torappu.PlayerData.instance.data.backflow.currentV2
  if not currentData then
    return nil
  end

  return currentData.mission.dailySupply
end

function ReturnV2Model:HasClickedAllOpenTab()
  local currentData = CS.Torappu.PlayerData.instance.data.backflow.currentV2;
  if not currentData then
    return true;
  end
  if self.m_clickedOpenTab == nil then
    local userClickCache = CS.Torappu.PlayerPrefsWrapper.GetUserInt(CLICKED_ALL_OPEN_TAB_FLAG .. currentData.start, 0);
    self.m_clickedOpenTab = userClickCache == 1;
  end
  return self.m_clickedOpenTab;
end


function ReturnV2Model:SetAllOpenTabClicked(value)
  if self.m_clickedOpenTab ~= nil and self.m_clickedOpenTab == value then
    return;
  end

  local currentData = CS.Torappu.PlayerData.instance.data.backflow.currentV2;
  if not currentData then
    return;
  end
  local flag = 1;
  if value == true then
    flag = 1;
  else
    flag = 0;
  end
  CS.Torappu.PlayerPrefsWrapper.SetUserInt(CLICKED_ALL_OPEN_TAB_FLAG .. currentData.start, flag);
  self.m_clickedOpenTab = value;
end


function ReturnV2Model:GetDailySupplyGroup()
  local currentData = CS.Torappu.PlayerData.instance.data.backflow.currentV2
  if currentData == nil then
    return nil
  end
  local systemStartTime = currentData.start

  local dailySupplyList = CS.Torappu.OpenServerDB.returnV2Data.dailySupplyData
  for idx = 1, dailySupplyList.Count do
    local csIdx = idx - 1
    local dailySupplyGroup = dailySupplyList[csIdx]
    if dailySupplyGroup.startTime <= systemStartTime and systemStartTime <= dailySupplyGroup.endTime then
      return dailySupplyGroup
    end
  end
  return nil
end

function ReturnV2Model:GetDailySupplyDesc()
  return CS.Torappu.OpenServerDB.returnV2Data.constData.dailySupplyDesc
end

function ReturnV2Model:GetPriceRewardDesc()
  return CS.Torappu.OpenServerDB.returnV2Data.constData.returnPriceDesc
end

function ReturnV2Model:GetSystemStartTime()
  local currentData = CS.Torappu.PlayerData.instance.data.backflow.currentV2;
  if not currentData then
    return 0
  end

  return currentData.start
end