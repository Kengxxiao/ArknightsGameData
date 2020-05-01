-- local BaseHotfixer = require ("Module/Core/BaseHotfixer")
-- local xutil = require('xlua.util')
-- local stringRes = require("Module/Config/LuaStringRes")
-- local eutil = CS.Torappu.Lua.Util

---@class ShopHotfixer:HotfixBase
local ShopHotfixer = Class("ShopHotfixer", HotfixBase)

local function fixShopBuy(self, viewModel,priceTypeHub)
  self:ApplyData(viewModel,priceTypeHub)
  if (viewModel.priceType == CS.Torappu.ShopDetailPriceType.EPGS_COIN) then
    self._maxButton.interactable = false;
    self._maxButtonText.color = CS.Torappu.ColorRes.TEXT_GRAY;
  end
end

function ShopHotfixer:OnInit()
  self:Fix_ex(CS.Torappu.UI.Shop.ShopDetailComplexView, "ApplyData", function(self, viewModel,priceTypeHub)
    local ok, error = xpcall(fixShopBuy,debug.traceback,self, viewModel,priceTypeHub)
    if not ok then
      eutil.LogError("[shop_btn] fix" .. error)
    end
  end)
end


function ShopHotfixer:OnDispose()
end

return ShopHotfixer