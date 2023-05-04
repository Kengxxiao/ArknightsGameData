
local ForcerSkill2HitBehaviourHotfixer = Class("ForcerSkill2HitBehaviourHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

function OnTickFix(self, deltaTime)
    if self.projectile ~= nil then
         self.eeHandler:OnTick()
    end    
    if self.traceTarget ~= nil and self.traceTarget.alive and self.projectile ~= nil then
         if self.traceTarget:GetType() ~= typeof(CS.Torappu.Battle.Enemy) or not self.traceTarget.isUnbalanced then
            self:Stop()
         end
    end      
end

function ForcerSkill2HitBehaviourHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.Projectiles.ForcerSkill2HitBehaviour)
    xlua.private_accessible(CS.Torappu.Battle.Projectiles.AuraHitBehaviour)
    self:Fix_ex(CS.Torappu.Battle.Projectiles.ForcerSkill2HitBehaviour, "OnTick", function(self, deltaTime) 
        local ok, errorInfo = xpcall(OnTickFix, debug.traceback, self, deltaTime)
        if not ok then
          eutil.LogError("[ForcerSkill2HitBehaviourHotfixer] OnTick fix" .. errorInfo)
        end
    end)
end

function ForcerSkill2HitBehaviourHotfixer:OnDispose()
end

return ForcerSkill2HitBehaviourHotfixer