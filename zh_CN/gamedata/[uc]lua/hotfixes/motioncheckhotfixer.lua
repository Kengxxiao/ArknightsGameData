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

	weight = (entity.mapPosition - source.mapPosition).sqrMagnitude;
	return true
end

function MotionCheckHotfixer:OnInit()
	xlua.private_accessible(CS.Torappu.Battle.BlemshSleepingFirstSelector)
	self:Fix_ex(CS.Torappu.Battle.BlemshSleepingFirstSelector, "_CheckEnemyHasAbnormalComboAndInBlockableRange", function(self, entity, source, weight, volume)
   		local ok, errorInfo = xpcall(CheckInBlockableRange,debug.traceback, self, entity, source, weight, volume)
    	if not ok then
      		eutil.LogError("[MotionCheckHotfixer] fix" .. errorInfo)
	    end
 	end)
end

function MotionCheckHotfixer:OnDispose()
end

return MotionCheckHotfixer