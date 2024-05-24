
local EnemyHotfixer = Class("EnemyHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

function _ResetPhysicsStatusFix(self)
    self.rigidbody2D.velocity = CS.UnityEngine.Vector2.zero;
    self.rigidbody2D:Sleep();
    if CS.Torappu.Battle.BattleController.isDeterministic then
        self.rigidbody2D.rotation = 0;
    end
    
    if self.m_nonTriggerCollider ~= nil and self.onlyCollideWhenUnbalance then
        self.m_nonTriggerCollider.enabled = false;
    end
    self.m_pullSources:Clear();
    self.m_disabledPullSources:Clear();
    self:RestoreFrictionFactor();
    self.stateMachine.blackboard:ResetUnbalanceProtectTime();
end

function EnemyHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.Enemy)
    self:Fix_ex(CS.Torappu.Battle.Enemy, "_ResetPhysicsStatus", function(self) 
        local ok, errorInfo = xpcall(_ResetPhysicsStatusFix, debug.traceback, self)
        if not ok then
          eutil.LogError("[EnemyHotfixer] _ResetPhysicsStatus fix" .. errorInfo)
        end
    end)
end

function EnemyHotfixer:OnDispose()
end

return EnemyHotfixer