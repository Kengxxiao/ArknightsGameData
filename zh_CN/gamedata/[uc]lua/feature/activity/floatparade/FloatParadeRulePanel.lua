local FadeSwitchTween = CS.Torappu.UI.FadeSwitchTween
local eutil = CS.Torappu.Lua.Util








FloatParadeRulePanel = Class("FloatParadeRulePanel", UIPanel);

function FloatParadeRulePanel:OnInit()
  self.m_switchTween = FadeSwitchTween(self._canvasGroup, 0.23)
  self.m_switchTween:Reset(false)
  self:AddButtonClickListener(self._btnBlank, FloatParadeRulePanel._Hide)
  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnBlank)
end


function FloatParadeRulePanel:Show(actData)
  if not actData then
    return
  end

  self:_Render(actData)
  
  self._scroll.verticalNormalizedPosition = 1

  if self.m_switchTween ~= nil then
    self.m_switchTween:Show()
  end
end


function FloatParadeRulePanel:_Render(actData)
  local constData = actData.constData
  if not constData then
    LogError("ConstData not provided")
    return
  end
  self._textCityName.text = constData.cityName
  self._textContent.text = eutil.FormatRichTextFromData(constData.ruleDesc)
end

function FloatParadeRulePanel:_Hide()
  if self.m_switchTween ~= nil then
    self.m_switchTween:Hide()
  end
end