local xutil = require('xlua.util')
local stringRes = require("HotFixes/LuaStringRes")
local eutil = CS.Torappu.Lua.Util

---@class Act4d0StageEntryHotfixer:HotfixBase
local Act4d0StageEntryHotfixer = Class("Act4d0StageEntryHotfixer", HotfixBase)

function Act4d0StageEntryHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Activity.Act4D0.Act4D0StageEntry)
  xutil.hotfix_ex(CS.Torappu.Activity.Act4D0.Act4D0StageEntry, "InitData",
  function(self)
    self:InitData()
    -- Act4d0StageEntryHotfixer.FixTimeInfoDisplay(self);
    xpcall(Act4d0StageEntryHotfixer.FixTimeInfoDisplay, function(e)
      eutil.LogError(e)
    end,self)
  end)
end

function Act4d0StageEntryHotfixer.FixTimeInfoDisplay(self)
  local data = CS.Torappu.Activity.Act4D0.Act4D0ResUtil.basicData
  local endTime = data.endTime
  local curTime = CS.Torappu.DateTimeUtil.timeStampNow
  if curTime < endTime then
    local find_func = CS.Torappu.Lua.LuaUIUtil.GetChild
    local target = find_func(self.gameObject, "remain_time")
    target = target:GetComponent("Text")
    local splited_time = string.split(target.text, ' ')
    if splited_time.Length > 2 then
      splited_time[2] = "09/10/16:00 - 09/24/03:59"
      target.text = table.concat(splited_time, ' ')
    end
  end
end

function Act4d0StageEntryHotfixer:OnDispose()
  xlua.hotfix(CS.Torappu.Activity.Act4D0.Act4D0StageEntry, "InitData", nil)
end

return Act4d0StageEntryHotfixer