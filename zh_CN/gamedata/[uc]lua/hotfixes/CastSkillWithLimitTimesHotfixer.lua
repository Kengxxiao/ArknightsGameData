local xutil = require('xlua.util')
local eutil = CS.Torappu.Lua.Util


local CastSkillWithLimitTimesHotfixer = Class("CastSkillWithLimitTimesHotfixer", HotfixBase)

local function _Get_OwnerIsInBulletMode(self)
    if self.owner == nil then
        return false
    end
    return self.ownerIsInBulletMode
end

function CastSkillWithLimitTimesHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.CastSkillWithLimitTimes)
    self:Fix_ex(CS.Torappu.Battle.CastSkillWithLimitTimes, "get_ownerIsInBulletMode", _Get_OwnerIsInBulletMode)
end

function CastSkillWithLimitTimesHotfixer:OnDispose()
end

return CastSkillWithLimitTimesHotfixer