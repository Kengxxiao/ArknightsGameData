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









local OpenServerV3StageStoryMainStoryItemViewModel = Class("OpenServerV3StageStoryMainStoryItemViewModel");

function OpenServerV3StageStoryMainStoryItemViewModel:LoadData(storySetData)
  self.awardCount = 0;
  self.totalAwardCount = 0;
  self.mainStoryId = storySetData.storySetId;
  self.kvImageId = storySetData.kvImageId or "";
  self.decoImageId = "";
  self.zoneId = nil;
  if storySetData.mainlineData ~= nil then
    self.decoImageId = storySetData.mainlineData.decoImageId or "";
    self.zoneId = storySetData.mainlineData.zoneId;
    if self.zoneId ~= nil then
      self.awardCount, self.totalAwardCount, self.isUnlocked =
          self:_CalcZoneAwardProgress(self.zoneId);
    end
  end
end



function OpenServerV3StageStoryMainStoryItemViewModel:_CalcZoneAwardProgress(zoneId)
  local awardGot = 0;
  local awardTotal = 0;
  local isUnlocked = false;
  local stages = StageDB.data.stages;
  if stages == nil then
    return awardGot, awardTotal, isUnlocked;
  end
  local isHardUnlocked = UIGuideController.CheckIfUnlocked(UILockTarget.HARD_BATTLE);
  local hardDifficulty = LevelDifficulty.FOUR_STAR;
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
  return awardGot, awardTotal, isUnlocked;
end













local OpenServerV3StageStorySsItemViewModel = Class("OpenServerV3StageStorySsItemViewModel");

function OpenServerV3StageStorySsItemViewModel:LoadData(storySetData)
  self.storySetId = storySetData.storySetId;
  self.retroId = storySetData.ssData and storySetData.ssData.retroActivityId or "";
  self.zoneId = "";
  self.awardCount = 0;
  self.totalAwardCount = 0;
  self.kvImageId = storySetData.kvImageId or "";
  self.titleImageId = storySetData.titleImageId or "";
  self.coreRewardType = storySetData.coreRewardType or CS.Torappu.ItemType.NONE;
  self.coreRewardId = storySetData.coreRewardId or "";

  if self.retroId == "" then
    return;
  end

  local hardDifficulty = LevelDifficulty.FOUR_STAR;
  local isHardUnlocked = UIGuideController.CheckIfUnlocked(UILockTarget.HARD_BATTLE);
  local zoneToRetro = RetroDB.data.zoneToRetro;
  local iter = RetroDB.data.stageList:GetEnumerator();
  while iter:MoveNext() do
    local stageData = iter.Current.Value;
    if stageData ~= nil and stageData.stageType == StageType.ACTIVITY then
      local hasRetro, retroId = zoneToRetro:TryGetValue(stageData.zoneId);
      if hasRetro and retroId == self.retroId then
        local isHard = stageData.difficulty == hardDifficulty;
        if isHardUnlocked or not isHard then
          self.totalAwardCount = self.totalAwardCount + stageData.diamondOnceDrop;
          local hasPlayer, playerStage = StageDataUtil.TryGetAvailStage(stageData.stageId);
          if hasPlayer and playerStage ~= nil then
            if isHard then
              if DataConvertUtil.CheckCompletedHardStage(stageData.difficulty, playerStage.state) then
                self.awardCount = self.awardCount + stageData.diamondOnceDrop;
              end
            else
              if playerStage.state == PlayerStageState.COMPLETE then
                self.awardCount = self.awardCount + stageData.diamondOnceDrop;
              end
            end
          end
        end
      end
    end
  end
  iter:Dispose();

  self:_ResolveCoreTrailReward();
end


function OpenServerV3StageStorySsItemViewModel:_ResolveCoreTrailReward()
  self.coreTrailRewardId = nil;
  self.isCoreRewardClaimed = false;

  if self.coreRewardId == "" then
    return;
  end

  local hasTrail, trailData = RetroDB.data.retroTrailList:TryGetValue(self.retroId);
  if not hasTrail or trailData == nil or trailData.trailRewardList == nil then
    return;
  end

  for i = 0, trailData.trailRewardList.Count - 1 do
    local rewardItem = trailData.trailRewardList[i];
    if rewardItem ~= nil and rewardItem.rewardItem ~= nil
        and rewardItem.rewardItem.id == self.coreRewardId
        and rewardItem.rewardItem.type == self.coreRewardType then
      self.coreTrailRewardId = rewardItem.trailRewardId;
      break;
    end
  end

  if self.coreTrailRewardId == nil then
    return;
  end

  local playerRetro = CS.Torappu.PlayerData.instance.data.retro;
  if playerRetro == nil or playerRetro.trail == nil then
    return;
  end
  local hasRetroTrail, trailDict = playerRetro.trail:TryGetValue(self.retroId);
  if not hasRetroTrail or trailDict == nil then
    return;
  end
  local hasReward, isClaimed = trailDict:TryGetValue(self.coreTrailRewardId);
  if hasReward then
    self.isCoreRewardClaimed = isClaimed;
  end
end






OpenServerV3StageStoryDlgViewModel = Class("OpenServerV3StageStoryDlgViewModel", UIViewModel);

function OpenServerV3StageStoryDlgViewModel:LoadData()
  self.mainStoryList = {};
  self.ssStoryList = {};
  self.isSsSystemUnlocked = UIGuideController.CheckIfUnlocked(UILockTarget.MIX_STORY_OVERALL);
  if not self.isSsSystemUnlocked then
    self.ssLockedTip = UIGuideController.GetLockedToastContent(UILockTarget.MIX_STORY_OVERALL);
  end

  local gameData = OpenServerV3Model.me:GetGameData();
  if gameData == nil or gameData.storyRecommendData == nil or gameData.storyRecommendData.Count <= 0 then
    return;
  end

  local storySets = StageDB.data.storylineStorySets;
  if storySets == nil then
    return;
  end

  local lockedCount = 0;
  for index = 0, gameData.storyRecommendData.Count - 1 do
    local recommendData = gameData.storyRecommendData[index];
    if recommendData ~= nil and recommendData.storySetId ~= nil then
      local ok, storySetData = storySets:TryGetValue(recommendData.storySetId);
      if ok and storySetData ~= nil then
        if storySetData.storySetType == StorylineStorySetType.MAINLINE then
          local itemModel = OpenServerV3StageStoryMainStoryItemViewModel.new();
          itemModel:LoadData(storySetData);
          if not itemModel.isUnlocked then
            lockedCount = lockedCount + 1;
          end
          if lockedCount <= 1 then
            table.insert(self.mainStoryList, itemModel);
          end
        elseif storySetData.storySetType == StorylineStorySetType.SS and self.isSsSystemUnlocked then
          local ssItemModel = OpenServerV3StageStorySsItemViewModel.new();
          ssItemModel:LoadData(storySetData);
          table.insert(self.ssStoryList, ssItemModel);
        end
      end
    end
  end
end
