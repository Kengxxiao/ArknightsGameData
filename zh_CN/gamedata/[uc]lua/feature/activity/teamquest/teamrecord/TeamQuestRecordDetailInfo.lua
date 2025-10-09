







local TeamQuestRecordDetailInfo = Class("TeamQuestRecordDetailInfo", UIPanel)


function TeamQuestRecordDetailInfo:Render(viewModel)
  self._nameText.text = viewModel.data.shareName;
  self._valueText.text = viewModel.value;
  self._iconImg:SetImage(CS.Torappu.ResourceUrls.GetActTeamQuestIconImagePath(viewModel.data.sharePic))
  local targetColor = CS.Torappu.ColorRes.TweenHtmlStringToColor(viewModel.themeColor);
  self._nameText.color = targetColor
  self._valueText.color = targetColor
  self._iconImg:SetColor(targetColor)
end


function TeamQuestRecordDetailInfo:_EventOnTabItemClick(tabType)
end

return TeamQuestRecordDetailInfo