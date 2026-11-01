local OpenServerMissionType = CS.Torappu.OpenServerMissionType;
local OpenServerMissionTypeEnumInfo = CS.Torappu.EnumInfoCache(OpenServerMissionType);















local OpenServerV3MissionTaskItemViewModel = Class("OpenServerV3MissionTaskItemViewModel");

function OpenServerV3MissionTaskItemViewModel:ctor()
  self.missionId = "";
  self.groupId = "";
  self.sortId = 0;
  self.missionType = CS.Torappu.OpenServerMissionType.NORMAL;
  self.tagTypeDesc = "";
  self.desc = "";
  self.rewardList = {};
  self.value = 0;
  self.target = 1;
  self.progress = 0;
  self.state = OpenServerV3MissionItemState.UNCOMPLETE;
  self.jumpType = OperationJumpType.NONE;
  self.jumpPlace = "";
end


function OpenServerV3MissionTaskItemViewModel:LoadData(missionData)
  if missionData == nil then
    return;
  end
  self.missionId = missionData.id;
  self.groupId = missionData.missionGroup;
  self.sortId = missionData.sortId;
  self.missionType = missionData.openServerMissionType;
  self.tagTypeDesc = self:_GetMissionTypeDesc(self.missionType);
  self.desc = missionData.description;
  self.jumpType = OperationJumpUtil.GetOpenServerV3OperationJumpType(missionData.jumpType);
  self.jumpPlace = missionData.jumpPlace;
  self.rewardList = {};
  if missionData.rewards ~= nil then
    for index = 0, missionData.rewards.Count - 1 do
      local reward = missionData.rewards[index];
      if reward ~= nil then
        local itemModel = CS.Torappu.UI.UIItemViewModel();
        itemModel:LoadGameData(reward.id, reward.type);
        itemModel.itemCount = reward.count;
        table.insert(self.rewardList, itemModel);
      end
    end
  end
end




function OpenServerV3MissionTaskItemViewModel:_GetMissionTypeDesc(missionType)
  local gameData = OpenServerV3Model.me:GetGameData();
  if gameData == nil or gameData.missionTypeDescData == nil then
    return "";
  end
  local key = OpenServerMissionTypeEnumInfo.ConvertToString(missionType);
  local ok, data = gameData.missionTypeDescData:TryGetValue(key);
  if ok and data ~= nil then
    return data.desc;
  end
  return "";
end


function OpenServerV3MissionTaskItemViewModel:RefreshPlayerData(playerMission)
  self.value, self.target = OpenServerV3Model.me:GetMissionProgress(playerMission);
  self.value = self.value > self.target and self.target or self.value;
  if self.target <= 0 then
    self.progress = 0;
  else
    self.progress = self.value / self.target;
  end
  self.state = OpenServerV3Model.me:GetMissionItemState(playerMission);
end



local function _GetMissionSortWeight(state)
  if state == OpenServerV3MissionItemState.COMPLETE then
    return 0;
  elseif state == OpenServerV3MissionItemState.UNCOMPLETE then
    return 1;
  end
  return 2;
end







local OpenServerV3MilestoneItemViewModel = Class("OpenServerV3MilestoneItemViewModel");

function OpenServerV3MilestoneItemViewModel:ctor()
  self.level = 0;
  self.pointCnt = 0;
  self.isBonus = false;
  self.rewardModel = nil;
  self.state = OpenServerV3MilestoneItemState.UNCOMPLETE;
end


function OpenServerV3MilestoneItemViewModel:LoadData(itemData)
  if itemData == nil then
    return;
  end
  self.level = itemData.level;
  self.pointCnt = itemData.pointCnt;
  self.isBonus = itemData.isBonus;
  self.rewardModel = self:_CreateRewardModel(itemData.reward);
end


