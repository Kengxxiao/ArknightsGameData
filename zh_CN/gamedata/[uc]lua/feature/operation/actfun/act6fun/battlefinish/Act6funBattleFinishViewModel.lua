




















local Act6FunBattleFinishAchieveItemModel = Class("Act6FunBattleFinishAchieveItemModel")

local Act6funBattleFinishViewModel = Class("Act6funBattleFinishViewModel")

local ACT6FUN_STAGE_COMPLETE_STATE = {
  FAIL = 1,
  PASS = 2,
  COMPLETE = 3,
}

function Act6funBattleFinishViewModel:InitData()
  self.achieveItemViewModelList = {};

  local act6FunData = CS.Torappu.ActivityDB.data.actFunData.act6FunData;
  if act6FunData == nil then
    return;
  end
  local constData = act6FunData.constData;
  if constData == nil then
    return;
  end

  local playerData = CS.Torappu.PlayerData.instance.data.playerAprilFool.actFun6;
  local input = CS.Torappu.Battle.BattleInOut.instance.input;
  local outPut = CS.Torappu.Battle.BattleInOut.instance.output;
  local finishResp = outPut.finishResponse;

  local stageTotalGetAchivementCount = 0;
  for _, playerStage in pairs(playerData.stages) do
    if playerStage.achievements ~= nil then
      stageTotalGetAchivementCount = stageTotalGetAchivementCount + playerStage.achievements.Count;
    end
  end

  self.stageId = input.stageInfo.stageId;
  local suc, stagePlayerData = playerData.stages:TryGetValue(self.stageId);
  if not suc then
    LogError("[Act6funBattleFinishViewModel]Can't find stagePlayerData:" .. self.stageId);
    return;
  end
  local additionData = self:_GetStageAdditionData(act6FunData.stageAdditionMap, self.stageId);
  if additionData == nil then
    return;
  end
  self.previewCharPicId = additionData.previewCharPicId;

  self.actId = input.actMeta.activityId;
  self.completeState = finishResp.completeState;
  self.isSuc = self.completeState >= ACT6FUN_STAGE_COMPLETE_STATE.PASS;
  self.isFail = self.completeState <= ACT6FUN_STAGE_COMPLETE_STATE.FAIL;
  self.curStageGetCoinCnt = finishResp.coin;
  self.passTime = -1;
  if self.isSuc then
    self.passTime = finishResp.passSec;
  end
  self.code = input.stageInfo.code;
  self.name = input.stageInfo.name;
  self.curStageGetStarCount = 0;
  local achievements = stagePlayerData.achievements;
  if achievements ~= nil then
    self.curStageGetStarCount = achievements.Count;
  end
  self.curStageStarMaxCount = 0;
  local achivementDataList = self:_GetStageAchivementListData(act6FunData.stageAchievementMap, self.stageId);
  if achivementDataList ~= nil then
    self.curStageStarMaxCount = achivementDataList.Count;
    for i = 0, self.curStageStarMaxCount - 1 do
      local achieveData = achivementDataList[i];
      local achievementId = achieveData.achievementId;
      local achieveItemInfo = Act6FunBattleFinishAchieveItemModel.new();
      achieveItemInfo.achieveId = achievementId;
      achieveItemInfo.sortId = achieveData.sortId;
      achieveItemInfo.description = achieveData.description;
      achieveItemInfo.hasComplete = self:_IsAchieveComplete(achievements, achievementId);
      table.insert(self.achieveItemViewModelList, achieveItemInfo)
    end
    table.sort(self.achieveItemViewModelList, function(a, b)
      local isSortEqual = a.sortId == b.sortId;
      if isSortEqual then
        return a.achieveId < b.achieveId;
      else
        return a.sortId < b.sortId;
      end
    end)
  end

  self.isNewRecord = finishResp.newRecord;
  self.curAchivePoint = stageTotalGetAchivementCount;
  self.achievementMaxCount = constData.achievementMaxNumber;
end


function Act6funBattleFinishViewModel:_GetStageAchivementListData(stageAchievementMap, stageId)
  if stageAchievementMap == nil then
    return nil;
  end
  local suc, dataList = stageAchievementMap:TryGetValue(stageId);
  if not suc then
    LogError("[Act6funBattleFinishViewModel]Can't find stage achivement data:" .. stageId);
    return nil;
  end
  return dataList;
end

function Act6funBattleFinishViewModel:_GetStageAdditionData(stageAdditionMap, stageId)
  if stageAdditionMap == nil then
    return nil;
  end
  local suc, data = stageAdditionMap:TryGetValue(stageId);
  if not suc then
    LogError("[Act6funBattleFinishViewModel]Can't find stage addition data:" .. stageId);
    return nil;
  end
  return data;
end

function Act6funBattleFinishViewModel:_IsAchieveComplete(playerAchieveInfos, achieveId)
  if playerAchieveInfos == nil or achieveId == nil then
    return false;
  end
  for achieveIdKey, _ in pairs(playerAchieveInfos) do
    if achieveIdKey == achieveId then
      return true;
    end
  end
  return false;
end

return Act6funBattleFinishViewModel