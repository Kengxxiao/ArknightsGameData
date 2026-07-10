local eutil = CS.Torappu.Lua.Util

local AphrisRangeHotfixer = Class("AphrisRangeHotfixer", HotfixBase)
local Map = CS.Torappu.Battle.Map
local EntityHashSet = CS.System.Collections.Generic.HashSet(CS.Torappu.Battle.Entity)
local cacheHashSet = EntityHashSet()
local GridPositionHashSet = CS.System.Collections.Generic.HashSet(CS.Torappu.GridPosition)
local enemyGrids = GridPositionHashSet()

local function _IsInstanceOf(obj, csType)
  return obj ~= nil and csType:IsAssignableFrom(obj:GetType())
end
local function _DoFindTargets_DISPOSE(self, mapPos, options, validator)
  local result = CS.Torappu.Battle.BattleController.AllocateEntityList_DISPOSE()
  local gridPosition = CS.Torappu.GridPosition.FromVectorPosition(mapPos)
  local myOwner = self.m_owner
  if eutil.IsDestroyed(myOwner) or myOwner.gridPosition ~= gridPosition then
    return result
  end

  cacheHashSet:Clear()

  for i = 0, self.m_gridPositions.Count - 1 do
    local grid = self.m_gridPositions[i]
    if Map.instance:CheckGridValid(grid) then
      local tile = Map.instance:GetTile(grid)
      local entities = tile:GetEntities_DISPOSE()
      for j = 0, entities.Count - 1 do
        local entity = entities[j]
        if options:VerifyTarget(entity) then
          if validator == nil or validator(entity) then
            cacheHashSet:Add(entity)
          end
        end
      end
      entities:Dispose()
    end
  end

  result:AddRange(cacheHashSet)
  return result
end

local function _TryGetDirChangeTimes(self, entity)
  local times = 0
  local flag, index = self:TryGetGridIndex(entity)
  if not flag then
    return false, times
  end

  if index < 0 then
    return false, times
  end

  times = self.m_dirChangeTimes[index]
  return true, times
end

local function _TryGetGridIndex(self, entity)
  local index = -1
  enemyGrids:Clear()

  if _IsInstanceOf(entity, typeof(CS.Torappu.Battle.Enemy)) and entity.rootSubTiles.Count > 0 then
    enemyGrids:Add(entity.gridPosition)
    for i = 0, entity.rootSubTiles.Count - 1 do
      local subTile = entity.rootSubTiles[i]
      if subTile ~= nil then
        enemyGrids:Add(subTile.gridPosition)
      end
    end
  elseif _IsInstanceOf(entity, typeof(CS.Torappu.Battle.GiantTrap)) then
    for i = 0, entity.locateTiles.Count - 1 do
      local subTile = entity.locateTiles[i]
      if subTile ~= nil then
        enemyGrids:Add(subTile.gridPosition)
      end
    end
  else
    enemyGrids:Add(entity.gridPosition)
  end

  local toRemove = {}
  local gridEnumerator = enemyGrids:GetEnumerator()
  while gridEnumerator:MoveNext() do
    local grid = gridEnumerator.Current
    if not self.m_gridPositionHash:Contains(grid) then
      table.insert(toRemove, grid)
    end
  end
  gridEnumerator:Dispose()
  for i, grid in ipairs(toRemove) do
    enemyGrids:Remove(grid)
  end

  if enemyGrids.Count == 0 then
    return false, index
  end

  local maxIdx = nil
  local enumerator = enemyGrids:GetEnumerator()
  while enumerator:MoveNext() do
    local gridPosition = enumerator.Current
    local idx = self.m_gridPositions:IndexOf(gridPosition)
    if maxIdx == nil or idx > maxIdx then
      maxIdx = idx
    end
  end
  enumerator:Dispose()
  if maxIdx ~= nil then
    index = maxIdx
  end

  return index >= 0, index
end

local function _TryGetExtendTimes(self, entity)
  local times = 0
  local flag, index = self:TryGetGridIndex(entity)
  if not flag then
    return false, times
  end

  if index < 0 then
    return false, times
  end

  times = self.m_extendTimes[index]
  return true, times
end

local function _DoFindTargets_DISPOSE_Xpcall(self, mapPos, options, validator)
  local ok, result = xpcall(_DoFindTargets_DISPOSE, debug.traceback, self, mapPos, options, validator)
  if not ok then
    eutil.LogHotfixError("[_DoFindTargets_DISPOSE] fix " .. tostring(result))
    return CS.Torappu.Battle.BattleController.AllocateEntityList_DISPOSE()
  end
  return result
end

local function _TryGetDirChangeTimes_Xpcall(self, entity)
  local ok, result, times = xpcall(_TryGetDirChangeTimes, debug.traceback, self, entity)
  if not ok then
    eutil.LogHotfixError("[_TryGetDirChangeTimes] fix " .. tostring(result))
    return false, 0
  end
  return result, times
end

local function _TryGetGridIndex_Xpcall(self, entity)
  local ok, result, index = xpcall(_TryGetGridIndex, debug.traceback, self, entity)
  if not ok then
    eutil.LogHotfixError("[_TryGetGridIndex] fix " .. tostring(result))
    return false, -1
  end
  return result, index
end

local function _TryGetExtendTimes_Xpcall(self, entity)
  local ok, result, times = xpcall(_TryGetExtendTimes, debug.traceback, self, entity)
  if not ok then
    eutil.LogHotfixError("[_TryGetExtendTimes] fix " .. tostring(result))
    return false, 0
  end
  return result, times
end

function AphrisRangeHotfixer:OnInit()
  if HOTFIX_ENABLE then
    if xlua and xlua.private_accessible then
      xlua.private_accessible(CS.Torappu.Battle.AphrisRange)
    end
    self:Fix_ex(CS.Torappu.Battle.AphrisRange, "DoFindTargets_DISPOSE", _DoFindTargets_DISPOSE_Xpcall)
    self:Fix_ex(CS.Torappu.Battle.AphrisRange, "TryGetDirChangeTimes", _TryGetDirChangeTimes_Xpcall)
    self:Fix_ex(CS.Torappu.Battle.AphrisRange, "TryGetGridIndex", _TryGetGridIndex_Xpcall)
    self:Fix_ex(CS.Torappu.Battle.AphrisRange, "TryGetExtendTimes", _TryGetExtendTimes_Xpcall)
  end
end

return AphrisRangeHotfixer