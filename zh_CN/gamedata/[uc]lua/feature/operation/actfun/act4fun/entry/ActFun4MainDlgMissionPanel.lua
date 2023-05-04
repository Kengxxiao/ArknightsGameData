local luaUtils = CS.Torappu.Lua.Util;
local ActFun4MainDlgMissionItem = require "Feature/Operation/ActFun/Act4fun/Entry/ActFun4MainDlgMissionItem";












ActFun4MainDlgMissionPanel = Class("ActFun4MainDlgMissionPanel", UIPanel)
ActFun4MainDlgMissionPanel.FADE_DUR = 0.4


function ActFun4MainDlgMissionPanel:Init()
  self:AddButtonClickListener(self._btnClose, self._EventOnCloseBtnClick)
  self.m_missionAdapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._missionLayout, 
      self._CreateCard, self._GetCardCount, self._UpdateCard);
  self:_SetVisible(false)
end

function ActFun4MainDlgMissionPanel:Update(missionModels, isShow)
  self:_SetVisible(isShow)
  if not isShow then
    return
  end
  self.m_missionModels = missionModels
  self.m_missionAdapter:NotifyDataSetChanged();
end

function ActFun4MainDlgMissionPanel:_SetVisible(visible)
  self.m_isVisible = visible
  if self._canvasGroup == nil then
    ActFun4MainDlgMissionPanel.super.SetVisible(self, visible)
    return;
  end
  if self.m_fadeTween then
    self.m_fadeTween.isShow = visible
  else
    self.m_fadeTween = CS.Torappu.UI.FadeSwitchTween(self._canvasGroup)
    self.m_fadeTween.duration = self.FADE_DUR
    self.m_fadeTween:Reset(visible)
  end
end

function ActFun4MainDlgMissionPanel:_CreateCard(gameObj)
  local card = self:CreateWidgetByGO(ActFun4MainDlgMissionItem, gameObj)
  return card;
end

function ActFun4MainDlgMissionPanel:_GetCardCount()
  if self.m_missionModels == nil then
    return 0
  end
  return #self.m_missionModels
end

function ActFun4MainDlgMissionPanel:_UpdateCard(index, card)
  local idx = index + 1;
  card:Update(self.m_missionModels[idx])
end


function ActFun4MainDlgMissionPanel:_EventOnCloseBtnClick()
  if not self.m_isVisible then
    return
  end
  self:_SetVisible(false)
end