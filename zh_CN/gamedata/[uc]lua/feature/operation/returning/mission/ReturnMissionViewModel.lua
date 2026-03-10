local luaUtil = CS.Torappu.Lua.Util;
















local ReturnMissionItemViewModel = Class("ReturnMissionItemViewModel");

function ReturnMissionItemViewModel:ctor()
  self.missionId = "";
  self.sortId = -1;
  self.missionDesc = "";
  self.rewardList = {};
  self.uncompleteBgIcon = "";
  self.completeBgIcon = "";
  self.value = 0;
  self.target = 1;
  self.progress = 0;
  self.sortState = ReturnMissionSortState.UNCOMPLETE;
  self.state = ReturnMissionItemState.UNCOMPLETE;
  self.jumpDestination = "";
end


function ReturnMissionItemViewModel:LoadData(missionData)
  if missionData == nil then
    return;
  end

  self.missionId = missionData.missionId;
  self.sortId = missionData.sortId;
  self.missionDesc = missionData.desc;
  self.uncompleteBgIcon = missionData.uncompleteBgIcon;
  self.completeBgIcon = missionData.completeBgIcon;
  self.rewardList = ToLuaArray(missionData.rewardList);
  self.jumpType = missionData.jumpType;
  self.jumpDestination = missionData.jumpPlace;
end


function ReturnMissionItemViewModel:RefreshPlayerData(progress)
  self.value = progress.current;
  self.target = progress.target;
  self.valueDesc = luaUtil.FormatNumberWithUnit(self.value);
  self.targetDesc = luaUtil.FormatNumberWithUnit(self.target);
  if self.target <= 0 then
    self.progress = 0;
  else
    self.progress = self.value / self.target;
  end
  self.state = progress.status;
  if self.state == ReturnMissionItemState.UNCOMPLETE then
    self.sortState = ReturnMissionSortState.UNCOMPLETE;
  elseif self.state == ReturnMissionItemState.COMPLETE then
    self.sortState = ReturnMissionSortState.COMPLETE;
  else
    self.sortState = ReturnMissionSortState.CONFIRMED;
  end
end















local ReturnMissionGroupViewModel = Class("ReturnMissionGroupViewModel");



local function _FindProgressFromPlayerData(missionId, playerProgress)
  if missionId == nil or playerProgress == nil then
    return nil;
  end
  for index, data in pairs(playerProgress) do
    if data.missionId == missionId then
      return data;
    end
  end
end

function ReturnMissionGroupViewModel:ctor()
  self.groupType = ReturnMissionGroupType.TITLE;
  self.titleType = ReturnMissionTitleType.DAILY;
  self.remainTimeDesc = "";
  self.showRemainTime = false;
  self.isMultiMission = false;
  self.state = ReturnMissionGroupState.UNCOMPLETE;
  self.groupId = "";
  self.displayMission = {};
  self.missionList = {};
  self.sortId = -1;
  self.index = -1;
end



function ReturnMissionGroupViewModel:LoadData(missionGroupData, playerMission)
  if missionGroupData == nil or missionGroupData.missionList == nil or playerMission == nil or
      playerMission.dailyMission == nil or playerMission.longMission == nil then
    return;
  end
  self.state = ReturnMissionGroupState.UNCOMPLETE;
  self.groupType = ReturnMissionGroupType.MISSION;
  self.groupId = missionGroupData.groupId;
  self.sortId = missionGroupData.sortId;
  local progressDict = playerMission.longMission;
  if missionGroupData.type == CS.Torappu.ReturnMissionGroupType.DAILY then
    progressDict = playerMission.dailyMission;
    self.titleType = ReturnMissionTitleType.DAILY;
  else
    self.titleType = ReturnMissionTitleType.NORMAL;
  end

  if progressDict == nil then
    return;
  end
  local ok, progressList = progressDict:TryGetValue(self.groupId);
  if not ok then
    return;
  end

  for index, mission in pairs(missionGroupData.missionList) do
    if mission ~= nil then
      local progress = _FindProgressFromPlayerData(mission.missionId, progressList);
      if progress ~= nil then
        local itemViewModel = ReturnMissionItemViewModel.new();
        itemViewModel:LoadData(mission);
        table.insert(self.missionList, itemViewModel);
      end
    end
  end

  self.isMultiMission = #self.missionList > 1;
end


