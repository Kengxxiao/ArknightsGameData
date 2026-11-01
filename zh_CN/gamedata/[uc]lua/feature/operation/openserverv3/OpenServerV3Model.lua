local luaUtils = CS.Torappu.Lua.Util;
local StageDB = CS.Torappu.StageDB;
local RetroDB = CS.Torappu.RetroDB;
local StageDataUtil = CS.Torappu.StageDataUtil;
local DataConvertUtil = CS.Torappu.DataConvertUtil;
local PlayerStageState = CS.Torappu.PlayerStageState;
local UIGuideController = CS.Torappu.UI.UIGuideController;
local UILockTarget = CS.Torappu.UI.UILockTarget;
local LevelDifficulty = CS.Torappu.LevelData.Difficulty;
local StorylineStorySetType = CS.Torappu.StorylineStorySetType;
local StageType = CS.Torappu.StageType;





OpenServerV3Model = ModelMgr.DefineModel("OpenServerV3Model");

local PLAYER_OPEN_SERVER_POP_TIME_KEY = "OpenServerPopTime";

local OPEN_SERVER_V3_NEW_TIP_TRACK = "OPEN_SERVER_V3_NEW_TIP_TRACK";
local OPEN_SERVER_V3_INIT_KEY = "init";
local OPEN_SERVER_V3_MISSION_NEW_TIP = "mission";
local OPEN_SERVER_V3_MILESTONE_NEW_TIP = "milestone";
local OPEN_SERVER_V3_STAGE_NEW_TIP = "stage";
local OPEN_SERVER_V3_GIFT_PACKAGE_NEW_TIP = "gift_package";


function OpenServerV3Model:GetOpenServerStatus()
  local status = {
    open = false;
    shouldPopup = false;
    showTrackPoint = false;
    showNewTip = false;
  }
  local playerData = self:GetPlayerData();
  if playerData == nil then
    status.open = false;
    return status;
  end
  status.open = self:CheckIfSystemOpen();
  
  status.shouldPopup = self:_CheckIfPopupOpenServerPage();
  status.showTrackPoint = self:CheckIfHasCheckInReward() or self:CheckIfHasMissionReward() or
      self:CheckIfHasMilestoneReward();
  status.showNewTip = self:CheckIfHasMissionTabNewTip() or self:CheckIfHasStageNewTip() or
      self:CheckIfHasGiftPackageNewTip();
  return status;
end


function OpenServerV3Model:GetPlayerData()
  local playerData = CS.Torappu.PlayerData.instance.data;
  if playerData == nil then
    return nil;
  end
  local openServerData = playerData.openServerV3;
  if openServerData == nil then
    return nil;
  end
  return openServerData;
end


function OpenServerV3Model:GetGameData()
  return CS.Torappu.OpenServerDB.data.openServerV3Data;
end


function OpenServerV3Model:GetPlayerGuideV3MissionData()
  local playerData = CS.Torappu.PlayerData.instance.data;
  if playerData == nil or playerData.mission == nil or playerData.mission.missions == nil then
    return nil;
  end
  return playerData.mission.missions.GuideV3;
end


function OpenServerV3Model:GetPlayerMissionGroupData()
  local playerData = CS.Torappu.PlayerData.instance.data;
  if playerData == nil or playerData.mission == nil then
    return nil;
  end
  return playerData.mission.missionGroups;
end



function OpenServerV3Model:GetPlayerMissionState(missionId)
  if missionId == nil or missionId == "" then
    return nil;
  end
  local playerMissions = self:GetPlayerGuideV3MissionData();
  if playerMissions == nil then
    return nil;
  end
  local ok, mission = playerMissions:TryGetValue(missionId);
  if ok then
    return mission;
  end
  return nil;
end



function OpenServerV3Model:GetPlayerMissionGroupState(groupId)
  if groupId == nil or groupId == "" then
    return nil;
  end
  local playerMissionGroups = self:GetPlayerMissionGroupData();
  if playerMissionGroups == nil then
    return nil;
  end
  local ok, groupState = playerMissionGroups:TryGetValue(groupId);
  if ok then
    return groupState;
  end
  return nil;
