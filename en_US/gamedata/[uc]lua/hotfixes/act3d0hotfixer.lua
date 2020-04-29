local xutil = require('xlua.util')
local stringRes = require("HotFixes/LuaStringRes")
local eutil = CS.Torappu.Lua.Util

---@class Act3d0Hotfixer:HotfixBase
local Act3d0Hotfixer = Class("Act3d0Hotfixer", HotfixBase)

function Act3d0Hotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Activity.Act3D0.Act3D0StageEntry)
  xutil.hotfix_ex(CS.Torappu.Activity.Act3D0.Act3D0StageEntry, "InitData",
  function(self, defaultBoxId)
    self:InitData(defaultBoxId)
    -- Act3d0Hotfixer.FixTimeInfoDisplay(self, defaultBoxId);
    xpcall(Act3d0Hotfixer.FixTimeInfoDisplay, function(e)
      eutil.LogError(e)
    end,self)
  end)
end

function Act3d0Hotfixer.FixTimeInfoDisplay(self, defaultBoxId)
  local data = CS.Torappu.Activity.Act3D0.Act3d0ResUtil.basicData
  local endTime = data.endTime
  local curTime = CS.Torappu.DateTimeUtil.timeStampNow
  if curTime < endTime then
    local find_func = CS.Torappu.Lua.LuaUIUtil.GetChild
    local target = find_func(self.gameObject, "Image (2)")
    target = find_func(target, "Text")
    target = target:GetComponent("Text")
    local splited_time = string.split(target.text, '\n')
    splited_time[1] = "04/29/10:00 - 05/13/03:59"
    target.text = table.concat(splited_time, '\n')
  end
end

function Act3d0Hotfixer:OnDispose()
  xlua.hotfix(CS.Torappu.Activity.Act3D0.Act3D0StageEntry, "InitData", nil)
end

return Act3d0Hotfixer