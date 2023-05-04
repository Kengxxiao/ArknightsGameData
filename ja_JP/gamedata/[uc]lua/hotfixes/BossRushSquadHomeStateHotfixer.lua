local BossRushSquadHomeStateHotfixer = Class("BossRushSquadHomeStateHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

local function _OnCharSelectFinished_Fixed(self, stateBean)
  if self.m_charSelectStateBeanInput.selectingTeamId ~= self.m_stateBean.curSquadTeamId then
    return
  end
  self:_OnCharSelectFinished(stateBean)
end

function BossRushSquadHomeStateHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.BossRush.BossRushSquadHomeState)

  self:Fix_ex(CS.Torappu.UI.BossRush.BossRushSquadHomeState, "_OnCharSelectFinished", function(self, stateBean)
    xpcall(_OnCharSelectFinished_Fixed, debug.traceback, self, stateBean)
  end)
end

function BossRushSquadHomeStateHotfixer:OnDispose()
end

return BossRushSquadHomeStateHotfixer