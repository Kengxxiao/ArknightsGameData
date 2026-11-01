local AutoChessBattleUIController = CS.Torappu.UI.AutoChess.Battle.AutoChessBattleUIController
local AutoChessBattleUIHUDModel = CS.Torappu.UI.AutoChess.Battle.AutoChessBattleUIHUDModel
local AutoChessBattlePlayerStatusGroupModel = CS.Torappu.UI.AutoChess.Battle.AutoChessBattlePlayerStatusGroupModel
local AutoChessBattleMapLayer = CS.Torappu.Battle.AutoChess.AutoChessGameStatus.AutoChessBattleMapLayer
local ActAutoChessEntryViewModel = CS.Torappu.Activity.AutoChess.ActAutoChessEntryViewModel
local AutoChessLocalCache = CS.Torappu.UI.AutoChess.AutoChessLocalCache
local AVGController = CS.Torappu.AVG.AVGController
local eutil = CS.Torappu.Lua.Util


local AutoChessHotfixer = Class("AutoChessHotfixer", HotfixBase)







local _ObTargetLogTag = "[AutoChessHotfixer][ObTarget]"

local function _ResolveJointBattleViewPlayerIdx(mapLayer, playerViewIndex)
  if mapLayer == AutoChessBattleMapLayer.MID then
    return -1
  end
  return playerViewIndex
end

local function _CalcBondInfoIdxFix(self, dataCenter, gameStatus)
  local tgtIdx = dataCenter.playerViewIndex
  if gameStatus.inHelpBattleState or gameStatus.inBossBattleState then
    tgtIdx = _ResolveJointBattleViewPlayerIdx(gameStatus.battleMapLayer, dataCenter.playerViewIndex)
  end
  return tgtIdx
end

local function _UpdateObTargetPlayerFix(self, dataCenter, gameStatus)
  local targetIdx = self.m_playerViewIdx
  local mapLayer = self.m_mapLayer
  if gameStatus.inHelpBattleState then
    targetIdx = _ResolveJointBattleViewPlayerIdx(mapLayer, dataCenter.playerViewIndex)
  elseif gameStatus.inBossBattleState then
    if mapLayer == AutoChessBattleMapLayer.MID then
      targetIdx = -1
    elseif self.m_playerViewIdx <= 0 then
      targetIdx = _ResolveJointBattleViewPlayerIdx(mapLayer, dataCenter.playerViewIndex)
    end
  end
  self.m_obTargetPlayer = self:_FindPlayerStatusModel(targetIdx)
end

local function _InitObTargetFixes(self)
  xlua.private_accessible(AutoChessBattleUIHUDModel)
  xlua.private_accessible(AutoChessBattlePlayerStatusGroupModel)

  self:Fix_ex(AutoChessBattleUIHUDModel, "_CalcBondInfoIdx", function(self, dataCenter, gameStatus)
    local ok, result = xpcall(_CalcBondInfoIdxFix, debug.traceback, self, dataCenter, gameStatus)
    if not ok then
      eutil.LogHotfixError(_ObTargetLogTag .. " _CalcBondInfoIdx: " .. result)
      return self:_CalcBondInfoIdx(dataCenter, gameStatus)
    end
    return result
  end)

  self:Fix_ex(AutoChessBattlePlayerStatusGroupModel, "_UpdateObTargetPlayer", function(self, dataCenter, gameStatus)
    local ok, err = xpcall(_UpdateObTargetPlayerFix, debug.traceback, self, dataCenter, gameStatus)
    if not ok then
      eutil.LogHotfixError(_ObTargetLogTag .. " _UpdateObTargetPlayer: " .. err)
      self:_UpdateObTargetPlayer(dataCenter, gameStatus)
    end
  end)
end






local _UIControllerLogTag = "[AutoChessHotfixer][UIController]"

local function _OnOpenPlayerDetailFix(self)
  local viewModel = self.m_modelProperty.Value
  if viewModel ~= nil then
    local uiStatus = viewModel.uiStatus
    if uiStatus ~= nil and uiStatus.inBattleWaiting then
      return
    end
  end
  self:_OnOpenPlayerDetail()
end

local function _InitUIControllerFixes(self)
  xlua.private_accessible(AutoChessBattleUIController)

  self:Fix_ex(AutoChessBattleUIController, "_OnOpenPlayerDetail", function(self)
    local ok, err = xpcall(_OnOpenPlayerDetailFix, debug.traceback, self)
    if not ok then
      eutil.LogHotfixError(_UIControllerLogTag .. " _OnOpenPlayerDetail: " .. err)
      self:_OnOpenPlayerDetail()
    end
  end)
end







local _EntryMatchBanAlertLogTag = "[AutoChessHotfixer][EntryMatchBanAlert]"
local EntryViewModelStatus = ActAutoChessEntryViewModel.Status

local function _CheckIfNeedShowMatchBanAlertFix(self)
  if AVGController.instance.isRunning then
    return false
  end
  if self.isWaitRetry or self.status == EntryViewModelStatus.TIME_OUT then
    return false
  end
  if self.multiRemainTs <= 0 then
    return false
  end
  local cachedBannedUntilTs = AutoChessLocalCache.instance:GetMatchBannedUtilTs(self.actId)
  if cachedBannedUntilTs == self.multiModeProtectTs then
    return false
  end
  return true
end

local function _InitEntryViewModelFixes(self)
  xlua.private_accessible(ActAutoChessEntryViewModel)

  self:Fix_ex(ActAutoChessEntryViewModel, "_CheckIfNeedShowMatchBanAlert", function(self)
    local ok, result = xpcall(_CheckIfNeedShowMatchBanAlertFix, debug.traceback, self)
    if not ok then
      eutil.LogHotfixError(_EntryMatchBanAlertLogTag .. " _CheckIfNeedShowMatchBanAlert: " .. result)
      return self:_CheckIfNeedShowMatchBanAlert()
    end
    return result
  end)
end

function AutoChessHotfixer:OnInit()
  _InitObTargetFixes(self)
  _InitUIControllerFixes(self)
  _InitEntryViewModelFixes(self)
end

function AutoChessHotfixer:OnDispose()
end

return AutoChessHotfixer