end



function OpenServerV3Model:CheckIfMissionGroupUnlocked(groupId)
  return self:GetPlayerMissionGroupState(groupId) ~= nil;
end



function OpenServerV3Model:CheckIfMissionGroupComplete(groupId)
  return self:GetPlayerMissionGroupState(groupId) == CS.Torappu.MissionPlayerData.MissionGroupState.Complete;
end



function OpenServerV3Model:GetMissionProgress(playerMission)
  if playerMission == nil or playerMission.progress == nil or playerMission.progress.Count <= 0 then
    return 0, 1;
  end
  local progress = playerMission.progress[0];
  if progress == nil then
    return 0, 1;
  end
  return progress.value, progress.target;
end



function OpenServerV3Model:GetMissionItemState(playerMission)
  local value, target = self:GetMissionProgress(playerMission);
  if playerMission ~= nil and playerMission.state == CS.Torappu.MissionHoldingState.FINISHED then
    return OpenServerV3MissionItemState.CONFIRMED;
  end
  if playerMission ~= nil and playerMission.state == CS.Torappu.MissionHoldingState.CONFIRMED and value >= target then
    return OpenServerV3MissionItemState.COMPLETE;
  end
  return OpenServerV3MissionItemState.UNCOMPLETE;
end



function OpenServerV3Model:CheckIfMissionCanClaim(missionId)
  return self:GetMissionItemState(self:GetPlayerMissionState(missionId)) == OpenServerV3MissionItemState.COMPLETE;
end



function OpenServerV3Model:GetClaimableMissionIdsInGroup(groupId)
  local missionIds = {};
  if groupId == nil or groupId == "" then
    return missionIds;
  end
  local gameData = self:GetGameData();
  if gameData == nil or gameData.missionData == nil then
    return missionIds;
  end
  for missionId, missionData in pairs(gameData.missionData) do
    if missionData ~= nil and missionData.missionGroup == groupId and self:CheckIfMissionCanClaim(missionId) then
      table.insert(missionIds, missionId);
    end
  end
  return missionIds;
end


function OpenServerV3Model:CheckIfHasCheckInReward()
  local playerData = self:GetPlayerData();
  if playerData == nil or playerData.checkIn == nil or playerData.checkIn.groupId == nil or
      playerData.checkIn.groupId == "" or playerData.checkIn.history == nil then
    return false;
  end
  local gameData = self:GetGameData();
  if gameData == nil or gameData.checkInData == nil then
    return false;
  end

  local ok, checkInGroupData = gameData.checkInData:TryGetValue(playerData.checkIn.groupId);
  if not ok or checkInGroupData == nil or checkInGroupData.checkInItemList == nil or
      checkInGroupData.checkInItemList.Count <= 0 then
    return false;
  end

  local history = playerData.checkIn.history;
  local checkInCount = history.Count;
  if checkInCount > checkInGroupData.checkInItemList.Count then
    checkInCount = checkInGroupData.checkInItemList.Count;
  end
  for index = 0, checkInCount - 1 do
    if history[index] == 1 then
      return true;
    end
  end
  return false;
end


function OpenServerV3Model:CheckIfHasMissionReward()
  local gameData = self:GetGameData();
  if gameData == nil or gameData.missionData == nil then
    return false;
  end
  for id, _ in pairs(gameData.missionData) do
    if self:CheckIfMissionCanClaim(id) then
      return true;
    end
  end
  return false;
end


function OpenServerV3Model:CheckIfHasMilestoneReward()
  local playerData = self:GetPlayerData();
  if playerData == nil or playerData.mission == nil or playerData.mission.milestone == nil then
    return false;
  end
  local playerMilestone = playerData.mission.milestone;
  if playerMilestone.groupId == nil or playerMilestone.groupId == "" or playerMilestone.got == nil then
    return false;
  end
  local gameData = self:GetGameData();
  if gameData == nil or gameData.milestoneGroupData == nil then
    return false;
  end

  local ok, milestoneGroupData = gameData.milestoneGroupData:TryGetValue(playerMilestone.groupId);
  if not ok or milestoneGroupData == nil or milestoneGroupData.itemList == nil or
      milestoneGroupData.itemList.Count <= 0 then
    return false;
  end

  local got = playerMilestone.got;
  for index = 0, milestoneGroupData.itemList.Count - 1 do
    local itemData = milestoneGroupData.itemList[index];
    if itemData ~= nil and playerMilestone.point >= itemData.pointCnt and not got:Contains(itemData.level) then
      return true;
    end
  end
  return false;
