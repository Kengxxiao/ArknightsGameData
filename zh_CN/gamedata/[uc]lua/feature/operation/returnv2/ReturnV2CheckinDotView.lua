local ReturnV2CheckinRewardModel = require("Feature/Operation/ReturnV2/ReturnV2CheckinRewardModel")





local ReturnV2CheckinDotView = Class("ReturnV2CheckinDotView", UIWidget)

ReturnV2CheckinDotView.INCOMING_COLOR = {r=0.3, g=0.3, b=0.3, a=1}
ReturnV2CheckinDotView.ACTIVE_COLOR = {r=1, g=1, b=1, a=1}




function ReturnV2CheckinDotView:Render(itemModel, isLatest)
  local isImportant = itemModel:IsImportant()
  local dotState = itemModel:GetState()

  if dotState >= ReturnV2CheckinRewardModel.SIGN_REWARD_STATE.CAN_GAIN then
    self._imgNormal.color = self.ACTIVE_COLOR
    self._imgImportant.color = self.ACTIVE_COLOR
  else
    self._imgNormal.color = self.INCOMING_COLOR
    self._imgImportant.color = self.INCOMING_COLOR
  end

  local isHighlight = isLatest and dotState == ReturnV2CheckinRewardModel.SIGN_REWARD_STATE.CAN_GAIN
  SetGameObjectActive(self._imgHighlight.gameObject, isHighlight)
  SetGameObjectActive(self._imgNormal.gameObject, not isImportant and not isHighlight)
  SetGameObjectActive(self._imgImportant.gameObject, isImportant and not isHighlight)
end

return ReturnV2CheckinDotView