function OpenServerV3MilestoneItemViewModel:RefreshPlayerData(playerMilestone)
  if playerMilestone == nil then
    self.state = OpenServerV3MilestoneItemState.UNCOMPLETE;
    return;
  end
  local got = playerMilestone.got;
  if got ~= nil and got:Contains(self.level) then
    self.state = OpenServerV3MilestoneItemState.CONFIRMED;
  elseif playerMilestone.point >= self.pointCnt then
    self.state = OpenServerV3MilestoneItemState.COMPLETE;
  else
    self.state = OpenServerV3MilestoneItemState.UNCOMPLETE;
  end
end




function OpenServerV3MilestoneItemViewModel:_CreateRewardModel(reward)
  if reward == nil then
    return nil;
  end
  local itemModel = CS.Torappu.UI.UIItemViewModel();
  itemModel:LoadGameData(reward.id, reward.type);
  itemModel.itemCount = reward.count;
  return itemModel;
end


















local OpenServerV3MilestoneViewModel = Class("OpenServerV3MilestoneViewModel");

function OpenServerV3MilestoneViewModel:ctor()
  self.groupId = "";
  self.pointItemId = "";
  self.rewardImgId = "";
  self.currentPoint = 0;
  self.currentLevel = 0;
  self.currentStagePoint = 0;
  self.nextStageNeedPoint = 0;
  self.progress = 0;
  self.isMax = false;
  self.focusIndex = 0;
  self.hasRewardCanClaim = false;
  self.claimableLevelList = {};
  self.itemList = {};
  self.targetRewardItemId = "";
  self.targetRewardLevel = 0;
  self.previewCharId = "";
end


function OpenServerV3MilestoneViewModel:LoadData(groupData)
  self.itemList = {};
  self.groupId = "";
  self.pointItemId = "";
  self.rewardImgId = "";
  self.targetRewardItemId = "";
  self.targetRewardLevel = 0;
  self.previewCharId = "";
  if groupData == nil then
    return;
  end
  self.groupId = groupData.groupId;
  self.pointItemId = groupData.rewardPointId;
  self.rewardImgId = groupData.rewardImgId or "";
  self.targetRewardItemId = groupData.rewardItemId;
  if groupData.itemList ~= nil then
    for index = 0, groupData.itemList.Count - 1 do
      local itemData = groupData.itemList[index];
      if itemData ~= nil then
        local itemModel = OpenServerV3MilestoneItemViewModel.new();
        itemModel:LoadData(itemData);
        table.insert(self.itemList, itemModel);
      end
    end
  end
  table.sort(self.itemList, function(a, b)
    if a.level ~= b.level then
      return a.level < b.level;
    end
    return a.pointCnt < b.pointCnt;
  end);
  self:_RefreshTargetRewardData();
end


function OpenServerV3MilestoneViewModel:RefreshPlayerData(playerMilestone)
  self.currentPoint = playerMilestone ~= nil and playerMilestone.point or 0;
  self.hasRewardCanClaim = false;
  self.claimableLevelList = {};
  for _, itemModel in ipairs(self.itemList) do
    itemModel:RefreshPlayerData(playerMilestone);
    if itemModel.state == OpenServerV3MilestoneItemState.COMPLETE then
      self.hasRewardCanClaim = true;
      table.insert(self.claimableLevelList, itemModel.level);
    end
  end
  self:_RefreshProgressData();
  self:_RefreshFocusIndex();
end


function OpenServerV3MilestoneViewModel:GetClaimableLevelList()
  return self.claimableLevelList;
end


function OpenServerV3MilestoneViewModel:_RefreshTargetRewardData()
  if self.targetRewardItemId == nil or self.targetRewardItemId == "" then
    return;
  end
  for _, itemModel in ipairs(self.itemList) do
    local reward = itemModel.rewardModel;
    if reward ~= nil and reward.itemId == self.targetRewardItemId then
      self.targetRewardLevel = itemModel.level;
      if self:_CheckIfCharId(self.targetRewardItemId) then
        self.previewCharId = self.targetRewardItemId;
      end
      return;
    end
  end
