

local AutoChessMainGameInHelpBattleHotfixer = Class("AutoChessMainGameInHelpBattleHotfixer", HotfixBase)

local MainGameInHelpBattle = CS.Torappu.Battle.GameMode.GameModeFactory.AutoChessGameMode.MainGameInHelpBattle

local AutoChessDataCenter = CS.Torappu.Battle.DataCenter.AutoChessDataCenter
local AutoChessGameManager = CS.Torappu.Battle.AutoChess.AutoChessGameManager



local function _ApplyAllChessStatus(self)
  local dataCenter = AutoChessDataCenter.instanceOrNull
  local gameManager = AutoChessGameManager.instanceOrNull
  if dataCenter == nil or gameManager == nil then
    return
  end
  local helpBattleData = dataCenter.helpBattleData
  if helpBattleData == nil or gameManager.isTrainingMode then
    return
  end

  
  local chessInstMap = dataCenter.battleData.chessMapInfo.chessInstMap
  local cachedInsts = {}
  for i = 0, chessInstMap.Count - 1 do
    cachedInsts[#cachedInsts + 1] = chessInstMap:Get(i).Value
  end

  local battleChessStatus = helpBattleData.battleChessStatus
  for i = 1, #cachedInsts do
    local chessInst = cachedInsts[i]
    local found, chessStatus = battleChessStatus:TryGetValue(chessInst.instId)
    if not found then
      if chessInst.validInBattle then
        chessInst.character:Lock():FinishWithNoReason()
      end
    else
      self:_ApplyChessStatus(chessInst, chessStatus)
    end
  end
end

function AutoChessMainGameInHelpBattleHotfixer:OnInit()
  
  xlua.private_accessible(MainGameInHelpBattle)
  self:Fix_ex(MainGameInHelpBattle, "_ApplyChessStatus", function(self, chessInst, chessStatus)
    if chessInst ~= nil then
      
      self:_ApplyChessStatus(chessInst, chessStatus)
      return
    end
    _ApplyAllChessStatus(self)
  end)
end

return AutoChessMainGameInHelpBattleHotfixer
