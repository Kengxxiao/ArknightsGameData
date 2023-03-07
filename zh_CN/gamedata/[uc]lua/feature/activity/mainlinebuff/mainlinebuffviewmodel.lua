local luaUtils = CS.Torappu.Lua.Util;









local MainlineBuffStepViewModel = Class("MainlineBuffStepViewModel");

function MainlineBuffStepViewModel:ctor()
  self.unlockDesc = "";
  self.favorUpDesc = "";
  self.blockDesc = "";
  self.m_isBlock = true;
  self.m_isUnlock = false;
  self.m_bindStageId = "";
end


function MainlineBuffStepViewModel:InitData(stepData)
  if stepData == nil then
    return;
  end
  self.m_isBlock = stepData.isBlock;
  self.m_bindStageId = stepData.bindStageId;
  self.unlockDesc = stepData.unlockDesc;
  self.favorUpDesc = stepData.favorUpDesc;
  self.blockDesc = stepData.blockDesc;
  self.m_isUnlock = false;

  self:RefreshPlayerData();
end

function MainlineBuffStepViewModel:RefreshPlayerData()
  if self.m_isBlock or self.m_bindStageId == nil or self.m_bindStageId == "" then
    self.m_isUnlock = false;
    return;
  end
  local suc, stage = CS.Torappu.PlayerData.instance.data.dungeon.stages:TryGetValue(self.m_bindStageId);
  if not suc or stage.state == CS.Torappu.PlayerStageState.UNLOCKED or stage.state == CS.Torappu.PlayerStageState.PLAYED then
    self.m_isUnlock = false;
    return;
  end
  self.m_isUnlock = true;
end

function MainlineBuffStepViewModel:IsUnlock()
  return not self.m_isBlock and self.m_isUnlock;
end

function MainlineBuffStepViewModel:IsBlock()
  return self.m_isBlock;
end













local MainlineBuffMissionViewModel = Class("MainlineBuffMissionViewModel");

function MainlineBuffMissionViewModel:ctor()
  self.missionId = "";
  self.desc = "";
  self.rewardList = {};
  self.value = 0;
  self.target = 0;
  self.progress = 0.0;
  self.m_state = 0;
  self.groupId = "";
  self.sortId = 0;
  self.state = MainlineBuffMissionState.UNCOMPLETE;
end




function MainlineBuffMissionViewModel:InitData(index, missionData, groupId)
  if missionData == nil then
    return;
  end
  self.missionId = missionData.id;
  self.desc = missionData.description;
  self.groupId = groupId;
  self.sortId = index;
  self.state = MainlineBuffMissionState.UNCOMPLETE;

  local rewards = missionData.rewards;
  if rewards ~= nil then
    for i = 0, missionData.rewards.Count - 1 do
      local reward = missionData.rewards[i];
      if reward == nil then
        break;
      end
      local itemViewModel = CS.Torappu.UI.UIItemViewModel();
      itemViewModel:LoadGameData(reward.id, reward.type);
      itemViewModel.itemCount = reward.count;
      table.insert(self.rewardList, i + 1, itemViewModel);
    end
  end
end

function MainlineBuffMissionViewModel:RefreshPlayerData()
  self.value = 0;
  self.target = 0;
  self.progress = 0.0;
  self.m_state = 0;
  local suc, playerMission = CS.Torappu.PlayerData.instance.data.mission.missions.Activity:TryGetValue(self.missionId);
  if not suc then
    return;
  end
  self.value = playerMission.progress[0].value;
  self.target = playerMission.progress[0].target;
  if self.target ~= 0 then
    self.progress = self.value / self.target;
  else
    self.progress = 0;
  end
  self.m_state = playerMission.state;

  self.state = MainlineBuffMissionState.UNCOMPLETE;
  if self.value < self.target then
    self.state = MainlineBuffMissionState.UNCOMPLETE;
  elseif self.m_state == CS.Torappu.MissionHoldingState.CONFIRMED then
    self.state = MainlineBuffMissionState.COMPLETE;
  elseif self.m_state == CS.Torappu.MissionHoldingState.FINISHED then
    self.state = MainlineBuffMissionState.CONFIRMED;
  end
end


function MainlineBuffMissionViewModel:CalcMissionPriority()
  if self.state == MainlineBuffMissionState.CONFIRMED then
    return 1;
  elseif self.state == MainlineBuffMissionState.COMPLETE then
    return -1;
  else
    return 0;
  end
end








local MainlineBuffMissionGroupViewModel = Class("MainlineBuffMissionGroupViewModel");





local function _GetMissionData(missionList, missionId, actId)
  if missionList == nil or missionId == nil or missionId == "" or actId == nil or actId == "" then
    return nil;
  end

  for idx, cur in pairs(missionList) do
    if cur.id == missionId and cur.missionGroup == actId then
      return cur;
    end
  end
  return nil;
end

function MainlineBuffMissionGroupViewModel:ctor()
  self.actId = "";
  self.groupId = "";
  self.missionModelList = {};
  self.bannerImgName = "";
  self.zoneId = "";
  self.apSupplyEndTimeDesc = "";
end




function MainlineBuffMissionGroupViewModel:InitData(actId, missionGroupData, endTimeDesc)
  self.actId = actId;
  self.groupId = missionGroupData.Value.id;
  self.bannerImgName = missionGroupData.Value.bindBanner;
  self.zoneId = missionGroupData.Value.zoneId;
  self.missionModelList = {};
  self.apSupplyEndTimeDesc = endTimeDesc;

  local missionList = CS.Torappu.ActivityDB.data.missionData;
  for i = 0, missionGroupData.Value.missionIdList.Count - 1 do
    local missionId = missionGroupData.Value.missionIdList[i];
    local missionData = _GetMissionData(missionList, missionId, actId);
    local missionModel = MainlineBuffMissionViewModel.new();
    missionModel:InitData(i, missionData, self.groupId);
    table.insert(self.missionModelList, i + 1, missionModel);
  end
