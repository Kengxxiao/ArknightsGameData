local xutil = require('xlua.util')
local eutil = CS.Torappu.Lua.Util


local RangeSelectorDoFindTargetsFixer = Class("RangeSelectorDoFindTargetsFixer", HotfixBase)

local function DoFindTargetsFix(self, pos)
    local tempDic = CS.Torappu.ListDict
    local origin = CS.Torappu.Battle.BattleController.instance.logger.m_stats.extraBattleInfoTmpStats
    CS.Torappu.Battle.BattleController.instance.logger.m_stats.extraBattleInfoTmpStats = tempDic
    local candidates = self:DoFindTargets(pos)
    CS.Torappu.Battle.BattleController.instance.logger.m_stats.extraBattleInfoTmpStats = origin
    return candidates
end

function RangeSelectorDoFindTargetsFixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.RangeSelector)
    xlua.private_accessible(CS.Torappu.Battle.BattleLogger)
    xlua.private_accessible(CS.Torappu.Battle.BattleLogger.BattleStats)

    local typeKey = typeof(CS.Torappu.ExtraBattleLogDataKey)
    xlua.private_accessible(CS.Torappu.ListDict(typeKey, CS.System.Int32))

    self:Fix_ex(CS.Torappu.Battle.RangeSelector, "DoFindTargets", function(self, pos)
        local ok, result = xpcall(DoFindTargetsFix, debug.traceback, self, pos)
        if not ok then
            eutil.LogError("[RangeSelectorDoFindTargetsFixer] fix" .. errorInfo)
        end
        return result
    end)
end

function RangeSelectorDoFindTargetsFixer:OnDispose()
end

return RangeSelectorDoFindTargetsFixer