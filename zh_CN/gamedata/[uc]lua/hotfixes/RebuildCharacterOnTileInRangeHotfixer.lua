
local RebuildCharacterOnTileInRangeHotfixer = Class("RebuildCharacterOnTileInRangeHotfixer", HotfixBase)
local BattleController = CS.Torappu.Battle.BattleController
local Blackboard = CS.Torappu.Blackboard
local BlackboardKeys = CS.Torappu.BlackboardKeys
local CardBuffLifeType = CS.Torappu.Battle.Deck.Card.CardBuff.LifeType
local Direction = CS.Torappu.SharedConsts.Direction
local LitePhysicsUtil = CS.Torappu.Battle.LitePhysicsUtil
local RandomUtil = CS.Torappu.RandomUtil
local Nodes = CS.Torappu.Battle.Action.Nodes
local RebuildCharacterOnTileInRange = CS.Torappu.Battle.Action.Nodes.RebuildCharacterOnTileInRange
local CharacterType = typeof(CS.Torappu.Battle.Character)
local UnitType = typeof(CS.Torappu.Battle.Unit)
local TileList = CS.System.Collections.Generic.List(CS.Torappu.Battle.Tile)
local DLog = CS.UnityEngine.DLog
local DIRECTION_E_NUM = 4

local cacheTiles = TileList()

local function _IsInstanceOf(obj, csType)
  return obj ~= nil and csType:IsAssignableFrom(obj:GetType())
end

local function _DirectionToInt(direction)
  if direction == Direction.UP then
    return 0
  end
  if direction == Direction.RIGHT then
    return 1
  end
  if direction == Direction.DOWN then
    return 2
  end
  if direction == Direction.LEFT then
    return 3
  end
  return DIRECTION_E_NUM
end

local function _GetLocateDirection(dx, dy)
  if dx == 0 then
    return dy > 0 and Direction.DOWN or Direction.UP
  end
  if dy == 0 then
    return dx > 0 and Direction.LEFT or Direction.RIGHT
  end
  return dy > 0 and Direction.DOWN or Direction.UP
end

local function _ShuffleTiles(tiles)
  local length = tiles.Count
  for i = 0, length - 1 do
    local swapI = RandomUtil.Range(i, length)
    local tmp = tiles[i]
    tiles[i] = tiles[swapI]
    tiles[swapI] = tmp
  end
end

local function _Execute(self, blackboard, sourceType, snapshot)
  local target = Nodes.GetActionTarget(snapshot, self._target)
  local owner = Nodes.GetActionTarget(snapshot, self._owner)
  if not _IsInstanceOf(target, CharacterType) or not _IsInstanceOf(owner, UnitType) then
    return false
  end

  local uid = target.cardUid
  local deck = BattleController.instance:GetDeck(target)
  local card = deck:FindCard(uid)
  local direction = target.direction
  local pos = owner.gridPosition

  target:SetExternWithdrawGainCostFlag(false)
  BattleController.instance:CreateCardBuffByCardWithBlackboard(card, blackboard, card, CardBuffLifeType.UNTIL_NEXT_SPAWN, true)
  target:Withdraw(false, true, false, false)
  if target.alive then
    return false
  end

  local tileList = LitePhysicsUtil.FindTilesInBox(self._rangeId, pos, owner.direction, nil)
  cacheTiles:Clear()
  cacheTiles:AddRange(tileList)

  for i = cacheTiles.Count - 1, 0, -1 do
    local tile = cacheTiles[i]
    if not card.buildCondition:CheckBuildable(tile, card.data, false, false, card.overflowOccupiedCnt) then
      cacheTiles:RemoveAt(i)
    end
  end

  if cacheTiles.Count <= 0 then
    return false
  end

  _ShuffleTiles(cacheTiles)
  local buildTile = cacheTiles[0]
  local locateDirection
  if self._rotateBuildDirection then
    local directionAdditionValue = blackboard:GetIntOrDefault(BlackboardKeys.VALUE, 0)
    if self._randomDirection then
      locateDirection = Direction.__CastFrom(BattleController.randomImp:Range(0, DIRECTION_E_NUM))
    else
      locateDirection = Direction.__CastFrom(_DirectionToInt(direction) + directionAdditionValue)
    end
  else
    local dx = buildTile.gridPosition.col - owner.gridPosition.col
    local dy = buildTile.gridPosition.row - owner.gridPosition.row
    locateDirection = _GetLocateDirection(dx, dy)
  end

  local success, charOrToken = deck:SpawnCharacterOrToken(card, locateDirection, buildTile, false, false, true)
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
    DLog.LogError("[RebuildCharacterOnTileInRangeHotfixer] fix " .. tostring(result))
    return false, snapshot
  end
  return result, snapshot
end

function RebuildCharacterOnTileInRangeHotfixer:OnInit()
  if HOTFIX_ENABLE then
    if xlua and xlua.private_accessible then
      xlua.private_accessible(RebuildCharacterOnTileInRange)
    end

    self:Fix_ex(RebuildCharacterOnTileInRange, "Execute", Execute)
  end
end

return RebuildCharacterOnTileInRangeHotfixer