end



function OpenServerV3Model:CheckIfMilestoneCanClaim(level)
  if level == nil then
    return false;
  end
  local playerData = self:GetPlayerData();
  if playerData == nil or playerData.mission == nil or playerData.mission.milestone == nil then
    return false;
  end
  local playerMilestone = playerData.mission.milestone;
  if playerMilestone.groupId == nil or playerMilestone.groupId == "" or playerMilestone.got == nil then
    return false;
  end
  if playerMilestone.got:Contains(level) then
    return false;
  end
  local itemData = self:_FindMilestoneItemData(playerMilestone.groupId, level);
  return itemData ~= nil and playerMilestone.point >= itemData.pointCnt;
end


function OpenServerV3Model:CheckIfSystemOpen()
  return not self:CheckIfStageComplete();
end


function OpenServerV3Model:CheckIfCheckInComplete()
  local playerData = self:GetPlayerData();
  if playerData == nil or playerData.checkIn == nil then
    return true;
  end
  local playerCheckIn = playerData.checkIn;
  if playerCheckIn.groupId == nil or playerCheckIn.groupId == "" then
    return true;
  end
  if playerCheckIn.history == nil then
    return false;
  end
  local gameData = self:GetGameData();
  if gameData == nil or gameData.checkInData == nil then
    return true;
  end

  local ok, checkInGroupData = gameData.checkInData:TryGetValue(playerCheckIn.groupId);
  if not ok or checkInGroupData == nil or checkInGroupData.checkInItemList == nil or
      checkInGroupData.checkInItemList.Count <= 0 then
    return true;
  end

  local history = playerCheckIn.history;
  local checkInCount = checkInGroupData.checkInItemList.Count;
  if history.Count < checkInCount then
    return false;
  end

  for index = 0, checkInCount - 1 do
    if history[index] == 1 then
      return false;
    end
  end
  return true;
end


function OpenServerV3Model:CheckIfMissionTabComplete()
  return self:CheckIfMissionComplete() and self:CheckIfMilestoneComplete();
end


function OpenServerV3Model:CheckIfStageComplete()
  local playerData = self:GetPlayerData();
  if playerData == nil or playerData.fullOpen == nil then
    return true;
  end
  if not self:CheckIfMissionTabComplete() or not self:CheckIfCheckInComplete() then
    return false;
  end
  return not self:_CheckIfFullOpenActive(playerData.fullOpen);
end


function OpenServerV3Model:CheckIfGiftPackageComplete()
  if not self:_CheckIfShopEntryUnlocked() then
    return true;
  end
  local gameData = self:GetGameData();
  if gameData == nil or gameData.giftPackageList == nil then
    return true;
  end
  local isComplete = true;
  for index = 0, gameData.giftPackageList.Count - 1 do
    local data = gameData.giftPackageList[index];
    if data ~= nil and luaUtils.CheckIfGiftPackageAvailable(data.goodId) then
      isComplete = false;
      break;
    end
  end
  return isComplete;
end



function OpenServerV3Model:_CheckIfShopEntryUnlocked()
  local lockTarget = CS.Torappu.UI.UILockTarget.SHOP_ENTRY;
  local isUnlocked = CS.Torappu.UI.UIGuideController.CheckIfUnlocked(lockTarget);
  return isUnlocked;
end




function OpenServerV3Model:_CheckIfFullOpenActive(fullOpen)
  if fullOpen.today then
    return true;
  end
  if fullOpen.remain ~= nil and fullOpen.remain > 0 then
    return true;
  end
  return false;
end