end




function OpenServerV3MilestoneViewModel:_CheckIfCharId(itemId)
  if itemId == nil or itemId == "" then
    return false;
  end
  local charName = CS.Torappu.CharacterUtil.GetCharName(itemId);
  return charName ~= nil and charName ~= "";
end


function OpenServerV3MilestoneViewModel:_RefreshProgressData()
  self.currentLevel = 0;
  self.currentStagePoint = 0;
  self.nextStageNeedPoint = 0;
  self.progress = 0;
  self.isMax = false;

  local prevPointCnt = 0;
  local nextItem = nil;
  for _, itemModel in ipairs(self.itemList) do
    if self.currentPoint < itemModel.pointCnt then
      nextItem = itemModel;
      break;
    end
    self.currentLevel = itemModel.level;
    prevPointCnt = itemModel.pointCnt;
  end

  if nextItem == nil then
    self.isMax = #self.itemList > 0;
    self.progress = self.isMax and 1 or 0;
    return;
  end

  self.nextStageNeedPoint = nextItem.pointCnt - prevPointCnt;
  self.currentStagePoint = self.currentPoint - prevPointCnt;
  if self.currentStagePoint < 0 then
    self.currentStagePoint = 0;
  elseif self.currentStagePoint > self.nextStageNeedPoint then
    self.currentStagePoint = self.nextStageNeedPoint;
  end

  self.progress = self.nextStageNeedPoint > 0 and self.currentStagePoint / self.nextStageNeedPoint or 0;
end


function OpenServerV3MilestoneViewModel:_RefreshFocusIndex()
  self.focusIndex = 0;
  for index, itemModel in ipairs(self.itemList) do
    if itemModel.state == OpenServerV3MilestoneItemState.COMPLETE then
      self.focusIndex = index;
      return;
    end
  end
  for index, itemModel in ipairs(self.itemList) do
    if itemModel.state == OpenServerV3MilestoneItemState.UNCOMPLETE then
      self.focusIndex = index;
      return;
    end
  end
  if #self.itemList > 0 then
    self.focusIndex = #self.itemList;
  end
end











local OpenServerV3MissionStageViewModel = Class("OpenServerV3MissionStageViewModel");

function OpenServerV3MissionStageViewModel:ctor()
  self.groupId = "";
  self.sortId = 0;
  self.index = 0;
  self.selected = false;
  self.locked = true;
  self.completed = false;
  self.hasTrackPoint = false;
  self.trackPointType = nil;
  self.missionList = {};
end


function OpenServerV3MissionStageViewModel:LoadData(groupData)
  if groupData == nil then
    return;
  end
  self.groupId = groupData.id;
  self.sortId = groupData.sortId;
end

function OpenServerV3MissionStageViewModel:RefreshPlayerData()
  self.completed = OpenServerV3Model.me:CheckIfMissionGroupComplete(self.groupId);
  self.hasTrackPoint = false;
  for _, missionModel in ipairs(self.missionList) do
    missionModel:RefreshPlayerData(OpenServerV3Model.me:GetPlayerMissionState(missionModel.missionId));
    self.hasTrackPoint = self.hasTrackPoint or missionModel.state == OpenServerV3MissionItemState.COMPLETE;
  end
  table.sort(self.missionList, function(a, b)
    local aSortWeight = _GetMissionSortWeight(a.state);
    local bSortWeight = _GetMissionSortWeight(b.state);
    if aSortWeight ~= bSortWeight then
      return aSortWeight < bSortWeight;
    elseif a.sortId ~= b.sortId then
      return a.sortId < b.sortId;
    end
    return a.missionId < b.missionId;
  end);
end











local OpenServerV3MissionViewModel = Class("OpenServerV3MissionViewModel");

