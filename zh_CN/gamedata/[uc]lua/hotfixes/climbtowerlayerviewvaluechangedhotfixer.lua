
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

local function MultiEditSaveEditDictFix(self)
  local editDict = CS.System.Collections.Generic.Dictionary(CS.System.String, CS.Torappu.UI.ClimbTower.ClimbTowerCharEditCacheModel)()
  local squadModel = self.prop:GetValueNotNull()

  for i = 0, squadModel.charEditList.Count-1 do
    local charModel = squadModel.charEditList[i]
    if not editDict:ContainsKey(charModel.cardModel.charId) then
      local editModel = CS.Torappu.UI.ClimbTower.ClimbTowerCharEditCacheModel()
      editModel.charId = charModel.cardModel.charId
      editModel.tmplId = charModel.cardModel.tmplId
      editModel.skillId = charModel.cardModel.skillId
      editModel.equipId = charModel.cardModel.equipId
      editDict:Add(charModel.cardModel.charId, editModel)
    end
  end

  CS.Torappu.UI.ClimbTower.ClimbTowerLocalCache.instance:SaveSquadEditDict(editDict)
end

local function SingleEditSaveEditDictFix(self)
  local editDict = CS.System.Collections.Generic.Dictionary(CS.System.String, CS.Torappu.UI.ClimbTower.ClimbTowerCharEditCacheModel)()
  local squadModel = self.m_squadProp:GetValueNotNull()

  for i = 0, squadModel.squadItemList.Count-1 do
    local charModel = squadModel.squadItemList[i]
    if not editDict:ContainsKey(charModel.cardModel.charId) then
      local editModel = CS.Torappu.UI.ClimbTower.ClimbTowerCharEditCacheModel()
      editModel.charId = charModel.cardModel.charId
      editModel.tmplId = charModel.cardModel.tmplId
      editModel.skillId = charModel.cardModel.skillId
      editModel.equipId = charModel.cardModel.equipId
      editDict:Add(charModel.cardModel.charId, editModel)
    end
  end

  CS.Torappu.UI.ClimbTower.ClimbTowerLocalCache.instance:SaveSquadEditDict(editDict)
end

function ClimbTowerLayerViewValueChangedHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.ClimbTower.ClimbTowerLayerView)

  self:Fix_ex(CS.Torappu.UI.ClimbTower.ClimbTowerLayerView, "OnValueChanged", function(self, property)
    local ok, errorInfo = xpcall(OnValueChangedFix, debug.traceback, self, property)
    if not ok then
      eutil.LogError("[ClimbTowerLayerViewValueChangedHotfixer] fix" .. errorInfo)
    end
  end)

  xlua.private_accessible(CS.Torappu.UI.ClimbTower.ClimbTowerSquadMultiEditStateBean)

  self:Fix_ex(CS.Torappu.UI.ClimbTower.ClimbTowerSquadMultiEditStateBean, "SaveEditDict", function(self)
    local ok, errorInfo = xpcall(MultiEditSaveEditDictFix, debug.traceback, self)
    if not ok then
      eutil.LogError("[ClimbTowerSquadMultiEditStateBeanHotfixer] fix" .. errorInfo)
    end
  end)

  xlua.private_accessible(CS.Torappu.UI.ClimbTower.ClimbTowerSquadSingleEditStateBean)

  self:Fix_ex(CS.Torappu.UI.ClimbTower.ClimbTowerSquadSingleEditStateBean, "SaveEditDict", function(self)
    local ok, errorInfo = xpcall(SingleEditSaveEditDictFix, debug.traceback, self)
    if not ok then
      eutil.LogError("[ClimbTowerSquadSingleEditStateBeanHotfixer] fix" .. errorInfo)
    end
  end)
end

function ClimbTowerLayerViewValueChangedHotfixer:OnDispose()
end

return ClimbTowerLayerViewValueChangedHotfixer