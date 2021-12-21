local MultiFunnelHitBehaviourHotfixer = Class("MultiFunnelHitBehaviourHotfixer", HotfixBase)
 
local function StopProjectileFix(self)
    self.m_remainingTime = self.m_periodTimer.remainingTime - CS.Torappu.GlobalConsts.FIXED_DELTA_TIME_FP
    self.m_periodTimer:MarkInvalid()
    self:Stop()
end
 
function MultiFunnelHitBehaviourHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.Projectiles.MultiFunnelHitBehaviour)
 
    self:Fix_ex(CS.Torappu.Battle.Projectiles.MultiFunnelHitBehaviour, "StopProjectile", function(self)
        local ok, errorInfo = xpcall(StopProjectileFix, debug.traceback, self)
        if not ok then
            eutil.LogError("[MultiFunnelHitBehaviourHotfixer] fix" .. errorInfo)
        end
    end)
end
 
function MultiFunnelHitBehaviourHotfixer:OnDispose()
end
 
return MultiFunnelHitBehaviourHotfixer