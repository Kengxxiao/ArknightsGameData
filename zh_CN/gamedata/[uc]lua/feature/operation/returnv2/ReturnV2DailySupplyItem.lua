






local ReturnV2DailySupplyItem = Class("ReturnV2DailySupplyItem", UIWidget)




function ReturnV2DailySupplyItem:Render(state, needLeftLight, needRightLight)
  SetGameObjectActive(self._objUnCompleteIcon, state == ReturnV2DailySupplyState.UNCOMPLETE)
  SetGameObjectActive(self._objCanClaimLight, state == ReturnV2DailySupplyState.CAN_CLAIM)
  SetGameObjectActive(self._objCompletedIcon, state ~= ReturnV2DailySupplyState.UNCOMPLETE)
  SetGameObjectActive(self._objCompleteBkg, state ~= ReturnV2DailySupplyState.UNCOMPLETE and not needRightLight)
  SetGameObjectActive(self._objLeftLight, needLeftLight)
  SetGameObjectActive(self._objRightLight, needRightLight)
end

return ReturnV2DailySupplyItem