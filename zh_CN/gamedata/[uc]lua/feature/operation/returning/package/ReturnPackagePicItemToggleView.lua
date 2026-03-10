


local ReturnPackagePicItemToggleView = Class("ReturnPackagePicItemToggleView", UIWidget);

function ReturnPackagePicItemToggleView:OnInitialize()
end


function ReturnPackagePicItemToggleView:Render(isOn)
  self._toggleGPItem.selected = isOn;
end

return ReturnPackagePicItemToggleView;