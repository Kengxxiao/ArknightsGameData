local xutil = require('xlua.util')
local stringRes = require("HotFixes/LuaStringRes")
local eutil = CS.Torappu.Lua.Util

---@class FurnShopHotfixer:HotfixBase
local FurnShopHotfixer = Class("FurnShopHotfixer", HotfixBase)

local function ShopFurnRepair(self) 
  local obj = self._adapter._furnItem
  local displayName = CS.Torappu.Lua.LuaUIUtil.GetChild(obj, "canvas_group/name")
  local comp = displayName:GetComponent("Text")
  comp.text = ""
end

function FurnShopHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.Shop.ShopFurnAdapter)

  xutil.hotfix_ex(CS.Torappu.UI.Shop.ShopFurnState, "OnEnter",
  function(self)
    self:OnEnter()
    xpcall(ShopFurnRepair, function(e)
      eutil.LogError(e)
    end,self)
  end)
end

function FurnShopHotfixer:OnDispose()
  xlua.hotfix(CS.Torappu.UI.Shop.ShopFurnState, "OnEnter", nil)
end

return FurnShopHotfixer