
local RO4DLC2BounceAbilityHotfixer = Class("RO4DLC2BounceAbilityHotfixer", HotfixBase)

local function Fix_ApplyCollision(self, collision, targetMapPos, source)
  local enemy = self.m_bounceEnemy:Lock()
  if enemy ~= nil then
    if source ~= nil then
      local enemyVelocity = enemy:GetVelocity()
      local curEnemyDir = CS.Torappu.Battle.MapUtil.ParseDirection(enemyVelocity.normalized)
      local standardOldDir = CS.Torappu.SharedConsts.FOUR_WAYS[curEnemyDir:GetHashCode()]
      local inverseDir = -standardOldDir
      local predictNextPos = enemy.mapPosition + inverseDir * 0.25 + inverseDir * enemyVelocity.magnitude * 0.017
      local predictTile = CS.Torappu.Battle.Map.instance:GetTile(CS.Torappu.GridPosition.FromVectorPosition(predictNextPos))
      if predictTile == nil or predictTile.heightType == CS.Torappu.TileData.HeightType.HIGHLAND then
        return
      end

      enemy.RO4DLC2TypeDescriteForceInfo.direction = inverseDir
      enemy:ApplyForce(source, enemy.RO4DLC2TypeDescriteForceInfo)
    else
      local tile = collision:GetComponentInParent(typeof(CS.Torappu.Battle.Tile))
      if tile ~= nil then
        local rawDir = CS.UnityEngine.Vector2(enemy.mapPosition.x - tile.mapPosition.x, enemy.mapPosition.y - tile.mapPosition.y)
        local rawDirNorm = rawDir.normalized;
        local newDirEnum = CS.Torappu.Battle.MapUtil.ParseDirection(rawDirNorm)
        local newDir = CS.Torappu.SharedConsts.FOUR_WAYS[newDirEnum:GetHashCode()]
        enemy.RO4DLC2TypeDescriteForceInfo.direction = newDir
        enemy:ApplyForce(source, enemy.RO4DLC2TypeDescriteForceInfo)
      end
    end
  end
end

function RO4DLC2BounceAbilityHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.RO4DLC2BounceEnemy)
  xlua.private_accessible(CS.Torappu.Battle.Abilities.RO4DLC2BounceAbility)
  xlua.private_accessible(CS.Torappu.Battle.Tile)
  self:Fix_ex(CS.Torappu.Battle.Abilities.RO4DLC2BounceAbility, "_ApplyCollision", function(self, collision, targetMapPos, source)
    local ok, errorInfo = xpcall(Fix_ApplyCollision, debug.traceback, self, collision, targetMapPos, source)
    if not ok then
      LogError("[RO4DLC2BounceAbilityHotfixer] fix" .. errorInfo)
    end
  end)
end

function RO4DLC2BounceAbilityHotfixer:OnDispose()
end

return RO4DLC2BounceAbilityHotfixer