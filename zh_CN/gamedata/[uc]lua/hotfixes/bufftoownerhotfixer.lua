local xutil = require('xlua.util')
local BuffToOwnerHotfixer = Class("BuffToOwnerHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

local function Fix_SetData(self, blackboard)
    if self._extraCondition ==
        CS.Torappu.Battle.Abilities.BuffToOwner.ExtraCondition.VALID_CAST_TARGETS_LESS_THAN_MAX_TARGET and
        string.match(self.owner.name, "char_437_mizuki") then
        base(self):SetData(blackboard)
        self.m_maxTargetNum = self._maxTarget
    else
        self:SetData(blackboard)
    end
end

function BuffToOwnerHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.Abilities.BuffToOwner)
    xlua.private_accessible(CS.Torappu.Blackboard)

    self:Fix_ex(CS.Torappu.Battle.Abilities.BuffToOwner, "SetData", function(self, blackboard)
        local ok, errorInfo = xpcall(Fix_SetData, debug.traceback, self, blackboard)
        if not ok then
            eutil.LogError("[BuffToOwnerHotfixer] fix" .. errorInfo)
        end
    end)
end

function BuffToOwnerHotfixer:OnDispose()
end

return BuffToOwnerHotfixer
