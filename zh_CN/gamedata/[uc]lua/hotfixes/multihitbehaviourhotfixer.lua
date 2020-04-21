local eutil = CS.Torappu.Lua.Util

---@class MultiHitBehaviourHotfixer:HotfixBase
local MultiHitBehaviourHotfixer = Class("MultiHitBehaviourHotfixer", HotfixBase)

local function _DoTargetStayFix(self, target)
  if self.projectile == nil then
    return
  end


  if target ~= nil and target.alive and self._targetOptions:VerifyTargetWithoutCheckingTargetSide(target) then
    self:DealHitTarget(target, false)
  end
end

function MultiHitBehaviourHotfixer:OnInit()
  self:Fix_ex(CS.Torappu.Battle.Projectiles.MultiHitBehaviour, "_DoTargetStay", function(self, target)
    local ok, error = xpcall(_DoTargetStayFix,debug.traceback,self, target)
    if not ok then
      eutil.LogError("[_DoTargetStayFix] fix" .. error)
    end
  end)
end

function MultiHitBehaviourHotfixer:OnDispose()
end

return MultiHitBehaviourHotfixer