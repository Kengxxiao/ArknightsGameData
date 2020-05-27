local xutil = require('xlua.util')
local stringRes = require("HotFixes/LuaStringRes")
local eutil = CS.Torappu.Lua.Util

---@class HomeHotfixer:HotfixBase
local HomeHotfixer = Class("HomeHotfixer", HotfixBase)

local function HomePageRepair(self)
  local find = CS.Torappu.Lua.LuaUIUtil.GetChild
  local obj = find(self.gameObject, "btn_activity_slot")
  obj = find(obj, "text_shadow")
  local objText = obj:GetComponent("Text")
  objText.alignment = 3
  obj = find(obj, "text")
  objText = obj:GetComponent("Text")
  objText.alignment = 3
end

function HomeHotfixer:OnInit()
  xutil.hotfix_ex(CS.Torappu.UI.Home.HomePage, "OnCreate",
    function(self, savedInst)
      self:OnCreate(savedInst)
      xpcall(HomePageRepair, function(e)
        eutil.LogError(e)
      end, self)
    end, self
  )
end

function HomeHotfixer:OnDispose()
    xlua.hotfix(CS.Torappu.UI.Home.HomePage, "OnCreate", nil)
end

return HomeHotfixer