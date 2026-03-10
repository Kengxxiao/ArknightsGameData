local luaUtils = CS.Torappu.Lua.Util;
local dateUtil = CS.Torappu.DateTimeUtil;
local ReturnAllOpenType = CS.Torappu.ReturnAllOpenType;





ReturnModel = ModelMgr.DefineModel("ReturnModel");

local PLAYER_RETURN_POP_TIME_KEY = "ReturnPopTime";

local RETURN_TRACK = "RETURN_TAB_TRACK";
local RETURN_TAB_NEWS_TRACK = "RETURN_TAB_NEWS_TRACK";
local RETURN_TAB_PACKAGE_TRACK = "RETURN_TAB_PACKAGE_TRACK";
local RETURN_TAB_SPECIAL_OPEN_TRACK = "RETURN_TAB_SPECIAL_OPEN_TRACK";

function ReturnModel:OnInit()
  self.m_clickedOpenTab = nil;
  CS.Torappu.UI.Home.HomeMainStateBean.SetExtension(self);
end

function ReturnModel:OnDispose()
  CS.Torappu.UI.Home.HomeMainStateBean.SetExtension(nil);
end


function ReturnModel:GetReturnStatus()
  local status = {
    open = false;
    shouldPopup = false;
    showTrackPoint = false;
    onlySpecialOpen = false;
  }
  local playerData = self:GetPlayerData();
  if playerData == nil then
    status.open = false;
    return status;
  else
    status.open = not self:_IsTimeOut(playerData) or self:CheckIfFullOpen(playerData);
  end

  status.onlySpecialOpen = self:CheckIfOnlySpecialOpen(playerData);
  
  status.shouldPopup = self:_CheckIfPopupReturnPage();

  status.showTrackPoint = not self:_IsTimeOut(playerData) and (self:CheckIfHasCheckInReward() or self:CheckIfHasMissionReward());

  return status;
end

function ReturnModel:CheckIfHasMissionReward()
  local playerData = self:GetPlayerData();
  if playerData == nil or playerData.currentV2 == nil then
    return false;
  end
  local stageAward = ToLuaArray(playerData.currentV2.mission.stageAward);
  for index, missionReward in ipairs(stageAward) do
    if missionReward == 1 then
      return true;
    end
  end
  local longMission = playerData.currentV2.mission.longMission;
  if longMission ~= nil then
    local longMissionArray = ToLuaArray(longMission);
    for id, missionList in ipairs(longMissionArray) do
      local missionArray = ToLuaArray(missionList);
      for index, missionStat in ipairs(missionArray) do
        if missionStat.status == 1 then
          return true;
        end
      end
    end
  end
  local dailyMission = playerData.currentV2.mission.dailyMission;
  if dailyMission ~= nil then
    local dailyMissionArray = ToLuaArray(dailyMission);
    for id, missionList in ipairs(dailyMissionArray) do
      local missionArray = ToLuaArray(missionList);
      for index, missionStat in ipairs(missionArray) do
        if missionStat.status == 1 then
          return true;
        end
      end
    end
  end
  return false;
end

function ReturnModel:CheckIfHasCheckInReward()
  local playerData = self:GetPlayerData();
  if playerData == nil or playerData.currentV2 == nil then
    return false;
  end
  local checkinReward = ToLuaArray(playerData.currentV2.checkIn.history);
  for index, dayReward in ipairs(checkinReward) do
    if dayReward == 1 then
      return true;
    end
  end
  return false;
end

function ReturnModel:SetAlreadyPopup()
  if not self.m_updatePopTime then
    return;
  end
  local popupStamp = CS.Torappu.DateTimeUtil.timeStampNow;
  CS.Torappu.PlayerPrefsWrapper.SetUserInt(PLAYER_RETURN_POP_TIME_KEY, popupStamp);
end


function ReturnModel:HasOnceReward()
  return self:_GetOnceRewardStatus() == ReturnOnceRewardStatus.READY;
end


function ReturnModel:HasOnceRewardGot()
  return self:_GetOnceRewardStatus() == ReturnOnceRewardStatus.GOT;
end

function ReturnModel:GetReturnOpenLevel()
  local playerData = self:GetPlayerData();
  if playerData == nil or playerData.currentV2 == nil then
    return false;
  end
  local groupId = playerData.currentV2.groupId;
  local gameData = self:GetGameData();
  if gameData == nil or gameData.groupDataMap == nil then
    return false;
  end
  local ok, groupData = gameData.groupDataMap:TryGetValue(groupId);
  if not ok or groupData == nil then
    return false;
  end
  return groupData.campAllOpenDays > 0;
