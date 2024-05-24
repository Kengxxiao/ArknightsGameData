
local EntityHotfixer = Class("EntityHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

function FinishWithNoReasonFix(self)
    if CS.Torappu.Battle.BattleController.isDeterministic and not self.unfinished then
        return
    end 
    self:FinishMe(CS.Torappu.Battle.Entity.FinishReason.OTHER);
end

function EntityHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.Entity)
    self:Fix_ex(CS.Torappu.Battle.Entity, "FinishWithNoReason", function(self) 
        local ok, errorInfo = xpcall(FinishWithNoReasonFix, debug.traceback, self)
        if not ok then
          eutil.LogError("[EntityHotfixer] FinishWithNoReason fix" .. errorInfo)
        end
    end)
end

function EntityHotfixer:OnDispose()
end

return EntityHotfixer