function OpenServerV3MissionViewModel:ctor()
  self.pageState = OpenServerV3MissionPageState.TASK;
  self.stageList = {};
  self.missionList = {};
  self.selectedStageIndex = 0;
  self.selectedStage = nil;
  self.hasRewardCanClaim = false;
  self.showTaskNewSign = false;
  self.showMilestoneNewSign = false;
  self.milestoneModel = nil;
end

function OpenServerV3MissionViewModel:LoadData()
  self.stageList = {};
  self.missionList = {};
  self.selectedStageIndex = 0;
  self.selectedStage = nil;
  self.milestoneModel = nil;
  local gameData = OpenServerV3Model.me:GetGameData();
  if gameData == nil or gameData.missionGroupData == nil or gameData.missionData == nil then
    return;
  end

  local groupModelMap = {};
  for groupId, groupData in pairs(gameData.missionGroupData) do
    if groupData ~= nil then
      local groupModel = OpenServerV3MissionStageViewModel.new();
      groupModel:LoadData(groupData);
      groupModelMap[groupId] = groupModel;
      table.insert(self.stageList, groupModel);
    end
  end

  table.sort(self.stageList, function(a, b)
    if a.sortId ~= b.sortId then
      return a.sortId < b.sortId;
    end
    return a.groupId < b.groupId;
  end);
  for index, groupModel in ipairs(self.stageList) do
    groupModel.index = index;
    groupModel.trackPointType = OpenServerV3TrackPointUtil.DefineMissionStageTrackPoint(groupModel.groupId);
  end

  for _, missionData in pairs(gameData.missionData) do
    if missionData ~= nil then
      local groupModel = groupModelMap[missionData.missionGroup];
      if groupModel ~= nil then
        local missionModel = OpenServerV3MissionTaskItemViewModel.new();
        missionModel:LoadData(missionData);
        table.insert(groupModel.missionList, missionModel);
      end
    end
  end
  self:_LoadMilestoneData(gameData);
end

function OpenServerV3MissionViewModel:RefreshPlayerData()
  local selectedStageIndex = self.selectedStageIndex;
  local selectedStage = self.stageList[selectedStageIndex];
  self:_RefreshStageLockedState();

  for _, stageModel in ipairs(self.stageList) do
    stageModel:RefreshPlayerData();
  end
  if selectedStage ~= nil and not selectedStage.locked then
    self:_ApplySelectedStage(selectedStageIndex, selectedStage);
  else
    self:_ClearSelectedStage();
  end
  self:_RefreshMilestonePlayerData();
  local hasTaskTrackPoint = OpenServerV3Model.me:CheckIfHasMissionReward();
  local hasMilestoneTrackPoint = OpenServerV3Model.me:CheckIfHasMilestoneReward();
  self.showTaskNewSign = OpenServerV3Model.me:CheckIfHasMissionNewTip() and not hasTaskTrackPoint;
  self.showMilestoneNewSign = OpenServerV3Model.me:CheckIfHasMilestoneNewTip() and not hasMilestoneTrackPoint;
end



function OpenServerV3MissionViewModel:SetPageState(pageState)
  if pageState == nil or self.pageState == pageState then
    return false;
  end
  self.pageState = pageState;
  return true;
end

function OpenServerV3MissionViewModel:SelectRecommendedStage()
  local recommendedGroupId = self:_PickRecommendedGroupId();
  for index, stageModel in ipairs(self.stageList) do
    if stageModel.groupId == recommendedGroupId then
      self:_ApplySelectedStage(index, stageModel);
      return;
    end
  end
  self:_ClearSelectedStage();
end


function OpenServerV3MissionViewModel:FocusPageByRewardTrackPoint()
  local hasTaskReward = OpenServerV3Model.me:CheckIfHasMissionReward();
  local hasMilestoneReward = OpenServerV3Model.me:CheckIfHasMilestoneReward();
  local targetPageState = OpenServerV3MissionPageState.TASK;
  if not hasTaskReward and hasMilestoneReward then
    targetPageState = OpenServerV3MissionPageState.MILESTONE;
  end
  return self:SetPageState(targetPageState);
