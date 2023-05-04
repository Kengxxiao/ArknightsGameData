
local DoubleBufferedListHotfixer = Class("DoubleBufferedListHotfixer", HotfixBase)

local function _IsEmpty(self)
    return true
end

function DoubleBufferedListHotfixer:OnInit()
    local wrap = xlua.get_generic_method(CS.Torappu.ObjectPtr, "Wrap")
    wrapEntity = wrap(CS.Torappu.Battle.Buff)
    local testBuff
    local ret = wrapEntity(testBuff)
    local type = ret:GetType()
    
    xlua.private_accessible(CS.Torappu.DoubleBufferedList(type))
    self:Fix_ex(CS.Torappu.DoubleBufferedList(type), "get_isEmpty", _IsEmpty)
end

function DoubleBufferedListHotfixer:OnDispose()
end

return DoubleBufferedListHotfixer