function OpenServerV3Model:_GetMilestoneGroupData(groupId)
  if groupId == nil or groupId == "" then
    return nil;
  end
  local gameData = self:GetGameData();
  if gameData == nil or gameData.milestoneGroupData == nil then
    return nil;
  end
  local ok, groupData = gameData.milestoneGroupData:TryGetValue(groupId);
  if ok then
    return groupData;
  end
  return nil;
end





function OpenServerV3Model:_FindMilestoneItemData(groupId, level)
  local groupData = self:_GetMilestoneGroupData(groupId);
  if groupData == nil or groupData.itemList == nil then
    return nil;
  end
  for index = 0, groupData.itemList.Count - 1 do
    local itemData = groupData.itemList[index];
    if itemData ~= nil and itemData.level == level then
      return itemData;
    end
  end
  return nil;
end


function OpenServerV3Model:CheckIfMissionComplete()
  local playerData = CS.Torappu.PlayerData.instance.data;
  if playerData == nil or playerData.mission == nil or playerData.mission.missionGroups == nil then
    return true;
  end
  local gameData = self:GetGameData();
  if gameData == nil or gameData.missionGroupData == nil then
    return true;
  end

  local playerMissionGroups = playerData.mission.missionGroups;
  for groupId, _ in pairs(gameData.missionGroupData) do
    local ok, groupState = playerMissionGroups:TryGetValue(groupId);
    if ok then
      if groupState ~= CS.Torappu.MissionPlayerData.MissionGroupState.Complete then
        return false;
      end
    end
  end
  return true;
end


function OpenServerV3Model:CheckIfMilestoneComplete()
  local playerData = self:GetPlayerData();
  if playerData == nil or playerData.mission == nil or playerData.mission.milestone == nil then
    return true;
  end
  local playerMilestone = playerData.mission.milestone;
  if playerMilestone.groupId == nil or playerMilestone.groupId == "" then
    return true;
  end
  if playerMilestone.got == nil then
    return false;
  end
  local gameData = self:GetGameData();
  if gameData == nil or gameData.milestoneGroupData == nil then
    return true;
  end

  local ok, milestoneGroupData = gameData.milestoneGroupData:TryGetValue(playerMilestone.groupId);
  if not ok or milestoneGroupData == nil or milestoneGroupData.itemList == nil or
      milestoneGroupData.itemList.Count <= 0 then
    return true;
  end

  local got = playerMilestone.got;
  for index = 0, milestoneGroupData.itemList.Count - 1 do
    local itemData = milestoneGroupData.itemList[index];
    if itemData ~= nil and not got:Contains(itemData.level) then
      return false;
    end
  end
  return true;
end


function OpenServerV3Model:CheckIfHasMissionTabNewTip()
  return self:CheckIfHasMissionNewTip() or self:CheckIfHasMilestoneNewTip();
end


function OpenServerV3Model:CheckIfHasMissionNewTip()
  return not self:CheckIfMissionComplete() and
      self:_CheckNewTip(OPEN_SERVER_V3_MISSION_NEW_TIP);
end


function OpenServerV3Model:CheckIfHasMilestoneNewTip()
  return not self:CheckIfMilestoneComplete() and
      self:_CheckNewTip(OPEN_SERVER_V3_MILESTONE_NEW_TIP);
end


function OpenServerV3Model:CheckIfHasStageNewTip()
  return not self:CheckIfStageComplete() and
      self:_CheckNewTip(OPEN_SERVER_V3_STAGE_NEW_TIP);
end


function OpenServerV3Model:CheckIfHasGiftPackageNewTip()
  return not self:CheckIfGiftPackageComplete() and
      self:_CheckNewTip(OPEN_SERVER_V3_GIFT_PACKAGE_NEW_TIP);
end

function OpenServerV3Model:ConsumeMissionNewTip()
  self:_ConsumeNewTip(OPEN_SERVER_V3_MISSION_NEW_TIP);
end

function OpenServerV3Model:ConsumeMilestoneNewTip()
  self:_ConsumeNewTip(OPEN_SERVER_V3_MILESTONE_NEW_TIP);
end

function OpenServerV3Model:ConsumeStageNewTip()
  self:_ConsumeNewTip(OPEN_SERVER_V3_STAGE_NEW_TIP);
