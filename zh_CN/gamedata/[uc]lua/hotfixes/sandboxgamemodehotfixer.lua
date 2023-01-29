
local eutil = CS.Torappu.Lua.Util


local SandboxGameModeHotfixer = Class("SandboxGameModeHotfixer", HotfixBase)

local function _RecordPlacedItemState(self, targetKey, newStatus)
    local tile = CS.Torappu.Battle.Map.instance.GetTile(CS.Torappu.Battle.Map.instance, targetKey.position)
    if tile ~= nil then
       local character = tile:GetCharacter()
       if character ~= nil then
          newStatus.statusHpRatio = character.hpRatio:AsFloat()
       end
    end

    self:RecordPlacedItemState(targetKey, newStatus)
end

function SandboxGameModeHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.GameMode.GameModeFactory.DefaultGameMode)
    xlua.private_accessible(CS.Torappu.Battle.GameMode.GameModeFactory.SandboxGameMode)
    xlua.private_accessible(CS.Torappu.Battle.Map)

    self:Fix_ex(CS.Torappu.Battle.GameMode.GameModeFactory.SandboxGameMode, "RecordPlacedItemState",
        function(self, targetKey, newStatus)
            local ok, errorInfo = xpcall(_RecordPlacedItemState, debug.traceback, self, targetKey, newStatus)
            if not ok then
                eutil.LogError("[SandboxGameMode] RecordPlacedItemState fix" .. errorInfo)
            end
        end)
end

function SandboxGameModeHotfixer:OnDispose()
end

return SandboxGameModeHotfixer
