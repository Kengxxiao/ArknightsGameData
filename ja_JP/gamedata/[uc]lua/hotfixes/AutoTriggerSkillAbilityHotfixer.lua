
local AutoTriggerSkillAbilityHotfixer = Class("AutoTriggerSkillAbilityHotfixer", HotfixBase)


function _DoSetData(self, owner, options)
    self.m_skill = nil
    self:DoSetData(owner, options)
end

function AutoTriggerSkillAbilityHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.Abilities.AutoTriggerSkillAbility)
    self:Fix_ex(CS.Torappu.Battle.Abilities.AutoTriggerSkillAbility, "DoSetData", function(self, owner, options) 
        local ok, errorInfo = xpcall(_DoSetData, debug.traceback, self, owner, options)
        if not ok then
          eutil.LogError("[AutoTriggerSkillAbilityHotfixer] DoSetData fix" .. errorInfo)
        end
    end)
end

function AutoTriggerSkillAbilityHotfixer:OnDispose()
end

return AutoTriggerSkillAbilityHotfixer