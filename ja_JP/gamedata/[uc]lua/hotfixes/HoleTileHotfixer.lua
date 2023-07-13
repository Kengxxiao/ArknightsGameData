
local eutil = CS.Torappu.Lua.Util


local HoleTileHotfixer = Class("HoleTileHotfixer", HotfixBase)

local function _get_moveCost(self)
  return 1000000
end

function HoleTileHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.HoleTile)

  self:Fix_ex(CS.Torappu.Battle.HoleTile, "get_moveCost", _get_moveCost)
end

function HoleTileHotfixer:OnDispose()
end

return HoleTileHotfixer