end


function ReturnModel:GetOnceRewardItemList()
  local playerData = self:GetPlayerData();
  local gameData = self:GetGameData();
  if playerData == nil or playerData.currentV2 == nil then
    return;
  end
  local systemStartTime = playerData.currentV2.start
  local groupId = playerData.currentV2.groupId
  local ok , groupData = gameData.groupDataMap:TryGetValue(groupId)
  if not ok or groupData == nil then
    return;
  end
  local ok, onceRewardData = CS.Torappu.OpenServerDB.returnData.onceDataMap:TryGetValue(groupData.onceGroupId)
  if not ok or onceRewardData == nil then
    return;
  end
  return onceRewardData.rewardList;
end



function ReturnModel:CheckIfOnlySpecialOpen(playerData)
  return self:CheckIfFullOpen(playerData) and self:_IsTimeOut(playerData);
end



function ReturnModel:CheckIfFullOpen(playerData)
  if playerData == nil then
    return false;
  end
  local currentData = playerData.currentV2;
  if currentData == nil then
    return false;
  end

  return self:CheckWeeklyFullOpenState(currentData) ~= ReturnSpecialOpenState.END or 
         self:CheckCampFullOpenState(currentData) ~= ReturnSpecialOpenState.END;
end



function ReturnModel:CheckWeeklyFullOpenState(currentData)
  local fullOpenData = currentData.fullOpen;
  if fullOpenData == nil then
    return ReturnSpecialOpenState.END;
  end
  local remain = self:GetWeeklyFullOpenRemainDay(currentData);
  if fullOpenData.today then
    return ReturnSpecialOpenState.OPEN;
  elseif remain ~= nil and remain > 0 then
    return ReturnSpecialOpenState.PAUSE;
  end;
  return ReturnSpecialOpenState.END;
end



function ReturnModel:CheckCampFullOpenState(currentData)
  local fullOpenData = currentData.campaignFullOpen;
  if fullOpenData == nil then
    return ReturnSpecialOpenState.END;
  end
  local remain = self:GetCampFullOpenRemainDay(currentData);
  if fullOpenData.today then
    return ReturnSpecialOpenState.OPEN;
  elseif remain ~= nil and remain > 0 then
    return ReturnSpecialOpenState.PAUSE;
  end
  return ReturnSpecialOpenState.END;
end



function ReturnModel:GetWeeklyFullOpenRemainDay(currentData)
  local fullOpenData = currentData.fullOpen;
  if fullOpenData == nil then
    return 0;
  end
  return fullOpenData.remain;
end



function ReturnModel:GetCampFullOpenRemainDay(currentData)
  local fullOpenData = currentData.campaignFullOpen;
  if fullOpenData == nil then
    return 0;
  end
  return fullOpenData.remain;
end


function ReturnModel:GetPlayerData()
  local playerData = CS.Torappu.PlayerData.instance.data;
  if playerData == nil then
    return nil;
  end
  local backflowData = playerData.backflow;
  if backflowData == nil or not backflowData.open then
    return nil;
  end
  return backflowData;
end


function ReturnModel:GetGameData()
  return CS.Torappu.OpenServerDB.returnData;
end



function ReturnModel:GetCurrentGroupData()
  local playerData = ReturnModel.me:GetPlayerData();
  local gameData = ReturnModel.me:GetGameData();
  if gameData == nil or playerData == nil or playerData.currentV2 == nil then
    return nil;
  end
  local currentV2 = playerData.currentV2;
  local groupId = currentV2.groupId;
  local groupDataMap = gameData.groupDataMap;
  if groupDataMap == nil or groupId == nil then
    return nil;
  end
  local ok, groupData = groupDataMap:TryGetValue(groupId);
  return groupData;
end

function ReturnModel:GetCurrentGroupId()
  local playerData = ReturnModel.me:GetPlayerData();
  if playerData == nil or playerData.currentV2 == nil then
    return "";
  end
  return playerData.currentV2.groupId;
end



