local xutil = require('xlua.util')
local stringRes = require("HotFixes/LuaStringRes")
local eutil = CS.Torappu.Lua.Util

---@class Act4d0Hotfixer:HotfixBase
local Act4d0Hotfixer = Class("Act4d0Hotfixer", HotfixBase)

function Act4d0Hotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Activity.Act4D0.Act4D0GetStoryState)
  xutil.hotfix_ex(CS.Torappu.Activity.Act4D0.Act4D0GetStoryState, "OnEnter",
  function(self)
    self:OnEnter()
    xpcall(FixRefreshFunc, function(e)
      eutil.LogError(e)
    end,self)
  end)
end

function FixRefreshFunc(self) 
  local up = self.transform:GetChild(7):GetComponent("RectTransform")
  local size = up.sizeDelta
  size.x = 2000
  up.sizeDelta = size
  local down = self.transform:GetChild(8):GetComponent("RectTransform")
  local sizedown = down.sizeDelta
  sizedown.x = 2000
  down.sizeDelta = sizedown
end

function Act4d0Hotfixer:OnDispose()
  xlua.hotfix(CS.Torappu.Activity.Act4D0.Act4D0GetStoryState, "OnEnter", nil)
end

return Act4d0Hotfixer