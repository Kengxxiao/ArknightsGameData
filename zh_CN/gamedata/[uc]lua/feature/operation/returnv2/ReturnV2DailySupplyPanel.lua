









local ReturnV2DailySupplyPanel = Class("ReturnV2DailySupplyPanel", UIPanel)
local ReturnV2DailySupplyItem = require("Feature/Operation/ReturnV2/ReturnV2DailySupplyItem")

function ReturnV2DailySupplyPanel:OnInit()
  self.m_canClaimReward = false
  self.m_dailySupplyStateList = {}
  self.m_dailySupplyAdapter = self:CreateCustomComponent(
      UISimpleLayoutAdapter, self, self._layoutSupplyProgress,
      self._CreateDailySupplyItemView, self._GetDailySupplyItemCount, 
      self._UpdateDailySupplyItemView)
  self:AddButtonClickListener(self._btnClick, self._HandleClick)
end




function ReturnV2DailySupplyPanel:Render(dailySupplyStateList, canClaimReward, lastCompleteDayIndex)
  self.m_dailySupplyStateList = dailySupplyStateList
  self.m_canClaimReward = canClaimReward
  self.m_lastCompleteDayIndex = lastCompleteDayIndex
  self.m_dailySupplyAdapter:NotifyDataSetChanged()
  SetGameObjectActive(self._objCanClaimRewardBkg, self.m_canClaimReward)
end



function ReturnV2DailySupplyPanel:_CreateDailySupplyItemView(gameObj)
  local item = self:CreateWidgetByGO(ReturnV2DailySupplyItem, gameObj)
  return item
end


function ReturnV2DailySupplyPanel:_GetDailySupplyItemCount()
  return #self.m_dailySupplyStateList
end



function ReturnV2DailySupplyPanel:_UpdateDailySupplyItemView(index, view)
  local dayIndex = index + 1
  local state = self.m_dailySupplyStateList[dayIndex]

  view:Render(state, dayIndex == 1 and state ~= ReturnV2DailySupplyState.UNCOMPLETE,
       dayIndex == self.m_lastCompleteDayIndex)
end

function ReturnV2DailySupplyPanel:_HandleClick()
  if self.m_canClaimReward and self.claimDailySupplyEvent then
    self.claimDailySupplyEvent:Call()
    return
  end
  if not self.m_canClaimReward and self.openDetailEvent then
    self.openDetailEvent:Call()
    return
  end
end

return ReturnV2DailySupplyPanel