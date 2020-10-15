---@class MotionCheckHotfixer:HotfixBase
local MotionCheckHotfixer = Class("MotionCheckHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

local function CheckInBlockableRange(self, entity, source, weight, volume)
	volume = 0
	weight = 0

	if entity:GetType() ~= typeof(CS.Torappu.Battle.Enemy) or source:GetType() ~= typeof(CS.Torappu.Battle.Character) then
		return false
	end
	if not entity:CheckInBlockRange(source) or not entity.attributes:GetAbnormalCombo(self._abnormalComboWithHighPriority) or entity.changeableMotionMode ~= source.changeableMotionMode then
		return false
	end

	weight = -entity.hatred
	return true, weight, volume
end

function MotionCheckHotfixer:OnInit()
	xlua.private_accessible(CS.Torappu.Battle.BlemshSleepingFirstSelector)
	self:Fix_ex(CS.Torappu.Battle.BlemshSleepingFirstSelector, "_CheckEnemyHasAbnormalComboAndInBlockableRange", function(self, entity, source, weight, volume)
		return CheckInBlockableRange(self, entity, source, weight, volume)
 	end)
end

function MotionCheckHotfixer:OnDispose()
end

return MotionCheckHotfixer