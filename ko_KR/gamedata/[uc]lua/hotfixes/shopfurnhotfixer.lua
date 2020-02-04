local xutil = require('xlua.util')
local stringRes = require("HotFixes/LuaStringRes")
local eutil = CS.Torappu.Lua.Util

---@class ShopFurnHotfixer:HotfixBase
local ShopFurnHotfixer = Class("ShopFurnHotfixer", HotfixBase)

local function _DoShopRepair(self,viewModel,hub)
  self:ApplyData(viewModel,hub)
  local coin_furn_part =  CS.Torappu.Lua.LuaUIUtil.GetChild(self.gameObject,"coin_furn_part")
  local unselectObj =  CS.Torappu.Lua.LuaUIUtil.GetChild(coin_furn_part,"unselect (1)")
  local Text = CS.Torappu.Lua.LuaUIUtil.GetChild(unselectObj,"Text")
  local TextScript = Text:GetComponent("Text")
  TextScript.horizontalOverflow = CS.UnityEngine.HorizontalWrapMode.Wrap
  TextScript.resizeTextForBestFit = true

  local coin_diam_part =  CS.Torappu.Lua.LuaUIUtil.GetChild(self.gameObject,"coin_diam_part")
  local unselectObj_d =  CS.Torappu.Lua.LuaUIUtil.GetChild(coin_diam_part,"close_part")
  local Text_d = CS.Torappu.Lua.LuaUIUtil.GetChild(unselectObj_d,"Text")
  local TextScript_d = Text_d:GetComponent("Text")
  TextScript_d.horizontalOverflow = CS.UnityEngine.HorizontalWrapMode.Wrap
  TextScript_d.resizeTextForBestFit = true
end

function ShopFurnHotfixer:OnInit()
  xutil.hotfix_ex(CS.Torappu.UI.Shop.ShopDetailFurnView, "ApplyData",
  function(self,viewModel,hub)
    xpcall(_DoShopRepair, function(e)
      eutil.LogError(e)
    end,self,viewModel,hub)
  end)
end

function ShopFurnHotfixer:OnDispose()
  xlua.hotfix(CS.Torappu.UI.Shop.ShopDetailFurnView, "ApplyData", nil)
end

return ShopFurnHotfixer