function ReturnModel:_CheckIfPopupReturnPage()
  if TEST and CS.Torappu.UI.DevTester.UIDebugPanel.TestOnlyGetIfSkipBackflow() then
    return false;
  end
  if self:HasOnceReward() then
    self.m_updatePopTime = true;
    return true;
  end

  local prePopTime = nil;
  local popupStamp = CS.Torappu.PlayerPrefsWrapper.GetUserInt(PLAYER_RETURN_POP_TIME_KEY, 0);
  if popupStamp ~= nil and popupStamp > 0 then
    prePopTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(popupStamp);
  end

  local currTime = CS.Torappu.DateTimeUtil.currentTime;
  if prePopTime and CS.Torappu.DateTimeUtil.IsSameDay(prePopTime, currTime) then
    return false;
  end

  local currentData = self:GetPlayerData();
  if currentData ~= nil then
    return false;
  end

  
  if self:_IsTimeOut(currentData) then
    return false;
  end

  self.m_updatePopTime = true;
  return true;
end



function ReturnModel:_IsTimeOut(playerData)
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



function ReturnModel:_GetOnceRewardStatus()
  local playerData = self:GetPlayerData();
  if playerData == nil then
    return ReturnOnceRewardStatus.ERROR;
  end
  local currentData = playerData.currentV2;
  if currentData == nil then
    return ReturnOnceRewardStatus.ERROR;
  end
  if currentData.hasOnceRewardGot then
    return ReturnOnceRewardStatus.GOT;
  end

  if self:_IsTimeOut(playerData) then
    return ReturnOnceRewardStatus.TIME_OUT;
  else
    return ReturnOnceRewardStatus.READY;
  end
end

function ReturnModel:CheckLocalTrack()
  local playerData = self:GetPlayerData();
  if playerData == nil or playerData.currentV2 == nil then
    return;
  end
  local start = playerData.currentV2.start;
  if not CS.Torappu.LocalTrackStore.instance:CheckTrack(RETURN_TRACK, start) then
    CS.Torappu.LocalTrackStore.instance:DoTrackTrigger(RETURN_TRACK, start);
    CS.Torappu.LocalTrackStore.instance:DoTrackTrigger(RETURN_TAB_NEWS_TRACK, start);
    CS.Torappu.LocalTrackStore.instance:DoTrackTrigger(RETURN_TAB_PACKAGE_TRACK, start);
    CS.Torappu.LocalTrackStore.instance:DoTrackTrigger(RETURN_TAB_SPECIAL_OPEN_TRACK, start);
  end
end

function ReturnModel:CheckTabNewsLocalTrack()
  local playerData = self:GetPlayerData();
  if playerData == nil or playerData.currentV2 == nil then
    return false;
  end
  local start = playerData.currentV2.start;
  return CS.Torappu.LocalTrackStore.instance:CheckTrack(RETURN_TAB_NEWS_TRACK, start);
end

function ReturnModel:CheckTabPackageLocalTrack()
  local playerData = self:GetPlayerData();
  if playerData == nil or playerData.currentV2 == nil then
    return false;
  end
  local start = playerData.currentV2.start;
  return CS.Torappu.LocalTrackStore.instance:CheckTrack(RETURN_TAB_PACKAGE_TRACK, start);
end

function ReturnModel:CheckTabSpecialOpenLocalTrack()
  local playerData = self:GetPlayerData();
  if playerData == nil or playerData.currentV2 == nil then
    return false;
  end
  local start = playerData.currentV2.start;
  return CS.Torappu.LocalTrackStore.instance:CheckTrack(RETURN_TAB_SPECIAL_OPEN_TRACK, start);
end

function ReturnModel:ConsumeTabNewsLocalTrack()
  local playerData = self:GetPlayerData();
  if playerData == nil or playerData.currentV2 == nil then
    return;
  end
  local start = playerData.currentV2.start;
  CS.Torappu.LocalTrackStore.instance:ConsumeTrack(RETURN_TAB_NEWS_TRACK, start);
end

function ReturnModel:ConsumeTabPackageLocalTrack()
  local playerData = self:GetPlayerData();
  if playerData == nil or playerData.currentV2 == nil then
    return;
  end
  local start = playerData.currentV2.start;
  CS.Torappu.LocalTrackStore.instance:ConsumeTrack(RETURN_TAB_PACKAGE_TRACK, start);
end

function ReturnModel:ConsumeTabSpecialOpenLocalTrack()
  local playerData = self:GetPlayerData();
  if playerData == nil or playerData.currentV2 == nil then
    return;
  end
  local start = playerData.currentV2.start;
  CS.Torappu.LocalTrackStore.instance:ConsumeTrack(RETURN_TAB_SPECIAL_OPEN_TRACK, start);
end