local MhwrbgSkill_1Hotfixer = Class("MhwrbgSkill_1Hotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

local function OnCastOnTargetFix(self, target, actions, buffs, attachments)
    base(self):OnCastOnTarget(target, actions, buffs, attachments)
    local character = target
    if character == nil then
        return
    end
    local ownerCharacter = self.owner
    if ownerCharacter == nil then
        return
    end
    local deck = CS.Torappu.Battle.BattleController.instance:GetDeck()
    if deck ~= nil then
        local result
        result, self.m_targetCard = self:_TryDrawCardToHand(deck)
        if result then
            local miscModifier = CS.Torappu.Battle.Deck.Card.MiscSettingModifier(
                not character.occupiedRemainingCharacterCnt, character.buildCondition.buildableType,
                character.buildCondition.advancedBuildableMask)
            local cardBuff = CS.Torappu.Battle.Deck.Card.CardBuff(self._cardBuffKey, CS.Torappu.Battle.Deck.Card
                .CardBuff.LifeType.IMMEDIATELY, miscModifier)
            self.m_targetCard:AddCardBuff(cardBuff)
            self.m_targetCard:MockAppearance(character.data)
        end
    end
end

function MhwrbgSkill_1Hotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.Abilities.MhwrbgSkill_1)
    self:Fix_ex(CS.Torappu.Battle.Abilities.MhwrbgSkill_1, "OnCastOnTarget",
        function(self, target, actions, buffs, attachments)
            local ok, errorInfo = xpcall(OnCastOnTargetFix, debug.traceback, self, target, actions, buffs, attachments)
            if not ok then
                eutil.LogError("[MhwrbgSkill_1Hotfixer] fix" .. errorInfo)
            end
        end)
end

function MhwrbgSkill_1Hotfixer:OnDispose()
end

return MhwrbgSkill_1Hotfixer
