local CheckinVsMainViewModel = require("Feature/Activity/CheckinVs/CheckinVsMainViewModel")
local CheckinVsRecycleRewardListAdapter = require("Feature/Activity/CheckinVs/View/CheckinVsRecycleRewardListAdapter")












local CheckinVsRewardPreview = Class("CheckinVsRewardPreview", UIPanel)



function CheckinVsRewardPreview:OnViewModelUpdate(data)
  if data == nil then
    self.m_viewModel = nil
    return
  end
  self.m_viewModel = data

  self:_InitIfNot()

  if data.displayStatus ~= CheckinVsMainViewModel.DisplayStatus.REWARD_VIEW then
    self._blurPanel:Hide()
    return
  end

  self._blurPanel:Show()

  self.m_adapter:SetViewModel(data)
  self.m_adapter:NotifyDataChanged()
end


function CheckinVsRewardPreview:_InitIfNot()
  if self.m_hasInited then
    return
  end
  self.m_hasInited = true

  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnClose)
  self:AddButtonClickListener(self._btnBackPress, self._HandleBtnCloseClick)
  self:AddButtonClickListener(self._btnClose, self._HandleBtnCloseClick)
  self.m_adapter = self:CreateCustomComponent(CheckinVsRecycleRewardListAdapter, self._rewardListGo, self)

  self._textApItemTime.text = self.m_viewModel:GetApTimeDesc()
end


function CheckinVsRewardPreview:_HandleBtnCloseClick()
  self.m_parent:EventOnReturnMainView()
end

return CheckinVsRewardPreview