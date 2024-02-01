




local AttachListenerToTileAbilityHotfixer = Class("AttachListenerToTileAbilityHotfixer", HotfixBase)

local function _FixGetTileCastedTimes(self, tile)
  if tile == nil then
    return 0
  end
  return self:GetTileCastedTimes(tile)
end

function AttachListenerToTileAbilityHotfixer:OnInit()
  self:Fix_ex(CS.Torappu.Battle.Abilities.AttachListenerToTileAbility, "GetTileCastedTimes", function(self, tile)
    local ok, ret = xpcall(_FixGetTileCastedTimes, debug.traceback, self, tile)
    if not ok then
      LogError("[Hotfix] failed to _FixGetTileCastedTimes : ".. ret)
      return self:GetTileCastedTimes(tile)
    else
      return ret
    end
  end)
end

return AttachListenerToTileAbilityHotfixer