local EtlchiHotfixer = Class("EtlchiHotfixer", HotfixBase)

local function _GetNearestEndPointTile(self, sourcePos, motionMode, avoidCheckReachable)
  if avoidCheckReachable then 
    return CS.Torappu.GridPosition.ZERO, null
  end
  return self:GetNearestEndPointTile(sourcePos, motionMode, avoidCheckReachable)
end

local function _EnsureDmgOrHealExecute(self, blackboard, sourceType, snapshot)
  local snapshotModifier = snapshot.modifier
  local snapshotSource = snapshot.source
  local localSnapshot = snapshot
  if not snapshotModifier.isCancelled and snapshotModifier.damageType == CS.Torappu.Battle.DamageType.PURE and snapshotSource ~= nil and string.find(snapshotSource.name, "entlec") ~= nil then
    snapshotModifier.value = blackboard:GetFpOrDefault("value", snapshotModifier.value)
    localSnapshot.modifier = snapshotModifier
    snapshot = localSnapshot
    return true, snapshot
  end
  return self:Execute(blackboard, sourceType, snapshot)
end

function EtlchiHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.Map)
  self:Fix_ex(CS.Torappu.Battle.Map, "GetNearestEndPointTile", function(self, sourcePos, motionMode, avoidCheckReachable)
    local ok, endPos, route = xpcall(_GetNearestEndPointTile, debug.traceback, self, sourcePos, motionMode, avoidCheckReachable)
    return endPos, route
  end)
  xlua.private_accessible(CS.Torappu.Battle.Action.Nodes.EnsureDmgOrHeal)
  self:Fix_ex(CS.Torappu.Battle.Action.Nodes.EnsureDmgOrHeal, "Execute", function(self, blackboard, sourceType, snapshot)
    local ok, res, snapshot = xpcall(_EnsureDmgOrHealExecute, debug.traceback, self, blackboard, sourceType, snapshot)
    if not ok then
      LogError("[_EnsureDmgOrHealExecute] fix" .. res)
    end
    return res, snapshot
  end)
end

function EtlchiHotfixer:OnDispose()
end

return EtlchiHotfixer