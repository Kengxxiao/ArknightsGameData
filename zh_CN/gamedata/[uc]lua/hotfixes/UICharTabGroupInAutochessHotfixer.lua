




local UICharTabGroupInAutochessHotfixer = Class("UICharTabGroupInAutochessHotfixer", HotfixBase)

local function _RefreshEquipDataFix(self, characterPtr, mode, card)
  if mode ~= CS.Torappu.Battle.UI.UICharacterInfoPanel.ModeType.RUNTIME_CHARACTER_MODE then
    return false
  end

  if not characterPtr.isValid then
    return false
  end

  local character = characterPtr:Lock()
  local instId = -1
  local hasInstId = CS.Torappu.Battle.AutoChess.AutoChessBattleUtil.TryGetCharacterInstId(character, instId)

  if hasInstId then
    return self:_UpdateEquip(character.gridPosition)
  end

  for pairI = 0, self.m_equipTextPair.Count - 1 do
    CS.Torappu.GameObjectUtil.SetActiveIfNecessary(self.m_equipTextPair[pairI].gameObject, false)
  end
  return false
end

function UICharTabGroupInAutochessHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.UI.UICharacterInfoTabGroupSubPanelInAutochess)
  self:Fix_ex(CS.Torappu.Battle.UI.UICharacterInfoTabGroupSubPanelInAutochess, "_RefreshEquipData",
    function(self, characterPtr, mode, card)
      local ok, errorInfo = xpcall(_RefreshEquipDataFix, debug.traceback, self, characterPtr, mode, card)
      if not ok then
        LogError("[UICharTabGroupInAutochessHotfixer] _RefreshEquipDataFix fix: " .. tostring(errorInfo))
        self:_RefreshEquipData(characterPtr, mode, card)
      end
    end)
end

return UICharTabGroupInAutochessHotfixer
