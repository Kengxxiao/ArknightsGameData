local Map = CS.Torappu.Battle.Map


local MapHotfixer = Class("MapHotfixer", HotfixBase)

function MapHotfixer:OnInit()
  xlua.private_accessible(Map)
  self:Fix(Map, "get_tiles", function(self)
    if self.m_allTiles.Count == 0 then
      self.m_allTiles:AddRange(self._tiles._tiles)
    end
    return self.m_allTiles
  end)
end

return MapHotfixer
