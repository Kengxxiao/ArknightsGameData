local CheckinVsMainViewModel = require("Feature/Activity/CheckinVs/CheckinVsMainViewModel")
local CheckinVsDefine = require("Feature/Activity/CheckinVs/CheckinVsDefine")
















local CheckinVsRuleView = Class("CheckinVsRuleView", UIPanel)

CheckinVsRuleView.REWARD_NORMAL_COLOR = {r=1, g=1, b=1, a=1}
CheckinVsRuleView.REWARD_GAINED_COLOR = {r=0.55, g=0.55, b=0.55, a=1}



function CheckinVsRuleView:OnViewModelUpdate(data)
  if data == nil then
    self.m_viewModel = nil
    return
  end
  self.m_viewModel = data

  self:_InitIfNot()

  if data.displayStatus ~= CheckinVsMainViewModel.DisplayStatus.RULE_VIEW then
    self._blurPanel:Hide()
    return
  end

  self._blurPanel:Show()
  self._textSaltyName.text = data:GetSpecialRewardName(true)
  self._textSweetName.text = data:GetSpecialRewardName(false)
  self._textRule.text = data:GetRuleDesc()
  local gainTaste = data:GetRewardGainStatus()
  SetGameObjectActive(self._saltyGainTagGo, gainTaste == CheckinVsDefine.TasteChoice.SALTY)
  SetGameObjectActive(self._sweetGainTagGo, gainTaste == CheckinVsDefine.TasteChoice.SWEET)
  self:SetSpecialRewardColor(self._imgSalty, gainTaste ~= CheckinVsDefine.TasteChoice.NONE)
  self:SetSpecialRewardColor(self._imgSweet, gainTaste ~= CheckinVsDefine.TasteChoice.NONE)
end


function CheckinVsRuleView:_InitIfNot()
  if self.m_hasInited then
    return
  end
  self.m_hasInited = true

  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnClose)
  self:AddButtonClickListener(self._btnBackPress, self._HandleBtnCloseClick)
  self:AddButtonClickListener(self._btnClose, self._HandleBtnCloseClick)
end


function CheckinVsRuleView:_HandleBtnCloseClick()
  self.m_parent:EventOnReturnMainView()
end



function CheckinVsRuleView:SetSpecialRewardColor(image, isGained)
  local imgColor
  if isGained then
    imgColor = self.REWARD_GAINED_COLOR
  else
    imgColor = self.REWARD_NORMAL_COLOR
  end
  image.color = imgColor
end

return CheckinVsRuleView