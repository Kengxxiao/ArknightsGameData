


local Act7FunBattleFinishEasterEggModel = Class("Act7FunBattleFinishEasterEggModel")












Act7FunBattleFinishViewModel = Class("Act7FunBattleFinishViewModel", UIViewModel)

function Act7FunBattleFinishViewModel:InitData()
  self.stageId = "";
  self.gameData = CS.Torappu.ActivityDB.data.actFunData.act7FunData;
  self.trapCnt = 0;
  self.cardUsedCnt = 0;
  self.defeatedCnt = 0;
  self.spineGroupId = nil;
  self.easterEggModels = {};
  self.hasEasterEgg = false;

  local input = CS.Torappu.Battle.BattleInOut.instance.input;
  local output = CS.Torappu.Battle.BattleInOut.instance.output;
  local finishResp = output.finishResponse;
  local actMeta = output.actMeta;
  local meta = CS.Torappu.Battle.BattleInOut.instance.input.actMeta.meta;

  
  local completeState = finishResp.completeState;
  self.isNormalSuc = completeState == CS.Torappu.PlayerBattleRank.PASS:GetHashCode();
  self.isFailed = completeState <= CS.Torappu.PlayerBattleRank.FAIL:GetHashCode();
  local unlockStages = finishResp.unlockedStages;
  if unlockStages ~= nil then
    for i = 0, unlockStages.Length - 1 do
      local stageId = unlockStages[i];
      CS.Torappu.LocalTrackStore.instance:DoTrackTrigger(CS.Torappu.Activity.Act7fun.Act7FunUtils.ACT7FUN_NEW_STAGE_TRACK_TYPE, stageId);
    end
  end

  meta:SetBool(ActFunMainDlgGroup.KEY_NEXT_STAGE, unlockStages ~= nil and unlockStages.Length > 0);
  
  
  self.stageId = input.stageInfo.stageId;
  local suc1, stageAdditionData = self.gameData.stageAdditionMap:TryGetValue(self.stageId);
  if suc1 and stageAdditionData ~= nil then
    if self.isFailed then
      self.spineGroupId = stageAdditionData.settleLoseSpineGroupId;
    else
      self.spineGroupId = stageAdditionData.settleWinSpineGroupId;
    end
  end
  
  
  local itemTable = nil;
  local respItems = finishResp.rewards;
  if respItems ~= nil and respItems.Count > 0 then
    itemTable = {};
    for idx = 0, respItems.Count - 1 do
      local respItem = respItems[idx];
      local item = self:_CreateItemBundle(respItem.id, respItem.type, respItem.count);
      table.insert(itemTable, item);
    end
    self.m_items = itemTable;
  end

  if itemTable ~= nil then
    meta:SetDataBundleList(ActFunMainDlgGroup.KEY_REWARD, itemTable);
  end

  
  if actMeta == nil then
    return;
  end

  self.trapCnt = actMeta.trapCnt;
  self.cardUsedCnt = actMeta.cardUsedCnt;
  self.defeatedCnt = actMeta.defeatedCnt;

  
  local easterEggIds = actMeta.easterEggIds;
  self.hasEasterEgg = easterEggIds ~= nil and easterEggIds.Count > 0;
  for i = 0, easterEggIds.Count - 1 do
    local id = easterEggIds[i];
    local suc2, eggData = self.gameData.easterEggData:TryGetValue(id);
    if suc2 and eggData ~= nil then
      local eggModel = Act7FunBattleFinishEasterEggModel.new();
      eggModel.charIconId = eggData.charId;
      eggModel.content = eggData.newsDesc;
      table.insert(self.easterEggModels, eggModel);
    else
      LogError("[act7fun] no valid easter egg id: " .. id);
    end
  end
end

function Act7FunBattleFinishViewModel:_CreateItemBundle(id, type, count)
  local bundle = CS.Torappu.DataBundle()
  bundle:SetString("id", id)
  bundle:SetString("type", type:ToString())
  bundle:SetInt("count", count)
  return bundle
end

return Act7FunBattleFinishViewModel