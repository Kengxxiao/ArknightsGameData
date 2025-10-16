
local Mainline16ManagerHotfixer = Class("Mainline16ManagerHotfixer", HotfixBase)

local localMap = CS.Torappu.Battle.Map
local function __ChangeBuildableState(self, tile, notBuildable)
  local options = tile.options
  if notBuildable then
    options.advancedBuildMask = CS.Torappu.Battle.AdvancedBuildableMask.RED_FOG
  else
    options.advancedBuildMask = CS.Torappu.Battle.AdvancedBuildableMask.DEFAULT
  end
  tile:RefreshOptionsOnly(options, tile:GetCharacter())
  localMap.instance:SetBuildableDirty(true)
end

function Mainline16ManagerHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.Mainline16Manager)
  self:Fix_ex(CS.Torappu.Battle.Mainline16Manager, "_ChangeBuildableState", function(self, tile, notBuildable)
    local ok, result = xpcall(__ChangeBuildableState, debug.traceback, self, tile, notBuildable)
    if not ok then
      LogError("[Mainline16ManagerHotfixer] fix" .. result)
    end
  end)
end

function Mainline16ManagerHotfixer:OnDispose()
end

return Mainline16ManagerHotfixer
