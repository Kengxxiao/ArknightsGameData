local luaUtils = CS.Torappu.Lua.Util
local rapidjson = require("rapidjson")
















local ActFun3BattleFinishViewModel = Class("ActFun3BattleFinishViewModel");

function ActFun3BattleFinishViewModel:InitData()
  local outPut = CS.Torappu.Battle.BattleInOut.instance.output;
  local finishResp = outPut.finishResponse;
  local rankData = finishResp.rank;
  self.m_stageId = CS.Torappu.Battle.BattleInOut.instance.input.stageInfo.stageId;
  self.m_isWin = outPut.battleRank ~= CS.Torappu.PlayerBattleRank.FAIL;
  self.m_inRank = finishResp.inRank;
  self.m_score = finishResp.score;
  self.m_stageCode = CS.Torappu.Battle.BattleInOut.instance.input.stageInfo.code;
  self.m_playerName = string.format("Dr.%s", CS.Torappu.PlayerData.instance.data.status.nickName);
  local itemTable = nil
  local respItems = finishResp.firstRewards
  if respItems ~= nil and respItems.Count > 0 then
    itemTable = {}
    for idx = 0, respItems.Count - 1 do
      local respItem = respItems[idx]
      local item = self:_CreateItemBundle(respItem.id, respItem.type, respItem.count)
      table.insert(itemTable, item)
    end
    self.m_items = itemTable
  end

  if itemTable ~= nil then
    local meta = CS.Torappu.Battle.BattleInOut.instance.input.actMeta.meta
    meta:SetDataBundleList(ActFunMainDlgGroup.KEY_REWARD, itemTable)
  end

  local scoreArray = finishResp.scoreItem;
  if scoreArray ~= nil and scoreArray.Length == 6 then
    if scoreArray[0] ~= nil then
      self.m_enemyCnt = scoreArray[0]
    end
    if scoreArray[1] ~= nil then
      self.m_enemyScore = scoreArray[1]
    end
    if scoreArray[2] ~= nil then
      self.m_bossCnt = scoreArray[2]
    end
    if scoreArray[3] ~= nil then
      self.m_boosScore = scoreArray[3]
    end
    if scoreArray[4] ~= nil then
      self.m_time = scoreArray[4]
    end
    if scoreArray[5] ~= nil then
      self.m_timeScore = scoreArray[5]
    end
  end
  if finishResp.rank ~= nil then
    self.m_rank = rankData
  end
end

function ActFun3BattleFinishViewModel:_CreateItemBundle(id, type, count)
  local bundle = CS.Torappu.DataBundle()
  bundle:SetString("id", id)
  bundle:SetString("type", type:ToString())
  bundle:SetInt("count", count)
  return bundle
end

return ActFun3BattleFinishViewModel