function ReturnMissionGroupViewModel:RefreshPlayerData(playerData)
  if playerData == nil then
    return;
  end
  
  local isAllConfirmed = true;
  local hasRewardNotClaim = false;
  local playerMission = playerData.longMission;
  if self.titleType == ReturnMissionTitleType.DAILY then
    playerMission = playerData.dailyMission;
  end

  if playerMission == nil then
    return;
  end
  local ok, progressList = playerMission:TryGetValue(self.groupId);
  if not ok then
    return;
  end

  for index, mission in ipairs(self.missionList) do
    local progress = _FindProgressFromPlayerData(mission.missionId, progressList);
    if progress ~= nil then
      mission:RefreshPlayerData(progress);
      isAllConfirmed = isAllConfirmed and mission.state == ReturnMissionItemState.CONFIRMED;
      hasRewardNotClaim = hasRewardNotClaim or mission.state == ReturnMissionItemState.COMPLETE;
    end
  end

  table.sort(self.missionList, function(a, b)
    if a.sortState ~= b.sortState then
      return a.sortState < b.sortState;
    elseif a.sortId ~= b.sortId then
      return a.sortId < b.sortId;
    end
    return a.missionId < b.missionId;
  end);
  self.displayMission = self.missionList[1];

  if isAllConfirmed then
    self.state = ReturnMissionGroupState.ALL_CONFIRMED;
  elseif hasRewardNotClaim then
    self.state = ReturnMissionGroupState.HAS_REWARD;
  else
    self.state = ReturnMissionGroupState.UNCOMPLETE;
  end
end










local ReturnPointItemViewModel = Class("ReturnPointItemViewModel");

function ReturnPointItemViewModel:ctor()
  self.id = "";
  self.desc = "";
  self.pointRequire = 0;
  self.rewardList = {};
  self.state = ReturnMissionItemState.UNCOMPLETE;
  self.pointSum = 0;
  self.progress = 0;
  self.displayReward = {};
end



function ReturnPointItemViewModel:LoadData(data, prevPoint)
  if data == nil then
    return;
  end
  self.id = data.contentId;
  self.pointRequire = data.pointRequire;
  self.pointSum = self.pointRequire - prevPoint;
  self.desc = data.desc;
  self.displayReward = CS.Torappu.UI.UIItemViewModel.FromSharedItemGetModel(data.displayReward);
  self.rewardList = {};
  for index, reward in pairs(data.rewardList) do
    local rewardModel = CS.Torappu.UI.UIItemViewModel.FromSharedItemGetModel(reward);
    table.insert(self.rewardList, rewardModel);
  end
end



function ReturnPointItemViewModel:RefreshPlayerData(currPoint, status)
  self.state = status;
  local pointInLevel = currPoint - (self.pointRequire - self.pointSum);
  if pointInLevel <= 0 or self.pointSum <= 0 then
    self.progress = 0;
    return;
  end
  self.progress = pointInLevel / self.pointSum;
  if self.progress < 0 then
    self.progress = 0;
  elseif self.progress > 1 then
    self.progress = 1;
  end
end














local ReturnMissionViewModel = Class("ReturnMissionViewModel");

function ReturnMissionViewModel:ctor()
  self.seqNum = 0;
  self.missionList = {};
  self.m_missionWithTitleList = {};
  self.missionOnlyList = {};
  self.pointList = {};
  self.currentPoint = 0;
  self.hasPointRewardCanClaim = false;
  self.endTimeDesc = "";
  self.returnPointDesc = "";
  self.returnPointLevelTip = "";
end

function ReturnMissionViewModel:LoadData()
  self.missionList = {};
  self.m_missionWithTitleList = {};
  self.missionOnlyList = {};
  self.pointList = {};

  local playerData = ReturnModel.me:GetPlayerData();
  local gameData = ReturnModel.me:GetGameData();
  if gameData == nil or playerData == nil or playerData.currentV2 == nil or
      playerData.currentV2.mission == nil or playerData.currentV2.mission.longMission == nil or
      playerData.currentV2.mission.dailyMission == nil then
    return;
  end

  local playerMission = playerData.currentV2.mission;
  local groupId = playerData.currentV2.groupId;
  local groupDataMap = gameData.groupDataMap;
  local missionDataMap = gameData.missionDataMap;
  if groupDataMap == nil or missionDataMap == nil or groupId == nil then
    return;
  end
  local ok, groupData = groupDataMap:TryGetValue(groupId);
  if not ok or groupData == nil then
    return;
  end
  local missionGroupIdList = groupData.missionGroupId;
  if missionGroupIdList == nil then
    return;
  end

  for index, id in pairs(missionGroupIdList) do
    if id ~= nil then
      local ok, missionData = missionDataMap:TryGetValue(id);
      if ok then
        local missionGroupModel = ReturnMissionGroupViewModel.new();
        missionGroupModel:LoadData(missionData, playerMission);
        table.insert(self.missionOnlyList, missionGroupModel);
      end
    end
  end

  table.sort(self.missionOnlyList, function(a, b)
    return a.sortId < b.sortId;
  end);

  local currType = nil;
  for index, model in ipairs(self.missionOnlyList) do
    if currType ~= model.titleType then
      local titleModel = ReturnMissionGroupViewModel.new();
      titleModel.groupType = ReturnMissionGroupType.TITLE;
      titleModel.titleType = model.titleType;
      table.insert(self.m_missionWithTitleList, titleModel);
    end
    model.index = index;
    currType = model.titleType;
    table.insert(self.m_missionWithTitleList, model);
  end

  local pointDataMap = gameData.priceDataMap;
  if pointDataMap == nil then
    return;
  end
  local ok, priceGroupData = pointDataMap:TryGetValue(groupData.priceGroupId);
  if not ok or priceGroupData == nil or priceGroupData.content == nil then
    return;
  end
  local prevPoint = 0;
  for index, priceGroup in pairs(priceGroupData.content) do
    local pointGroupModel = ReturnPointItemViewModel.new();
    pointGroupModel:LoadData(priceGroup, prevPoint);
    prevPoint = pointGroupModel.pointRequire;
    table.insert(self.pointList, pointGroupModel);
  end

  local constData = gameData.constData;
  if constData == nil then
    return;
  end
  self.returnPointDesc = constData.returnPriceDesc;
  self.returnPointLevelTip = luaUtil.Format(StringRes.RETURN_POINT_TIP_FORMAT, CS.Torappu.UI.ItemUtil.GetItemName(constData.pointItemId));
