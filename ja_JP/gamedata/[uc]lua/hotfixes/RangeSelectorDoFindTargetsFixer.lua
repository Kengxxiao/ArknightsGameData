local xutil = require('xlua.util')
local eutil = CS.Torappu.Lua.Util


local RangeSelectorDoFindTargetsFixer = Class("RangeSelectorDoFindTargetsFixer", HotfixBase)

local function FindTargets_DISPOSE(self, misc)
    local tempDic = CS.Torappu.ListDict
    local origin = CS.Torappu.Battle.BattleController.instance.logger.m_stats.extraBattleInfoTmpStats
    CS.Torappu.Battle.BattleController.instance.logger.m_stats.extraBattleInfoTmpStats = tempDic
    local candidates = self:FindTargets_DISPOSE(misc)
    CS.Torappu.Battle.BattleController.instance.logger.m_stats.extraBattleInfoTmpStats = origin
    return candidates
end

local function _DoFilter(self, misc1, misc2)
  local tempDic = CS.Torappu.ListDict
  local origin = CS.Torappu.Battle.BattleController.instance.logger.m_stats.extraBattleInfoTmpStats
  CS.Torappu.Battle.BattleController.instance.logger.m_stats.extraBattleInfoTmpStats = tempDic
  self:_DoFilter(misc1, misc2)
  CS.Torappu.Battle.BattleController.instance.logger.m_stats.extraBattleInfoTmpStats = origin
end

function RangeSelectorDoFindTargetsFixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.TileSelector)
    xlua.private_accessible(CS.Torappu.Battle.BattleLogger)
    xlua.private_accessible(CS.Torappu.Battle.BattleLogger.BattleStats)

    local typeKey = typeof(CS.Torappu.ExtraBattleLogDataKey)
    xlua.private_accessible(CS.Torappu.ListDict(typeKey, CS.System.Int32))

    self:Fix_ex(CS.Torappu.Battle.TargetSelector, "FindTargets_DISPOSE", function(self, misc)
        local ok, result, errorInfo = xpcall(FindTargets_DISPOSE, debug.traceback, self, misc)
        if not ok then
            eutil.LogError("[TargetSelector.FindTargets_DISPOSE] fix" .. errorInfo)
        end
        return result
    end)
    self:Fix_ex(CS.Torappu.Battle.TileSelector, "_DoFilter", function(self, misc1, misc2)
      local ok, errorInfo = xpcall(_DoFilter, debug.traceback, self, misc1, misc2)
      if not ok then
          eutil.LogError("[TileSelector._DoFilter] fix" .. errorInfo)
      end
    end)
end

function RangeSelectorDoFindTargetsFixer:OnDispose()
end

return RangeSelectorDoFindTargetsFixer