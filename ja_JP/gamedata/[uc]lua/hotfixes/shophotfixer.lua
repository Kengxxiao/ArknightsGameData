




local ShopHotfixer = Class("ShopHotfixer", HotfixBase)

local eutil = CS.Torappu.Lua.Util

local function _FixRender(self, viewModel)
  self:Render(viewModel)
  
  if not viewModel.isDouble then
    return
  end
  if not viewModel.cacheData then
    return
  end
  local hub = CS.Torappu.DataConvertUtil.LoadCashIconHub()
  if not hub then
    return
  end
  local doubleId = eutil.Format(CS.Torappu.ShopConst.DIAMOND_IMG, viewModel.cacheData.doubleCount).. "d"
  local suc, doubleSprite = hub:TryGetSprite(doubleId)
  if not suc or not doubleSprite then
    return
  end
  self._countSprite.sprite = doubleSprite
end

function ShopHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.Shop.CashShopItemObject)
  self:Fix_ex(CS.Torappu.UI.Shop.CashShopItemObject, "Render", function(self, viewModel)
    local ok, error = xpcall(_FixRender, debug.traceback, self, viewModel)
    if not ok then
      eutil.LogError(error)
    end
  end)
end

function ShopHotfixer:OnDispose()
end

return ShopHotfixer