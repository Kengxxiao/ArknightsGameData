



local BlessOnlyBlessListSliderItemView = Class("BlessOnlyBlessListSliderItemView", UIPanel);


function BlessOnlyBlessListSliderItemView:Render(isSelect)
  SetGameObjectActive(self._darkState, not(isSelect));
  SetGameObjectActive(self._lightState, isSelect);
end

return BlessOnlyBlessListSliderItemView;