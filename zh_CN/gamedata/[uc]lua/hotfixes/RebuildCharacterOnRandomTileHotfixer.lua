
local RebuildCharacterOnRandomTileHotfixer = Class("RebuildCharacterOnRandomTileHotfixer", HotfixBase)
local BattleController = CS.Torappu.Battle.BattleController
local Blackboard = CS.Torappu.Blackboard
local LifeType = CS.Torappu.Battle.Deck.Card.CardBuff.LifeType
local Direction = CS.Torappu.SharedConsts.Direction
local LitePhysicsUtil = CS.Torappu.Battle.LitePhysicsUtil
local Nodes = CS.Torappu.Battle.Action.Nodes
local RebuildCharacterOnRandomTile = CS.Torappu.Battle.Action.Nodes.RebuildCharacterOnRandomTile
local CharacterType = typeof(CS.Torappu.Battle.Character)
local TileList = CS.System.Collections.Generic.List(CS.Torappu.Battle.Tile)
local DLog = CS.UnityEngine.DLog

local cacheTiles = TileList()

local function _IsInstanceOf(obj, csType)
  return obj ~= nil and csType:IsAssignableFrom(obj:GetType())
end

local function _Execute(self, blackboard, sourceType, snapshot)
  local target = Nodes.GetActionTarget(snapshot, self._target)
  if not _IsInstanceOf(target, CharacterType) or not BattleController.hasInstance then
    return false
  end

  local uid = target.cardUid
  local deck = BattleController.instance:GetDeck(target)
  local card = deck:FindCard(uid)
  target:SetExternWithdrawGainCostFlag(false)

  BattleController.instance:CreateCardBuffByCardWithBlackboard(card, blackboard, card, LifeType.UNTIL_NEXT_SPAWN, true)
  target:Withdraw(false, true, false, false)

  if target.alive then
    return false
  end

  local direction = BattleController.randomImp:Next(4)

  local tiles = LitePhysicsUtil.FindTilesInGlobalRange(nil)
  cacheTiles:Clear()
  cacheTiles:AddRange(tiles)

  for i = cacheTiles.Count - 1, 0, -1 do
    local tile = cacheTiles[i]
    if not card.buildCondition:CheckBuildable(tile, card.data, false, false, card.overflowOccupiedCnt)
        or not tile:CheckBuildable(card.data, false) then
      cacheTiles:RemoveAt(i)
    end
  end

  if cacheTiles.Count <= 0 then
    return false
  end

  local tilePos = BattleController.randomImp:Next(cacheTiles.Count)
  local randTile = cacheTiles[tilePos]
  if randTile == nil then
    return false
  end

  local success, charOrToken = deck:SpawnCharacterOrToken(card, Direction.__CastFrom(direction), randTile, false, false, true)
  if not success or charOrToken == nil then
    DLog.LogError("RebuildCharacter: failed to spawn character")
    return false
  end
  if self._createBuff then
    local myBlackboard = Blackboard(blackboard)
    charOrToken:AddBuff(self._buff, snapshot.source, snapshot.ability, myBlackboard)
  end
  return true
end

local function Execute(self, blackboard, sourceType, snapshot)
  local ok, result = xpcall(_Execute, debug.traceback, self, blackboard, sourceType, snapshot)
  if not ok then
    DLog.LogError("[RebuildCharacterOnRandomTileHotfixer] fix " .. tostring(result))
    return false, snapshot
  end
  return result, snapshot
end

function RebuildCharacterOnRandomTileHotfixer:OnInit()
  if HOTFIX_ENABLE then
    if xlua and xlua.private_accessible then
      xlua.private_accessible(RebuildCharacterOnRandomTile)
    end

    self:Fix_ex(RebuildCharacterOnRandomTile, "Execute", Execute)
  end
end

return RebuildCharacterOnRandomTileHotfixer
