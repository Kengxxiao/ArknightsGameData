local luaUtils = CS.Torappu.Lua.Util
local CommonCharCardView = CS.Torappu.UI.CommonCharCardView

local CommonCharCardCacheHotfixer = Class("CommonCharCardCacheHotfixer", HotfixBase)

local function _CheckCacheConditionFix(self, cardAssets, characterCardViewModel, cardPlugin)
  if cardAssets == nil or characterCardViewModel == nil or cardPlugin == nil then
    return
  end
  cardPlugin:RendView(cardAssets, characterCardViewModel)
end

function CommonCharCardCacheHotfixer:OnInit()
  xlua.private_accessible(typeof(CommonCharCardView))
  self:Fix_ex(CommonCharCardView, "_RendCardSingleTypeView", function(self, cardAssets, characterCardViewModel, cardPlugin)
    local ok, errorInfo = xpcall(_CheckCacheConditionFix, debug.traceback, self, cardAssets, characterCardViewModel, cardPlugin)
    if not ok then
      LogError("[common char card] CommonCharCardView fix error: " .. errorInfo)
    end
  end)
end

return CommonCharCardCacheHotfixer