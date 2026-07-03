local UICharacterTabGroupAddtionHotfixer = Class("UICharacterTabGroupAddtionHotfixer", HotfixBase)

local function _EnableTab(self, isActive)
  local uiController = CS.Torappu.Battle.UI.UIController.instance
  local tabGroupPanel = uiController.characterInfo.tabGroupSubPanelCasted
  if tabGroupPanel ~= nil
      and self._additionInfoTab.transform.parent ~= tabGroupPanel.uiCharacterTabGroup.infoTabRoot.transform then
    self:OnInit(uiController)
  end
  self:EnableTab(isActive)
end

function UICharacterTabGroupAddtionHotfixer:OnInit()
  if HOTFIX_ENABLE then
    local addtionType = CS.Torappu.Battle.UI.UICharacterTabGroupAddtion
    xlua.private_accessible(addtionType)
    self:Fix_ex(addtionType, "EnableTab", function(self, isActive)
      local ok, errorInfo = xpcall(_EnableTab, debug.traceback, self, isActive)
      if not ok then
        LogError("[UICharacterTabGroupAddtionHotfixer] fix EnableTab: " .. errorInfo)
      end
    end)
  end
end

function UICharacterTabGroupAddtionHotfixer:OnDispose()
end

return UICharacterTabGroupAddtionHotfixer
