local AdaptiveDynIllustArbiter = CS.Torappu.UI.AdaptiveDynIllustArbiter


local AdaptiveDynIllustUpdaterHotfixer = Class("AdaptiveDynIllustUpdaterHotfixer", HotfixBase)

function AdaptiveDynIllustUpdaterHotfixer:OnInit()
  
  self:Fix(AdaptiveDynIllustArbiter, "ShouldSkipAdaptiveFraming", function(_)
    return false
  end)
end

function AdaptiveDynIllustUpdaterHotfixer:OnDispose()
end

return AdaptiveDynIllustUpdaterHotfixer
