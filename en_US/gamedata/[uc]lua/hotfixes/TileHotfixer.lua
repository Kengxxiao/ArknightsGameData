local TileHotfixer = Class("TileHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

local function CheckBuildableFix(self, character)
    local autoReplay = CS.Torappu.Battle.BattleController.instance.isAutoReplayOn
    if autoReplay and character.data == nil and string.find(character.name, "trap_102_mhwrbg") then
      return true
    end
    return self:CheckBuildable(character)
end

function TileHotfixer:OnInit()
    self:Fix_ex(CS.Torappu.Battle.Tile, "CheckBuildable", function(self, character)
        return CheckBuildableFix(self, character)
    end)
end

function TileHotfixer:OnDispose()
end

return TileHotfixer