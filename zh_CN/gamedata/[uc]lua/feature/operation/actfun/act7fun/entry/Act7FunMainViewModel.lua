






local Act7FunMainStageModel = Class("Act7FunMainStageModel")






Act7FunMainViewModel = Class("Act7FunMainViewModel", UIViewModel)

function Act7FunMainViewModel:InitData()
  self.gameData = CS.Torappu.ActivityDB.data.actFunData.act7FunData;
  self.useWinStyle = false;
  self.displaySpineGroupId = nil;
  self.stageModels = {};

  
  self:_InitStageModels();
  self:RefreshData();
end

function Act7FunMainViewModel:RefreshData()
  if self.gameData == nil then
    return;
  end

  self.useWinStyle = CS.Torappu.Activity.Act7fun.Act7FunUtils:IsWinStyle();
  local displayStageId = self:_FindDisplayStageId();

  for stageId, stageModel in pairs(self.stageModels) do
    local playerStageState = self:_LoadPlayerStageState(stageId);
    stageModel.isUnlocked = playerStageState >= CS.Torappu.PlayerStageState.UNLOCKED:GetHashCode();
    stageModel.hasPassed = playerStageState >= CS.Torappu.PlayerStageState.PASS:GetHashCode();
    stageModel.hasPerfect = playerStageState == CS.Torappu.PlayerStageState.COMPLETE:GetHashCode();

    if stageId == displayStageId then
      self.displaySpineGroupId = stageModel.spineGroupId;
    end
  end
end

function Act7FunMainViewModel:_InitStageModels()
  local stages = CS.Torappu.ActivityDB.data.actFunData.stages;
  local stageAdditionMap = self.gameData.stageAdditionMap;
  if stageAdditionMap == nil or stages == nil then
    return
  end
  local iter = stageAdditionMap:GetEnumerator();
  while iter:MoveNext() do
    local stageId = iter.Current.Key;
    local stageAdditionData = iter.Current.Value;
    local stageModel = self:_CreateStageModel(stageId, stageAdditionData);
    self.stageModels[stageId] = stageModel;
  end
end

function Act7FunMainViewModel:_CreateStageModel(stageId, stageAdditionData)
  local suc1, stageData = CS.Torappu.ActivityDB.data.actFunData.stages:TryGetValue(stageId);
  if not suc1 then
    return nil;
  end
  local stageModel = Act7FunMainStageModel.new();
  stageModel.stageId = stageId;
  stageModel.stageData = stageData;
  stageModel.spineGroupId = stageAdditionData.homepageSpineGroupId;

  
  stageModel.isUnlocked = false;
  stageModel.hasPassed = false;
  stageModel.hasPerfect = false;

  return stageModel;
end

function Act7FunMainViewModel:_LoadPlayerStageState(stageId)
  local playerAprilFool = CS.Torappu.PlayerData.instance.data.playerAprilFool;
  if playerAprilFool == nil then
    return -1;
  end
  local actFun7data = playerAprilFool.actFun7;
  local actFun7dataStages = actFun7data.stages;
  if actFun7dataStages == nil then
    return -1;
  end
  local ok, stageState = actFun7dataStages:TryGetValue(stageId);
  if ok and stageState ~= nil then
    return stageState:GetHashCode();
  end
  return -1;
end

function Act7FunMainViewModel:_FindDisplayStageId()
  local defaultStageId = self.gameData.constData.defaultStage;
  local playerAprilFool = CS.Torappu.PlayerData.instance.data.playerAprilFool;
  if playerAprilFool == nil then
    return defaultStageId;
  end
  local actFun7data = playerAprilFool.actFun7;
  local actFun7dataStages = actFun7data.stages;
  if actFun7dataStages == nil then
    return defaultStageId;
  end
  local retStageId = defaultStageId;
  for stageId, playerStageState in pairs(actFun7dataStages) do
    if playerStageState:GetHashCode() >= CS.Torappu.PlayerStageState.PASS:GetHashCode() then
      retStageId = stageId;
    end
  end
  return retStageId;
end

return Act7FunMainViewModel