local eutil = CS.Torappu.Lua.Util
local Enemy = CS.Torappu.Battle.Enemy
local Entity = CS.Torappu.Battle.Entity
local Map = CS.Torappu.Battle.Map
local GridPosition = CS.Torappu.GridPosition


local EnemyHotfixer = Class("EnemyHotfixer", HotfixBase)



local function _PresetMapLayerFromSpawnTile(self, route)
  if not Map.hasInstance then
    return
  end
  local spawnPos = route:GetSpawnPosition() + route:GetSpawnOffset()
  local found, spawnTile = Map.instance:TryGetTile(GridPosition.FromVectorPosition(spawnPos))
  if found then
    self.mapLayer = spawnTile.mapLayer
  end
end

function EnemyHotfixer:OnInit()
  if HOTFIX_ENABLE then
    
    xlua.private_accessible(Entity)
    self:Fix_ex(Enemy, "Spawn", function(self, data, handbookData, snapshot, route, options)
      local ok, err = xpcall(_PresetMapLayerFromSpawnTile, debug.traceback, self, route)
      if not ok then
        eutil.LogHotfixError("[EnemyHotfixer] fix Spawn: " .. tostring(err))
      end
      self:Spawn(data, handbookData, snapshot, route, options)
    end)
  end
end

return EnemyHotfixer
