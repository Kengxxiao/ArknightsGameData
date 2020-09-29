local eutil = CS.Torappu.Lua.Util

---@class TempShopCRSingleViewHotfixer:HotfixBase
local TempShopCRSingleViewHotfixer = Class("TempShopCRSingleViewHotfixer", HotfixBase)

local function _FixFunc(self)
  local isJp = CS.Torappu.I18N.LocalizationEnv.IsJapan()
  local isKr = CS.Torappu.I18N.LocalizationEnv.IsKorea()
  local isEn = CS.Torappu.I18N.LocalizationEnv.IsEnArea()
  --print(isJp)
  if isJp then
    self._constText.text = "購入"
  elseif isKr then
    self._constText.text = "합계"
  elseif isEn then
    self._constText.text = "Buy"
  end
end

function TempShopCRSingleViewHotfixer:OnInit()
  self:Fix_ex(CS.Torappu.UI.TemplateShop.TemplateShopCommonRightSingleView, "Render", function(self,viewModel)
    self:Render(viewModel);
    local ok, error = xpcall(_FixFunc, debug.traceback, self);
    if not ok then
      eutil.LogError("[TempShopCRSingleViewHotfixer] fix error:" .. error);
    end
  end)
end

function TempShopCRSingleViewHotfixer:OnDispose()
  xlua.hotfix(CS.Torappu.UI.TemplateShop.TemplateShopCommonRightSingleView, "Render", nil)
end

return TempShopCRSingleViewHotfixer