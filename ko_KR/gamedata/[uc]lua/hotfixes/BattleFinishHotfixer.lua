local eutil = CS.Torappu.Lua.Util


local BattleFinishHotfixer = Class("BattleFinishHotfixer", HotfixBase)

local function _FixBattleLogSquad()
  local stageType = CS.Torappu.Battle.BattleInOut.instance.input.stageInfo.stageType
  if stageType ~= CS.Torappu.StageType.CAMPAIGN then 
    return
  end
  local squad = CS.Torappu.Battle.BattleInOut.instance.output.journal.squad
  if squad == nil then
    return
  end
  for i = squad.Count - 1, 0, -1 do
    local charInfo = squad[i]
    if charInfo.charInstId < 0 then
      squad:RemoveAt(i)
    end
  end
end

function BattleFinishHotfixer:OnInit()
  self:Fix_ex(CS.Torappu.UI.BattleFinish.BattleFinishHomeState, "OnEnter", function(self)
    self:OnEnter()
    local ok, error = xpcall(_FixBattleLogSquad, debug.traceback)
    if not ok then
      eutil.LogError("[BattleFinishHotfixer] fix squad error:" .. error)
    end
  end)
end

function BattleFinishHotfixer:OnDispose()
end

return BattleFinishHotfixer