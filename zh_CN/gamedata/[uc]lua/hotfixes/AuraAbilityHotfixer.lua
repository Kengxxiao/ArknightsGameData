
local AuraAbilityHotfixer = Class("AuraAbilityHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

function _DoTargetCheckAndEnterFix(self, target)
    if CS.Torappu.Battle.BattleController.isDeterministic then
        if self.owner == nil or not self.owner.alive then
            return false
        end
    end
    
    return self:_DoTargetCheckAndEnter(target)
end

function AuraAbilityHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.Abilities.AuraAbility)
    self:Fix_ex(CS.Torappu.Battle.Abilities.AuraAbility, "_DoTargetCheckAndEnter", function(self, target) 
        local ok, result, errorInfo = xpcall(_DoTargetCheckAndEnterFix, debug.traceback, self, target)
        if ok then
            return result
        else
          eutil.LogError("[AuraAbilityHotfixer] AuraAbility fix" .. errorInfo)
        end
    end)
end

function AuraAbilityHotfixer:OnDispose()
end

return AuraAbilityHotfixer