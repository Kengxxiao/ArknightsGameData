local LegionUILibraryCardItemHotfixer = Class("LegionUILibraryCardItemHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util
 
local function Fix_SetEvolvePhase(self, evolvePhase)
    if(evolvePhase == CS.Torappu.EvolvePhase.PHASE_0) then
        CS.Torappu.GameObjectUtil.SetActiveIfNecessary(self._eliteIcon.gameObject, false);
        return
    end
    self:_SetEvolvePhase(evolvePhase);
end
 
function LegionUILibraryCardItemHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.Legion.LegionUILibraryCardItem)
 
    self:Fix_ex(CS.Torappu.Battle.Legion.LegionUILibraryCardItem, "_SetEvolvePhase", function(self, evolvePhase)
        local ok, errorInfo = xpcall(Fix_SetEvolvePhase, debug.traceback, self, evolvePhase)
        if not ok then
            eutil.LogError("[LegionUILibraryCardItemHotfixer] fix" .. errorInfo)
        end
    end)
end
 
function LegionUILibraryCardItemHotfixer:OnDispose()
end
 
return LegionUILibraryCardItemHotfixer