end

function MainlineBuffMissionGroupViewModel:RefreshPlayerData()
  for i = 1, #self.missionModelList do
    local model = self.missionModelList[i];
    if model ~= nil then
      model:RefreshPlayerData();
    end
  end
  table.sort(self.missionModelList, function(left, right)
    local lhsPri = left:CalcMissionPriority();
    local rhsPri = right:CalcMissionPriority();
    
    if lhsPri < rhsPri then
      return true;
    elseif lhsPri > rhsPri then
      return false;
    elseif left.sortId < right.sortId then
      return true;
    elseif left.sortId > right.sortId then
      return false;
    else
      return false;
    end;
  end);
end






















local MainlineBuffViewModel = Class("MainlineBuffViewModel");

function MainlineBuffViewModel:InitData(actId)
  self.actId = actId;
  self.firstStepModel = MainlineBuffStepViewModel.new();
  self.secondStepModel = MainlineBuffStepViewModel.new();
  self.missionGroupModelList = {};
  self:_LoadGameData(actId);
  self:RefreshPlayerData();
end

function MainlineBuffViewModel:_LoadGameData(actId)
  self.endTimeDesc = nil;
  self.m_endTime = nil;
  self.firstStepModel:ctor();
  self.secondStepModel:ctor();
  self.missionGroupModelList = {};
  self.favorUpCharList = {};
  self.showCompleteAll = false;
  self.showFavorUpPanel = false;
  local suc, basicInfo = CS.Torappu.ActivityDB.data.basicInfo:TryGetValue(actId);
  if not suc then
    return;
  end
  local endTime = luaUtils.ToDateTime(basicInfo.endTime);
  local timeRemain = endTime - CS.Torappu.DateTimeUtil.currentTime;
  self.endTimeDesc = luaUtils.Format(
      CS.Torappu.StringRes.DATE_FORMAT_YYYY_MM_DD_HH_MM,
      endTime.Year, endTime.Month, endTime.Day, endTime.Hour, endTime.Minute);
  self.timeRemainDesc = luaUtils.Format(
      CS.Torappu.StringRes.COMMON_LEFT_TIME, 
      CS.Torappu.FormatUtil.FormatTimeDelta(timeRemain));
  self.m_endTime = endTime;
  self.periodId = MainlineBuffUtil.GetCurrMainlineBuffActPeriodId(actId);

  local suc, gameData = CS.Torappu.ActivityDB.data.activity.mainlineBuffData:TryGetValue(actId);
  if not suc then
    return;
  end
  self.favorUpStageRangeDesc = gameData.constData.favorUpStageRange;

  local endTimeDesc = "";
  if gameData.apSupplyOutOfDateDict ~= nil and gameData.apSupplyOutOfDateDict.Count then
    local endTime = luaUtils.ToDateTime(gameData.apSupplyOutOfDateDict[0].Value);
    endTimeDesc = luaUtils.Format(
        CS.Torappu.StringRes.DATE_FORMAT_YYYY_MM_DD_HH_MM,
        endTime.Year, endTime.Month, endTime.Day, endTime.Hour, endTime.Minute);
  end
  for i = 0, gameData.missionGroupList.Count - 1 do
    local missionGroupData = gameData.missionGroupList[i];
    local model = MainlineBuffMissionGroupViewModel.new();
    model:InitData(actId, missionGroupData, endTimeDesc);
    table.insert(self.missionGroupModelList, i + 1, model);
  end
end

function MainlineBuffViewModel:RefreshPlayerData()
  local periodData = MainlineBuffUtil.GetCurrMainlineBuffActPeriodData(self.actId);
  if periodData ~= nil then
    self.firstStepModel:InitData(periodData.stepDataList[0]);
    self.secondStepModel:InitData(periodData.stepDataList[1]);
    self.favorUpCharImgName = periodData.favorUpImgName;
    self.newChapterImgName = periodData.newChapterImgName;
    self.newChapterZoneId = periodData.newChapterZoneId;
    self.favorUpCharDesc = periodData.favorUpCharDesc;
  end

  self.m_zoneGroupDict = CS.Torappu.StageDataUtil.LoadZonesView(self.m_zoneDict);
  self.mainlineViewModel = nil;
  local suc, mainlineModel = self.m_zoneGroupDict:TryGetValue(CS.Torappu.UI.Stage.ZoneViewType.MAINLINE);
  if suc then
    self.mainlineViewModel = mainlineModel;
  end

  self.firstStepModel:RefreshPlayerData();
  self.secondStepModel:RefreshPlayerData();
  for index, model in pairs(self.missionGroupModelList) do
    model:RefreshPlayerData();
  end

  self.showCompleteAll = MainlineBuffUtil.CheckIfMissionGroupNeedComplete(self.actId);
  
  self.favorUpCharList = {};
  local suc, playerActData = CS.Torappu.PlayerData.instance.data.activity.mainlineBuffActivityList:TryGetValue(self.actId);
  if not suc or playerActData.favorList == nil then
    return;
  end
  for i = 0, playerActData.favorList.Count - 1 do
    table.insert(self.favorUpCharList, i + 1, playerActData.favorList[i]);
  end
end

return MainlineBuffViewModel;