end




function OpenServerV3MissionViewModel:SetSelectedStageIndex(stageIndex)
  local stageModel = self.stageList[stageIndex];
  if stageModel == nil or stageModel.locked then
    return false, stageModel;
  end
  if self.selectedStageIndex == stageIndex then
    return false, stageModel;
  end
  self:_ApplySelectedStage(stageIndex, stageModel);
  return true, stageModel;
end




function OpenServerV3MissionViewModel:_ApplySelectedStage(stageIndex, stageModel)
  self.selectedStageIndex = stageIndex;
  self.selectedStage = stageModel;
  self.missionList = stageModel.missionList;
  self.hasRewardCanClaim = stageModel.hasTrackPoint;
  for index, model in ipairs(self.stageList) do
    model.selected = index == stageIndex;
  end
end


function OpenServerV3MissionViewModel:_ClearSelectedStage()
  self.selectedStageIndex = 0;
  self.selectedStage = nil;
  self.missionList = {};
  self.hasRewardCanClaim = false;
  for _, model in ipairs(self.stageList) do
    model.selected = false;
  end
end


function OpenServerV3MissionViewModel:GetClaimableMissionIdsInSelectedStage()
  if self.selectedStage == nil then
    return {};
  end
  return OpenServerV3Model.me:GetClaimableMissionIdsInGroup(self.selectedStage.groupId);
end


function OpenServerV3MissionViewModel:GetClaimableMilestoneLevels()
  if self.milestoneModel == nil then
    return {};
  end
  return self.milestoneModel:GetClaimableLevelList();
end


function OpenServerV3MissionViewModel:_RefreshStageLockedState()
  for _, stageModel in ipairs(self.stageList) do
    stageModel.locked = self:_CheckIfStageLocked(stageModel);
  end
end



function OpenServerV3MissionViewModel:_PickRecommendedGroupId()
  local latestUnlockedGroup = nil;
  local latestClaimableGroup = nil;
  for _, stageModel in ipairs(self.stageList) do
    if not stageModel.locked then
      latestUnlockedGroup = stageModel.groupId;
      local claimableMissionIds = OpenServerV3Model.me:GetClaimableMissionIdsInGroup(stageModel.groupId);
      if claimableMissionIds ~= nil and #claimableMissionIds > 0 then
        latestClaimableGroup = stageModel.groupId;
      end
    end
  end
  return latestClaimableGroup or latestUnlockedGroup or (self.stageList[1] ~= nil and self.stageList[1].groupId or "");
end




function OpenServerV3MissionViewModel:_CheckIfStageLocked(stageModel)
  if stageModel == nil then
    return true;
  end
  return not OpenServerV3Model.me:CheckIfMissionGroupUnlocked(stageModel.groupId);
end



function OpenServerV3MissionViewModel:_LoadMilestoneData(gameData)
  local playerData = OpenServerV3Model.me:GetPlayerData();
  if playerData == nil or playerData.mission == nil or playerData.mission.milestone == nil then
    return;
  end
  local playerMilestone = playerData.mission.milestone;
  if playerMilestone.groupId == nil or playerMilestone.groupId == "" or gameData.milestoneGroupData == nil then
    return;
  end
  local ok, groupData = gameData.milestoneGroupData:TryGetValue(playerMilestone.groupId);
  if not ok or groupData == nil then
    return;
  end
  self.milestoneModel = OpenServerV3MilestoneViewModel.new();
  self.milestoneModel:LoadData(groupData);
end


function OpenServerV3MissionViewModel:_RefreshMilestonePlayerData()
  if self.milestoneModel == nil then
    return;
  end
  local playerData = OpenServerV3Model.me:GetPlayerData();
  if playerData == nil or playerData.mission == nil then
    self.milestoneModel:RefreshPlayerData(nil);
    return;
  end
  self.milestoneModel:RefreshPlayerData(playerData.mission.milestone);
end

return OpenServerV3MissionViewModel;