end

function OpenServerV3Model:ConsumeGiftPackageNewTip()
  self:_ConsumeNewTip(OPEN_SERVER_V3_GIFT_PACKAGE_NEW_TIP);
end




function OpenServerV3Model:_CheckNewTip(trackId)
  self:_EnsureNewTipTracks();
  return CS.Torappu.LocalTrackStore.instance:CheckTrack(OPEN_SERVER_V3_NEW_TIP_TRACK, trackId);
end



function OpenServerV3Model:_ConsumeNewTip(trackId)
  CS.Torappu.LocalTrackStore.instance:ConsumeTrack(OPEN_SERVER_V3_NEW_TIP_TRACK, trackId);
end


function OpenServerV3Model:_EnsureNewTipTracks()
  if CS.Torappu.LocalTrackStore.instance:CheckTrack(OPEN_SERVER_V3_NEW_TIP_TRACK, OPEN_SERVER_V3_INIT_KEY) then
    return;
  end
  local trackStore = CS.Torappu.LocalTrackStore.instance;
  trackStore:DoTrackTrigger(OPEN_SERVER_V3_NEW_TIP_TRACK, OPEN_SERVER_V3_INIT_KEY);
  trackStore:DoTrackTrigger(OPEN_SERVER_V3_NEW_TIP_TRACK, OPEN_SERVER_V3_MISSION_NEW_TIP);
  trackStore:DoTrackTrigger(OPEN_SERVER_V3_NEW_TIP_TRACK, OPEN_SERVER_V3_MILESTONE_NEW_TIP);
  trackStore:DoTrackTrigger(OPEN_SERVER_V3_NEW_TIP_TRACK, OPEN_SERVER_V3_STAGE_NEW_TIP);
  trackStore:DoTrackTrigger(OPEN_SERVER_V3_NEW_TIP_TRACK, OPEN_SERVER_V3_GIFT_PACKAGE_NEW_TIP);
end

function OpenServerV3Model:SetAlreadyPopup()
  if not self.m_updatePopTime then
    return;
  end
  local popupStamp = CS.Torappu.DateTimeUtil.timeStampNow;
  CS.Torappu.PlayerPrefsWrapper.SetUserInt(PLAYER_OPEN_SERVER_POP_TIME_KEY, popupStamp);
end



function OpenServerV3Model:_CheckIfPopupOpenServerPage()
  self.m_updatePopTime = false;

  local popupStamp = CS.Torappu.PlayerPrefsWrapper.GetUserInt(PLAYER_OPEN_SERVER_POP_TIME_KEY, 0);
  local prePopTime = nil;
  if popupStamp ~= nil and popupStamp > 0 then
    prePopTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(popupStamp);
  end

  local currTime = CS.Torappu.DateTimeUtil.currentTime;
  if prePopTime ~= nil and CS.Torappu.DateTimeUtil.IsSameDay(prePopTime, currTime) then
    return false;
  end

  if not self:CheckIfHasCheckInReward() then
    return false;
  end

  self.m_updatePopTime = true;
  return true;
end


