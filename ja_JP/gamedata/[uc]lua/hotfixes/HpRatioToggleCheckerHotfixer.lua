
local HpRatioToggleCheckerHotfixer = Class("HpRatioToggleCheckerHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

local function _CheckCondition_Fixed(self)
    if self._useLTForMax then
        return self.owner.alive and CS.Torappu.MathUtil.GE(self.owner.hpRatio:AsFloat(), self._minHpRatio) and CS.Torappu.MathUtil.LT(self.owner.hpRatio:AsFloat(), self.m_maxHpRatio)
    end
    return self.owner.alive and CS.Torappu.MathUtil.Between(self.owner.hpRatio:AsFloat(), self._minHpRatio, self.m_maxHpRatio)
end

function HpRatioToggleCheckerHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.Abilities.HpRatioToggleChecker)

	self:Fix_ex(CS.Torappu.Battle.Abilities.HpRatioToggleChecker, "_CheckCondition", function(self)
		return _CheckCondition_Fixed(self)
 	end)
end

function HpRatioToggleCheckerHotfixer:OnDispose()
end

return HpRatioToggleCheckerHotfixer