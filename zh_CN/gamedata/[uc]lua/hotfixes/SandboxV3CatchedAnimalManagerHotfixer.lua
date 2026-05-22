


local SandboxV3CatchedAnimalManagerHotfixer = Class("SandboxV3CatchedAnimalManagerHotfixer", HotfixBase)
local HashSet = CS.System.Collections.Generic.HashSet
local HashSet_1_System_Int32 = HashSet(CS.System.Int32)
local Ranch = CS.Torappu.Battle.SandboxV3.Ranch

local function _HandleUnionFence(self, character)
  local adjacentRanches = HashSet_1_System_Int32()
  local firstRanchId = nil
  local pos = character.gridPosition
  local neighbors = {
    {row = pos.row + 1, col = pos.col},
    {row = pos.row - 1, col = pos.col},
    {row = pos.row, col = pos.col + 1},
    {row = pos.row, col = pos.col - 1},
  }

  for _, neighbor in ipairs(neighbors) do
    local neighborPos = CS.Torappu.GridPosition(neighbor.row, neighbor.col)
    local ok, neighborUnitId = self.m_tileToUnitMap:TryGetValue(neighborPos, nil)
    if ok then
      local neighborUnit = self.m_units[neighborUnitId]
      if neighborUnit.isValid and self:_IsUnionFence(neighborUnit:Lock().id) then
        local ok2, ranchId = self.m_unitToRanchMap:TryGetValue(neighborUnitId, nil)
        if ok2 then
          adjacentRanches:Add(ranchId)
          if firstRanchId == nil then
            firstRanchId = ranchId
          end
        end
      end
    end

    if adjacentRanches.Count == 0 then
      local newRanchId = self.m_nextRanchId + 1
      self.m_nextRanchId = newRanchId
      local ranch = Ranch(newRanchId)
      ranch.unitIds:Add(character.instanceUid)
      ranch.occupiedTilePos:Add(pos)
      self.m_ranches[newRanchId] = ranch
      self.m_unitToRanchMap[character.instanceUid] = newRanchId
    elseif adjacentRanches.Count == 1 then
      local ranch = self.m_ranches[firstRanchId]
      ranch.unitIds:Add(character.instanceUid)
      ranch.occupiedTilePos:Add(pos)
      self.m_unitToRanchMap[character.instanceUid] = firstRanchId
    else
      self._MergeRanches(adjacentRanches, character)
    end
  end
end
function SandboxV3CatchedAnimalManagerHotfixer:OnInit()
  if HOTFIX_ENABLE then
    if xlua and xlua.private_accessible then
      xlua.private_accessible(CS.Torappu.Battle.SandboxV3.SandboxV3CatchedAnimalManager)
    end
    self:Fix_ex(CS.Torappu.Battle.SandboxV3.SandboxV3CatchedAnimalManager, "_HandleUnionFence", _HandleUnionFence)
  end
end

return SandboxV3CatchedAnimalManagerHotfixer