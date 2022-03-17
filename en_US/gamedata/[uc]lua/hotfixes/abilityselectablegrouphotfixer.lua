local xutil = require('xlua.util')
local eutil = CS.Torappu.Lua.Util


local AbilitySelectableGroupHotfixer = Class("AbilitySelectableGroupHotfixer", HotfixBase)

local function OnCastEndFix(self, reason)
    self:OnCastEnd(reason)

    local len = self._abilityConfigs.Length
    for i = 0, len - 1 do
        self._abilityConfigs[i].ability:InterruptIfNot()
    end
end

function AbilitySelectableGroupHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.Abilities.AbilitySelectableGroup)

    self:Fix_ex(CS.Torappu.Battle.Abilities.AbilitySelectableGroup, "OnCastEnd", function(self, reason)
        local ok, errorInfo = xpcall(OnCastEndFix, debug.traceback, self, reason)
        if not ok then
            eutil.LogError("[AbilitySelectableGroupHotfixer] fix" .. errorInfo)
        end
    end)
end

function AbilitySelectableGroupHotfixer:OnDispose()
end

return AbilitySelectableGroupHotfixer