
local AutoChessGameManagerHotfixer = Class("AutoChessGameManagerHotfixer", HotfixBase)
local util = require("xlua.util")

local AutoChessGameManager = CS.Torappu.Battle.AutoChess.AutoChessGameManager
local GameTaskWithCoroutine = CS.Torappu.Battle.GameMode.GameModeFactory.AutoChessGameMode.GameTaskWithCoroutine
local GameFinishInBattle = CS.Torappu.Battle.GameMode.GameModeFactory.AutoChessGameMode.GameFinishInBattle
local BattleController = CS.Torappu.Battle.BattleController
local Map = CS.Torappu.Battle.Map
local Yields = CS.Torappu.Battle.Yields
local SpeedLevel = CS.Torappu.Battle.SpeedLevel
local CostLockReason = CS.Torappu.Battle.CostLockReason
local PlayerSide = CS.Torappu.PlayerSide
local AutoChessObModel = CS.Torappu.Battle.AutoChess.AutoChessObModel
local AutoChessGameStatus = CS.Torappu.Battle.AutoChess.AutoChessGameStatus

local AutoChessDataCenter = CS.Torappu.Battle.DataCenter.AutoChessDataCenter


local BATTLE_WAIT_UI_TIME = 0.3

local FINISH_BATTLE_EXTRA_WAIT_TIME = 1.2




local function _WaitForFixedSeconds(time)
  local deltaPlayTime = BattleController.deltaPlayTime
  local frameCnt = 1
  if deltaPlayTime > 0 then
    frameCnt = math.max(1, math.floor(time / deltaPlayTime + 0.5))
  end
  for _ = 1, frameCnt do
    coroutine.yield(Yields.sharedWaitForFixedUpdate)
  end
end

local function _GameFinishInBattleCoroutineTask(self)
  return util.cs_generator(function()
    local battleController = BattleController.instance
    if battleController == nil then
      return
    end
    Map.instance:BeginBatchTileUpdate(true  )
    _WaitForFixedSeconds(BATTLE_WAIT_UI_TIME)

    local gameManager = AutoChessGameManager.instanceOrNull
    gameManager:_FinishAllUnits()
    gameManager.dataCenter:OnBattleFinish()
    gameManager.dataBridge:OnBattleFinish()
    coroutine.yield(gameManager.dummyManager:FinishAllDummy(true  ))
    gameManager.schedulerManager:Reset()
    _WaitForFixedSeconds(FINISH_BATTLE_EXTRA_WAIT_TIME)

    battleController.speedLevel = SpeedLevel.STANDARD
    battleController:LockCostIncreasement(true, CostLockReason.AUTOCHESS_REST)

    battleController:SetCurrentPlayerSide(PlayerSide.DEFAULT)
    local playerIndex = gameManager.dataCenter.realPlayerIndex
    gameManager.dataCenter:UpdatePlayerBattleData(playerIndex)

    coroutine.yield(gameManager.effectManager:PlayEffectsOnStateChange())
    coroutine.yield(Yields.sharedWaitForFixedUpdate)
    Map.instance:EndBatchTileUpdate(false)
    self.m_coroutineFinished = true
  end)
end





local s_cachedRealIndex = 0

local function _ResetCachedRealPlayerIndex()
  s_cachedRealIndex = 0
end


local function _ComputeRealPlayerIndex(obModel)
  if obModel.hasDeadObIndex then
    return obModel.m_deadObIndex
  end
  return obModel.m_selfPlayerIndex
end



local function _RefreshAndCacheRealPlayerIndex(obModel)
  local gameStatus = AutoChessGameStatus.instanceOrNull
  if gameStatus ~= nil and gameStatus.inBattleState then
    s_cachedRealIndex = _ComputeRealPlayerIndex(obModel)
  else
    s_cachedRealIndex = 0
  end
end

local function _GetRealPlayerIndex(obModel)
  if s_cachedRealIndex > 0 then
    return s_cachedRealIndex
  end
  return _ComputeRealPlayerIndex(obModel)
end




local function _RefreshSpEnemyPreviewIfLoading(dataCenter, playerIndex)
  local gameManager = AutoChessGameManager.instanceOrNull
  local gameStatus = AutoChessGameStatus.instanceOrNull
  if gameManager == nil or gameStatus == nil then
    return
  end
  local enemyPreviewer = gameManager.enemyPreviewer
  if playerIndex == dataCenter.playerViewIndex and gameStatus.inMainPrepareState and enemyPreviewer.inLoading then
    enemyPreviewer:RefreshSpEnemy()
  end
end

function AutoChessGameManagerHotfixer:OnInit()
  
  xlua.private_accessible(AutoChessGameManager)
  
  xlua.private_accessible(GameTaskWithCoroutine)
  xlua.private_accessible(GameFinishInBattle)

  
  self:Fix(AutoChessGameManager, "_FinishUnitInRecycle", function(self)
  end)

  
  self:Fix(AutoChessGameManager, "FinishBattle", function(self)
  end)

  
  self:Fix(GameFinishInBattle, "CoroutineTask", function(self)
    return _GameFinishInBattleCoroutineTask(self)
  end)

  
  self:Fix_ex(AutoChessGameManager, "_OnGameStateChanged", function(self, newStateId, oldStateId)
    _RefreshAndCacheRealPlayerIndex(self.dataCenter.obModel)
    self:_OnGameStateChanged(newStateId, oldStateId)
  end)

  
  
  xlua.private_accessible(AutoChessObModel)
  self:Fix(AutoChessObModel, "get_realPlayerIndex", function(self)
    return _GetRealPlayerIndex(self)
  end)

  
  
  self:Fix_ex(AutoChessGameManager, "Start", function(self)
    _ResetCachedRealPlayerIndex()
    self:Start()
  end)
  self:Fix_ex(AutoChessGameManager, "Dispose", function(self)
    _ResetCachedRealPlayerIndex()
    self:Dispose()
  end)

  
  self:Fix_ex(AutoChessDataCenter, "UpdatePlayerBattleData", function(self, playerIndex)
    self:UpdatePlayerBattleData(playerIndex)
    _RefreshSpEnemyPreviewIfLoading(self, playerIndex)
  end)
end

function AutoChessGameManagerHotfixer:OnDispose()
  _ResetCachedRealPlayerIndex()
end

return AutoChessGameManagerHotfixer