function OpenServerV3Model:GetStageStoryAwardStatus()
  local currCount = 0;
  local totalCount = 0;

  local gameData = self:GetGameData();
  if gameData == nil or gameData.storyRecommendData == nil or gameData.storyRecommendData.Count <= 0 then
    return currCount, totalCount;
  end

  local storySets = StageDB.data.storylineStorySets;
  if storySets == nil then
    return currCount, totalCount;
  end

  local isSsSystemUnlocked = UIGuideController.CheckIfUnlocked(UILockTarget.MIX_STORY_OVERALL);
  local isHardUnlocked = UIGuideController.CheckIfUnlocked(UILockTarget.HARD_BATTLE);
  local hardDifficulty = LevelDifficulty.FOUR_STAR;

  for index = 0, gameData.storyRecommendData.Count - 1 do
    local recommendData = gameData.storyRecommendData[index];
    if recommendData ~= nil and recommendData.storySetId ~= nil then
      local ok, storySetData = storySets:TryGetValue(recommendData.storySetId);
      if ok and storySetData ~= nil then
        if storySetData.storySetType == StorylineStorySetType.MAINLINE then
          local zoneId = storySetData.mainlineData ~= nil and storySetData.mainlineData.zoneId or nil;
          if zoneId ~= nil then
            local zoneCurr, zoneTotal = self:_CalcZoneAwardProgress(
                zoneId, isHardUnlocked, hardDifficulty);
            currCount = currCount + zoneCurr;
            totalCount = totalCount + zoneTotal;
          end
        elseif storySetData.storySetType == StorylineStorySetType.SS and isSsSystemUnlocked then
          local retroId = storySetData.ssData and storySetData.ssData.retroActivityId or "";
          if retroId ~= "" then
            local ssCurr, ssTotal = self:_CalcRetroAwardProgress(
                retroId, isHardUnlocked, hardDifficulty);
            currCount = currCount + ssCurr;
            totalCount = totalCount + ssTotal;
          end
        end
      end
    end
  end

  return currCount, totalCount;
end






function OpenServerV3Model:_CalcZoneAwardProgress(zoneId, isHardUnlocked, hardDifficulty)
  local awardGot = 0;
  local awardTotal = 0;

  local stages = StageDB.data.stages;
  if stages == nil then
    return 0, 0;
  end

  local isUnlocked = false;
  local iter = stages:GetEnumerator();
  while iter:MoveNext() do
    local stageData = iter.Current.Value;
    if stageData ~= nil and stageData.zoneId == zoneId
        and (stageData.stageType == StageType.MAIN or stageData.stageType == StageType.SUB) then
      if not isUnlocked and StageDataUtil.CheckIfPlayerStageAvail(stageData.stageId) then
        isUnlocked = true;
      end
      local isHard = stageData.difficulty == hardDifficulty;
      if isHardUnlocked or not isHard then
        awardTotal = awardTotal + stageData.diamondOnceDrop;
        local hasPlayer, playerStage = StageDataUtil.TryGetAvailStage(stageData.stageId);
        if hasPlayer and playerStage ~= nil then
          if isHard then
            if DataConvertUtil.CheckCompletedHardStage(stageData.difficulty, playerStage.state) then
              awardGot = awardGot + stageData.diamondOnceDrop;
            end
          else
            if playerStage.state == PlayerStageState.COMPLETE then
              awardGot = awardGot + stageData.diamondOnceDrop;
            end
          end
        end
      end
    end
  end
  iter:Dispose();

  if not isUnlocked then
    return 0, 0;
  end
  return awardGot, awardTotal;
end






function OpenServerV3Model:_CalcRetroAwardProgress(retroId, isHardUnlocked, hardDifficulty)
  local awardGot = 0;
  local awardTotal = 0;

  local zoneToRetro = RetroDB.data.zoneToRetro;
  local stageList = RetroDB.data.stageList;
  if stageList == nil then
    return awardGot, awardTotal;
  end

  local iter = stageList:GetEnumerator();
  while iter:MoveNext() do
    local stageData = iter.Current.Value;
    if stageData ~= nil and stageData.stageType == StageType.ACTIVITY then
      local hasRetro, matchedRetroId = zoneToRetro:TryGetValue(stageData.zoneId);
      if hasRetro and matchedRetroId == retroId then
        local isHard = stageData.difficulty == hardDifficulty;
        if isHardUnlocked or not isHard then
          awardTotal = awardTotal + stageData.diamondOnceDrop;
          local hasPlayer, playerStage = StageDataUtil.TryGetAvailStage(stageData.stageId);
          if hasPlayer and playerStage ~= nil then
            if isHard then
              if DataConvertUtil.CheckCompletedHardStage(stageData.difficulty, playerStage.state) then
                awardGot = awardGot + stageData.diamondOnceDrop;
              end
            else
              if playerStage.state == PlayerStageState.COMPLETE then
                awardGot = awardGot + stageData.diamondOnceDrop;
              end
            end
          end
        end
      end
    end
  end
  iter:Dispose();

  return awardGot, awardTotal;
end