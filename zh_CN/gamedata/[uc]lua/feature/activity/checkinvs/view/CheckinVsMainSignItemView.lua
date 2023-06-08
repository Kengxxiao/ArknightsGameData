local CheckinVsMainRewardItemView = require("Feature/Activity/CheckinVs/View/CheckinVsMainRewardItemView")
local CheckinVsMainViewModel = require("Feature/Activity/CheckinVs/CheckinVsMainViewModel")












local CheckinVsMainSignItemView = Class("CheckinVsMainSignItemView", UIPanel)





function CheckinVsMainSignItemView:Render(dayIndex, rewardList, rewardStatus)
  self:_InitIfNot()

  self._textSignCnt.text = tostring(dayIndex)
  self.m_rewardList = rewardList
  self.m_rewardListAdapter:NotifyDataSetChanged()

  SetGameObjectActive(self._normalBgGo, rewardStatus ~= CheckinVsMainViewModel.RewardStatus.ACTIVE)
  SetGameObjectActive(self._activeBgGo, rewardStatus == CheckinVsMainViewModel.RewardStatus.ACTIVE)
  SetGameObjectActive(self._finishMaskGo, rewardStatus == CheckinVsMainViewModel.RewardStatus.FINISH)
end



function CheckinVsMainSignItemView:SetSignFunc(onSignClick)
  self.m_onItemClick = onSignClick
end


function CheckinVsMainSignItemView:_InitIfNot()
  if self.m_hasInited then
    return
  end
  self.m_hasInited = true

  self:AddButtonClickListener(self._btnSign, self._HandleBtnSignClick)
  self.m_rewardListAdapter = self:CreateCustomComponent(
      UISimpleLayoutAdapter, self, self._rewardList, self._CreateRewardItemView,
      self._GetRewardItemCount, self._UpdateRewardItemView)
end


function CheckinVsMainSignItemView:_HandleBtnSignClick()
  if self.m_onItemClick == nil then
    return
  end
  self.m_onItemClick()
end



function CheckinVsMainSignItemView:_CreateRewardItemView(gameObj)
  local itemView = self:CreateWidgetByGO(CheckinVsMainRewardItemView, gameObj)
  return itemView
end


function CheckinVsMainSignItemView:_GetRewardItemCount()
  if self.m_rewardList == nil then
    return 0
  end

  return self.m_rewardList.Count
end




function CheckinVsMainSignItemView:_UpdateRewardItemView(index, itemView)
  itemView:Render(self.m_rewardList[index])
end

return CheckinVsMainSignItemView