local BrigidS2ParacurveMovementHotfixer = Class("BrigidS2ParacurveMovementHotfixer", HotfixBase)

local function __CheckProjectileMissTarget(self)
  local res = self:_CheckProjectileMissTarget()
  return res and (not self.m_isComeBack)
end
function BrigidS2ParacurveMovementHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.Projectiles.BrigidS2ParacurveMovement)
  self:Fix_ex(CS.Torappu.Battle.Projectiles.BrigidS2ParacurveMovement, "_CheckProjectileMissTarget", function(self)
    local ok, result = xpcall(__CheckProjectileMissTarget, debug.traceback, self)
    if ok then
      return result
    end
  end)
end

function BrigidS2ParacurveMovementHotfixer:OnDispose()
end

return BrigidS2ParacurveMovementHotfixer