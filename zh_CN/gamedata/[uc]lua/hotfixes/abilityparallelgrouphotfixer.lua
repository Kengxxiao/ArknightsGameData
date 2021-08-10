 local xutil = require('xlua.util')
 local eutil = CS.Torappu.Lua.Util

 
 local AbilityParallelGroupHotfixer = Class("AbilityParallelGroupHotfixer", HotfixBase)

 local function _OnAttributeDirty(self, attributetype, oldvalue)
    self:OnAttributeDirty(attributetype, oldvalue)

    if (self.data.prefabKey == "char_1013_chen2" and (attributetype == CS.Torappu.AttributeType.BASE_ATTACK_TIME or attributetype == CS.Torappu.AttributeType.ATTACK_SPEED)) then
        for i = 0, self.m_abilities.count - 1 do
            local ab = self.m_abilities[i]
            if ab:GetType() == typeof(CS.Torappu.Battle.Abilities.AbilityParallelGroup) then
                ab.m_cooldown = self.attackTime
                ab.m_cooldownTimer:ResetButKeepProgress(self.attackTime)
            end
        end
    end
end

local function _DoAttach (self, owner)
    self:DoAttach(owner)
    
    if (string.find(owner.name, "char_1013_chen2")) then
        self.m_cooldown = owner.attackTime
        self.m_cooldownTimer:ResetButKeepProgress(owner.attackTime)
    end
end	

local function _get_isAffecting(self)
    if (string.find(self.owner.name, "char_1013_chen2")) then
        for i = 0, self._abilities.Length - 1 do
            local ab = self._abilities[i]
            if ab.isAffecting then
                return true
            end
        end
        return false
    end

    return self.isAffecting
end

function AbilityParallelGroupHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.Character)
    xlua.private_accessible(CS.Torappu.Battle.Ability)
    xlua.private_accessible(CS.Torappu.Battle.Abilities.AbilityParallelGroup)

    self:Fix_ex(CS.Torappu.Battle.Character, "OnAttributeDirty", function ( self, attributetype, oldvalue )
        local ok, errorInfo = xpcall(_OnAttributeDirty, debug.traceback, self, attributetype, oldvalue)
        if not ok then
            eutil.LogError("[AbilityParallelGroupHotfixer] OnAttributeDirty fix" .. errorInfo)
        end
    end)

    self:Fix_ex(CS.Torappu.Battle.Abilities.AbilityParallelGroup, "DoAttach",function ( self, owner )
        local ok, errorInfo = xpcall(_DoAttach, debug.traceback, self, owner)
        if not ok then
            eutil.LogError("[AbilityParallelGroupHotfixer] DoAttach fix" .. errorInfo)
        end
    end)

    self:Fix_ex(CS.Torappu.Battle.Abilities.AbilityParallelGroup, "get_isAffecting", _get_isAffecting)
end

function AbilityParallelGroupHotfixer:OnDispose()
end

return AbilityParallelGroupHotfixer