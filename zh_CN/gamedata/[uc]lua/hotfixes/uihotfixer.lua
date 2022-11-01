



local UIHotfixer = Class("UIHotfixer", HotfixBase)

function UIHotfixer:OnInit()
  self:Fix("Torappu.UI.SiracusaMap.SiracusaMapBigMapView+ScrollController", "set_normalizedPos", function(self, val)
    local scrollRect = self.m_scrollRect
    if scrollRect == nil or not scrollRect.gameObject.activeInHierarchy then
      return
    end
    scrollRect.normalizedPosition = val
  end)
end

function UIHotfixer:OnDispose()
end

return UIHotfixer