end


function ReturnMissionViewModel:RefreshPlayerData(playerData)
  self.missionList = {};

  if playerData == nil or playerData.currentV2 == nil or
      playerData.currentV2.mission == nil or playerData.currentV2.mission.longMission == nil or
      playerData.currentV2.mission.dailyMission == nil or playerData.currentV2.mission.dailySupply == nil then
    return;
  end

  local finishTs = playerData.currentV2.finishTs;
  local endTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(finishTs);
  self.endTimeDesc = luaUtil.Format(StringRes.DATE_FORMAT_YYYY_MM_DD_HH_MM, endTime.Year, endTime.Month, endTime.Day, endTime.Hour, endTime.Minute);
  local currTime = CS.Torappu.DateTimeUtil.currentTime;
  local nextDayTime = CS.Torappu.DateTimeUtil.GetNextCrossDayTime(currTime);
  local nextDayTs = CS.Torappu.DateTimeUtil.DateTimeToTimeStamp(nextDayTime);
  local showRemainTime = nextDayTs <= finishTs;
  local formatDesc = StringRes.RETURN_DAILY_MISSION_END_TIME_DESC;
  if showRemainTime then
    formatDesc = StringRes.RETURN_DAILY_MISSION_REFRESH_REMAIN_TIME_DESC;
  end
  local timeSpan = nextDayTime - currTime;
  local nextTimeDesc = luaUtil.Format(formatDesc, luaUtil.FormatTimeDelta(timeSpan));

  local playerMission = playerData.currentV2.mission;

  self.hasRewardCanClaim = false;
  for index, groupData in ipairs(self.missionOnlyList) do
    if groupData.groupType == ReturnMissionGroupType.MISSION then
      groupData:RefreshPlayerData(playerMission);
      self.hasRewardCanClaim = self.hasRewardCanClaim or groupData.state == ReturnMissionGroupState.HAS_REWARD;
    end
  end

  
  self.hasPointRewardCanClaim = false;
  self.currentPoint = playerData.currentV2.mission.point;
  local stageAwardSt = ToLuaArray(playerData.currentV2.mission.stageAward);
  for index, progress in pairs(stageAwardSt) do
    local priceData = self.pointList[index];
    if priceData ~= nil then
      priceData:RefreshPlayerData(self.currentPoint, progress);
      self.hasPointRewardCanClaim = self.hasPointRewardCanClaim or priceData.state == ReturnMissionItemState.COMPLETE;
    end
  end
  self.hasRewardCanClaim = self.hasRewardCanClaim or self.hasPointRewardCanClaim;

  if self.hasRewardCanClaim then
    local claimAllModel = ReturnMissionGroupViewModel.new();
    claimAllModel.groupType = ReturnMissionGroupType.CLAIM_ALL;
    table.insert(self.missionList, claimAllModel);
  end
  for index, groupData in ipairs(self.m_missionWithTitleList) do
    if groupData.groupType == ReturnMissionGroupType.TITLE then
      groupData.showRemainTime = groupData.titleType == ReturnMissionTitleType.DAILY;
      groupData.remainTimeDesc = nextTimeDesc;
    end
    table.insert(self.missionList, groupData);
  end
end

return ReturnMissionViewModel;