


local OpenServerV3GiftPackageToggleView = Class("OpenServerV3GiftPackageToggleView", UIWidget);


function OpenServerV3GiftPackageToggleView:Render(isSelected)
  SetGameObjectActive(self._panelSelected, isSelected);
  SetGameObjectActive(self._panelUnselected, not isSelected);
end

return OpenServerV3GiftPackageToggleView;
