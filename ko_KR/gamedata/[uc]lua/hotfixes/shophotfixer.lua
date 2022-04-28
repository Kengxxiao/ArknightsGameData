




local ShopHotfixer = Class("ShopHotfixer", HotfixBase)

local function _ConfigGetData(self)
  return true
end

function ShopHotfixer:OnInit()
  self:Fix_ex(CS.Torappu.Config.RemoteConfig, "get_enableBestHttp", _ConfigGetData)
end

function ShopHotfixer:OnDispose()
end

return ShopHotfixer