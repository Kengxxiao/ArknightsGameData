local CheckinVsMainSignItemView = require("Feature/Activity/CheckinVs/View/CheckinVsMainSignItemView")





local CheckinVsRecycleRewardListAdapter = Class("CheckinVsRecycleRewardListAdapter", UIRecycleAdapterBase)



function CheckinVsRecycleRewardListAdapter:SetViewModel(viewModel)
  self.m_viewModel = viewModel
end




function CheckinVsRecycleRewardListAdapter:ViewConstructor(objPool)
  
  local rewardItem = self:CreateWidgetByPrefab(CheckinVsMainSignItemView, self._itemPrefab, self._container)
  local rootGo = rewardItem:RootGameObject()
  self:AddObj(rewardItem, rootGo)
  return rootGo
end





function CheckinVsRecycleRewardListAdapter:OnRender(transform, index)
  
  local item = self:GetWidget(transform.gameObject)
  local dayIndex = index + 1
  local rewardList = self.m_viewModel:GetRewardList(dayIndex)
  local rewardStatus = self.m_viewModel:GetRewardStatus(dayIndex)
  item:Render(dayIndex, rewardList, rewardStatus)
end



function CheckinVsRecycleRewardListAdapter:GetTotalCount()
  if self.m_viewModel == nil then
    return 0
  end
  return self.m_viewModel:GetRewardListCount()
end

return CheckinVsRecycleRewardListAdapter