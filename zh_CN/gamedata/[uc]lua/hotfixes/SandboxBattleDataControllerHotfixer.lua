local SandboxBattleDataControllerHotfixer = Class("SandboxBattleDataControllerHotfixer", HotfixBase)

local function RecordUsingConstructItemFix(self, character)
    local gameMode = self.m_gameMode
    if character ~= nil and character.data ~= nil and gameMode ~= nil and gameMode.configData ~= nil and not gameMode.isInBuildType then
        local itemId = CS.Torappu.Battle.Sandbox.SandboxBattleUtil.GetTrapItemId(character, gameMode.configData)
        local output = self.m_output
        if itemId ~= nil and output ~= nil then
            local constructItems = output.constructItems
            if constructItems ~= nil then
                local itemCnt = constructItems:get_Item(itemId)
                if itemCnt ~= nil then
                    local sourceCard = CS.Torappu.Battle.BattleController.instance:GetDeck(CS.Torappu.PlayerSide.DEFAULT):FindCard(character.data.uniqueId)
                    if sourceCard ~= nil and sourceCard.remainingCnt == itemCnt then
                        return
                    end
                end
            end
        end
    end

    self:RecordUsingConstructItem(character)
end

function SandboxBattleDataControllerHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.Sandbox.SandboxBattleDataController)
    xlua.private_accessible(CS.Torappu.Battle.GameMode.GameModeFactory.SandboxGameMode)
    xlua.private_accessible(CS.Torappu.SandboxV2Data)
    xlua.private_accessible(CS.Torappu.Battle.Character)

    self:Fix_ex(CS.Torappu.Battle.Sandbox.SandboxBattleDataController, "RecordUsingConstructItem", function(self, character)
        local ok, errorInfo = xpcall(RecordUsingConstructItemFix, debug.traceback, self, character)
        if not ok then
            LogError("[SandboxBattleDataControllerHotfixer] fix" .. errorInfo)
        end
    end)
end

function SandboxBattleDataControllerHotfixer:OnDispose()
end

return SandboxBattleDataControllerHotfixer