local Svash2DeckAuraBehaviourHotfixer = Class("Svash2DeckAuraBehaviourHotfixer", HotfixBase)

local function _IsCardValidFix(self, card)
    if card == nil or card.data == nil or card.data.isToken then
        return false
    end
    return self:_IsCardValid(card)
end

function Svash2DeckAuraBehaviourHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.Abilities.Svash2DeckAuraBehaviour)

    self:Fix_ex(CS.Torappu.Battle.Abilities.Svash2DeckAuraBehaviour, "_IsCardValid", function(self, card)
        local ok, ret = xpcall(_IsCardValidFix, debug.traceback, self, card)
        if not ok then
            LogError("[Svash2DeckAuraBehaviourHotfixer] fix" .. ret)
        end
        return ret
    end)
end

function Svash2DeckAuraBehaviourHotfixer:OnDispose()
end

return Svash2DeckAuraBehaviourHotfixer