

local AutoChessHelpBattleCntHotfixer = Class("AutoChessHelpBattleCntHotfixer", HotfixBase)

local eutil = CS.Torappu.Lua.Util
local HelpBattleRoundStatus = CS.Torappu.Battle.AutoChess.AutoChessBattleStatusDataModel.HelpBattleRoundStatus

local AutoChessDataCenter = CS.Torappu.Battle.DataCenter.AutoChessDataCenter
local AutoChessGameManager = CS.Torappu.Battle.AutoChess.AutoChessGameManager


local function _GetHelpBattleScheduler()
  local dataCenter = AutoChessDataCenter.instanceOrNull
  local gameManager = AutoChessGameManager.instanceOrNull
  if dataCenter == nil or gameManager == nil or dataCenter.helpBattleData == nil then
    return nil
  end
  local players = dataCenter.battlePlayerIndex
  if players == nil or players.Count <= 0 then
    return nil
  end
  return gameManager.schedulerManager:GetScheduler(players[0])
end

local function _GetCurEnemyCnt()
  local scheduler = _GetHelpBattleScheduler()
  if scheduler == nil then
    return 0
  end
  return scheduler.finishedEnemiesCnt
end

function AutoChessHelpBattleCntHotfixer:OnInit()
  self:Fix(HelpBattleRoundStatus, "get_curEnemyCnt", function(self)
    
    
    local ok, result = xpcall(_GetCurEnemyCnt, debug.traceback)
    if not ok then
      eutil.LogHotfixError("[AutoChessHelpBattleCntHotfixer] get_curEnemyCnt: " .. tostring(result))
      return 0
    end
    return result
  end)
end

return AutoChessHelpBattleCntHotfixer
