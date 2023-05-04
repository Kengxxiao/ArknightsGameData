








local CheckinAllPlayerMainView = Class("CheckinAllPlayerMainView", UIPanel);


function CheckinAllPlayerMainView:OnViewModelUpdate(data)
  for itemId, endTime in pairs(data.activityData.apSupplyOutOfDateDict) do
    local endt = CS.Torappu.DateTimeUtil.TimeStampToDateTime(endTime);
    self._apTime.text = CS.Torappu.FormatUtil.FormatDateTimeyyyyMMddHHmm(endt);
    break;
  end
  self._charName.text = data.activityData.constData.characterName;
  self._skinName.text = data.activityData.constData.skinName;

  local skinTimeValid = data.skinDay ~= nil;
  SetGameObjectActive(self._skinStatusPanel, skinTimeValid);
  if skinTimeValid then
    SetGameObjectActive(self._skinCanGetNode, data.skinDay == 0);
    SetGameObjectActive(self._skinGotNode, data.skinDay < 0);
    SetGameObjectActive(self._skinTimeNode, data.skinDay > 0);
    self._skinGetTime.text = tostring(data.skinDay);
  end
end

return CheckinAllPlayerMainView;