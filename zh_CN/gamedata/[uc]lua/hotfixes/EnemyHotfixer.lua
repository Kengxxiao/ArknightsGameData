
local EnemyHotfixer = Class("EnemyHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

function EndPullFix(self, source)
    pullList = self.m_pullSources:GetInternalList()
    for i = 0, pullList.Count - 1 do
        src = pullList[i]
        if src:Lock() == source then
            self.m_pullSources:Remove(src)
            break
        end
    end
    
    disablePullSrc = self.m_disabledPullSources:GetInternalList()
    for i = 0, disablePullSrc.Count - 1 do
        src = disablePullSrc[i]
        if src:Lock() == source then
            self.m_disabledPullSources:Remove(src)
            break
        end
    end
        
    if self.m_pullSources.isEmpty and self.isUnbalanced then
        self.rigidbody2D:Sleep()
        self.rigidbody2D:WakeUp()
        self.stateMachine:Tick(0)
    end
    if source:GetType() ~= typeof(CS.Torappu.Battle.Projectile) and source.source ~= nil then
        source.source.buffContainer:OnEndPulling(self);
    end      
end

function EnemyHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.Enemy)
    self:Fix_ex(CS.Torappu.Battle.Enemy, "EndPull", function(self, source) 
        local ok, errorInfo = xpcall(EndPullFix, debug.traceback, self, source)
        if not ok then
          eutil.LogError("[EnemyHotfixer] EndPull fix" .. errorInfo)
        end
    end)
end

function EnemyHotfixer:OnDispose()
end

return EnemyHotfixer