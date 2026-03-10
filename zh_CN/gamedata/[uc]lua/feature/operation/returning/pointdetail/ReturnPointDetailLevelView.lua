


local ReturnPointDetailLevelView = Class("ReturnPointDetailLevelView", UIWidget);



function ReturnPointDetailLevelView:Render(model, isFirst)
  if model == nil then
    return;
  end
  self._textPoint.text = model.pointRequire;
  SetGameObjectActive(self._panelArrow, not isFirst);
end

return ReturnPointDetailLevelView;