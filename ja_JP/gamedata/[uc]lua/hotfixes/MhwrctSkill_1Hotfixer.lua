local MhwrctSkill_1Hotfixer = Class("MhwrctSkill_1Hotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

local function OnCastOnTargetFix(self, target, actions, buffs, attachments)
    local ownerCharacter = self.owner
    local deck = CS.Torappu.Battle.BattleController.instance:GetDeck();
    if deck ~= nil then
        local card = deck:FindCard(ownerCharacter.cardUid);

        if card.dataToShow == card.data then
            return;
        end

        local characters = CS.Torappu.Battle.BattleController.instance.unitManager.characters;
        local targetCharacter = nil;
        local enumerator = characters:GetEnumerator()
        while enumerator:MoveNext() do
          local character = enumerator.Current
          if character ~= nil and character.data == card.dataToShow then
            targetCharacter = character
            break
          end
        end

        local tile = ownerCharacter.rootTile;
        if targetCharacter ~= nil and targetCharacter.aliveOrDying then
            self:_CreateProjectile(targetCharacter);
        end

        ownerCharacter:FinishWithNoReason();

        if targetCharacter ~= nil and targetCharacter.aliveOrDying then
            targetCharacter:RespawnSelf(tile, ownerCharacter.direction);
        end
    end
end

function MhwrctSkill_1Hotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.Abilities.MhwrctSkill_1)
    self:Fix_ex(CS.Torappu.Battle.Abilities.MhwrctSkill_1, "OnCastOnTarget",
        function(self, target, actions, buffs, attachments)
            local ok, errorInfo = xpcall(OnCastOnTargetFix, debug.traceback, self, target, actions, buffs, attachments)
            if not ok then
                eutil.LogError("[MhwrctSkill_1Hotfixer] fix" .. errorInfo)
            end
        end)
end

function MhwrctSkill_1Hotfixer:OnDispose()
end

return MhwrctSkill_1Hotfixer
