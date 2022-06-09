
local ClimbTowerLayerViewValueChangedHotfixer = Class("ClimbTowerLayerViewValueChangedHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

local function OnValueChangedFix(self, property)
  local model = property.Value;
  if model == nil then
    return;
  end
  if model.towerModel == nil then
    return;
  end
  if model.selectedLevelModel == nil then
    return;
  end
  self:OnValueChanged(property)
end

function ClimbTowerLayerViewValueChangedHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.ClimbTower.ClimbTowerLayerView)

  self:Fix_ex(CS.Torappu.UI.ClimbTower.ClimbTowerLayerView, "OnValueChanged", function(self, property)
    local ok, errorInfo = xpcall(OnValueChangedFix, debug.traceback, self, property)
    if not ok then
      eutil.LogError("[ClimbTowerLayerViewValueChangedHotfixer] fix" .. errorInfo)
    end
  end)
end

function ClimbTowerLayerViewValueChangedHotfixer:OnDispose()
end

return ClimbTowerLayerViewValueChangedHotfixer