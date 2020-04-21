local eutil = CS.Torappu.Lua.Util

---@class TemplateShopHotfixer:HotfixBase
local TemplateShopHotfixer = Class("TemplateShopHotfixer", HotfixBase)

local function _FixTemplateShopName(self, viewModel)
  local displayName = viewModel:GetDisplayName()
  if (displayName == nil or displayName == "") then
    return
  end
  self._normalName.text = displayName;
end

function TemplateShopHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.TemplateShop.TemplateShopCommonItemView)
  self:Fix_ex(CS.Torappu.UI.TemplateShop.TemplateShopCommonItemView, "_RenderCommonItemType", function(self,viewModel)
    self:_RenderCommonItemType(viewModel)
    local ok, error = xpcall(_FixTemplateShopName, debug.traceback, self, viewModel)
    if not ok then
      eutil.LogError("[TemplateShopHotfixer] fix commonName error:" .. error)
    end
  end)
end

function TemplateShopHotfixer:OnDispose()
end

return TemplateShopHotfixer