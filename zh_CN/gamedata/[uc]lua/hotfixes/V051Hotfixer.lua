

local xutil = require('xlua.util')
local CSSender = CS.Torappu.UI.UISender




local V051Hotfixer = Class("V051Hotfixer", HotfixBase)

local function _FixSendBattleService(self, isRetry)
  local routine = self:_SendBattleService(isRetry)
  return xutil.cs_generator(function()
    while CSSender.IsBusy() do
      coroutine.yield()
    end
    coroutine.yield(routine)
  end)
end

local function _FixExecuteHideCgItem(self, command)
  local param = self:_GenSlotParam(command)
  local clearAll = false
  if (param.key == nil or param.key == '') then
    clearAll = true
  end

  if (clearAll) then
    for k,v in pairs(self.m_slotsInUseDict) do
      v:Dispose()
    end
    self.m_slotsInUseDict:Clear()
    return false
  end
  self:_ExecuteHideCgItem(command)
end

function V051Hotfixer:OnInit()
  self:Fix_ex(CS.Torappu.Battle.UI.UIBattleFinishServiceState, "_SendBattleService", _FixSendBattleService);
  self:Fix_ex(CS.Torappu.AVG.AVGCgItemPanel, "_ExecuteHideCgItem", _FixExecuteHideCgItem);
end

return V051Hotfixer