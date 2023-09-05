


local MainlineBpBpUpDetailItemView = Class("MainlineBpBpUpDetailItemView", UIWidget);


function MainlineBpBpUpDetailItemView:Render(model)
  self._textStage.text = model.stageCode;
  self._textUpDesc.text = model.upPercentDesc;
end

return MainlineBpBpUpDetailItemView;