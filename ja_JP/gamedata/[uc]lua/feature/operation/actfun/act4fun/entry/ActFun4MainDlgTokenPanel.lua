local luaUtils = CS.Torappu.Lua.Util;














ActFun4MainDlgTokenPanel = Class("ActFun4MainDlgTokenPanel", UIPanel)
ActFun4MainDlgTokenPanel.FADE_DUR = 0.4


function ActFun4MainDlgTokenPanel:Init()
  self:AddButtonClickListener(self._btnClose, self._EventOnCloseBtnClick)
  self:_SetVisible(false)
end

function ActFun4MainDlgTokenPanel:Update(tokenModel, isShow)
  self:_SetVisible(isShow)
  if not isShow then
    return
  end
  self._txtLevel.text = tokenModel.level
  SetGameObjectActive(self._panelLevelMax, tokenModel:IsLevelMax())
  self._txtLevelDesc.text = self:_GeneLevelDescStr(tokenModel)
  self._txtTokenDesc.text = tokenModel.tokenDesc
end

function ActFun4MainDlgTokenPanel:_SetVisible(visible)
  self.m_isVisible = visible
  if self._canvasGroup == nil then
    ActFun4MainDlgTokenPanel.super.SetVisible(self, visible)
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

function ActFun4MainDlgTokenPanel:_GeneLevelDescStr(tokenModel)
  local str = ''
  for i = 1, #tokenModel.levelDescs do
    if str ~= '' then
      str = str .. '\n'
    end
    local desc = ''
    
    if i <= tokenModel.level - 1 then
      desc = luaUtils.Format(self._validFormat, tokenModel.levelDescs[i])
    else
      desc = tokenModel.levelDescs[i]
    end
    str = str .. desc
  end
  return str
end

function ActFun4MainDlgTokenPanel:_EventOnCloseBtnClick()
  if not self.m_isVisible then
    return
  end
  self:_SetVisible(false)
end