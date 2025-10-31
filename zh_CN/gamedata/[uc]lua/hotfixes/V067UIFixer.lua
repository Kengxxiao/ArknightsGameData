
local V067UIHotfixer = Class("V067UIHotfixer", HotfixBase)


local function _FixSpriteRenderDataGetUVs(self, padding)
  
  if self.atlasSize == 360 and self.rect.w == 180 then
    return CS.UnityEngine.Vector4(0, 0, 1, 1)
  end
  
  return self:GetUVs(padding)
end


function V067UIHotfixer:OnInit()
  
  self:Fix_ex(CS.Torappu.UI.Atlas.SpriteRenderData, "GetUVs", function(self, padding)
    local ok, ret = xpcall(_FixSpriteRenderDataGetUVs, debug.traceback, self, padding)
    if not ok then
      LogError("[FixSpriteRenderData] error: ".. ret)
      return self:GetUVs(padding)
    end
    return ret
  end)
end

function V067UIHotfixer:OnDispose()
  
end

return V067UIHotfixer
