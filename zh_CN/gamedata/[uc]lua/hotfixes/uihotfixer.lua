



local UIHotfixer = Class("UIHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util
local SiracusaMapController = CS.Torappu.UI.SiracusaMap.SiracusaMapController

local function OnNavigationSelectFix(self, entryId, entryType)
  local mapViewModel = self.panelMapProperty:GetValueNotNull()
  if mapViewModel.navigationViewModel.selectingEntryId ~= entryId then
    mapViewModel:SelectPoint(nil)
  end
  mapViewModel:SelectNavi(entryId)
  self.panelMapProperty:NotifyUpdate()
end

function UIHotfixer:OnInit()
  self:Fix("Torappu.UI.SiracusaMap.SiracusaMapBigMapView+ScrollController", "set_normalizedPos", function(self, val)
    local scrollRect = self.m_scrollRect
    if scrollRect == nil or not scrollRect.gameObject.activeInHierarchy then
      return
    end
    scrollRect.normalizedPosition = val
  end)

  xlua.private_accessible(SiracusaMapController)
  self:Fix_ex(SiracusaMapController, "_OnNavigationSelect", function(self, entryId, entryType)
    local ok, ret = xpcall(OnNavigationSelectFix, debug.traceback, self, entryId, entryType)
    if not ok then
      eutil.LogError("[OnNavigationSelectFix] fix" .. ret)
    end
  end)

  self:Fix(CS.Torappu.ResourceUrls, "GetDeepSeaRPSpecialPicHubPath", function()
    return "Arts/UI/DeepSea/SpecialPic/special_pic_hub"
  end)

  self:Fix(CS.Torappu.ResourceUrls, "GetDeepSeaRPPicHubPath", function()
    return "Arts/UI/DeepSea/NormalPic/normal_pic_hub"
  end)
end

function UIHotfixer:OnDispose()
end

return UIHotfixer