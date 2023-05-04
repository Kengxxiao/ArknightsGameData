





local Act4funLiveValueChangeFlag = Class("Act4funLiveValueChangeFlag", UIWidget);



function Act4funLiveValueChangeFlag:Render(changeValue, threshold)
  local hide = changeValue == 0;
  self:SetVisible(not hide);
  if hide then
    return;
  end

  if changeValue == nil then
    changeValue = 0;
  end
  SetGameObjectActive(self._unknown, changeValue == 0);
  SetGameObjectActive(self._up1, changeValue > 0);
  SetGameObjectActive(self._up2, changeValue >= threshold);
  SetGameObjectActive(self._down1, changeValue < 0);
  SetGameObjectActive(self._down2, changeValue <= -threshold);
end

return Act4funLiveValueChangeFlag;