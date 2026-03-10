











local ReturnSpecialOpenEntryView = Class("ReturnSpecialOpenMultiView", UIPanel);

function ReturnSpecialOpenEntryView:OnInit()
  self:AddButtonClickListener(self._btnEntry, self._EventOnClick);
end



function ReturnSpecialOpenEntryView:Render(model, selectedType)
  if model == nil then
    return;
  end
  self.m_cachedType = model.specialOpenType;
  self._imgEntry.sprite = self:_LoadSprite(CS.Torappu.ResourceUrls.GetReturnAllOpenEntryHubPath(), model.imgEntryId);
  self._textName.text = model.name;

  local isSelected = selectedType == model.specialOpenType;
  self._selectedToggle.selected = isSelected;

  local isActive = model.openState ~= ReturnSpecialOpenState.END;
  self._remainTimeToggle.selected = isActive;
  self._remainTimeText.text = model.remainTimeDesc;
end





function ReturnSpecialOpenEntryView:_LoadSprite(hubPath, spriteName)
  if self.loadFunc == nil then
    return nil;
  end
  return self.loadFunc(hubPath, spriteName);
end

function ReturnSpecialOpenEntryView:_EventOnClick()
  if self.onEntryClick == nil then
    return;
  end
  self.onEntryClick:Call(self.m_cachedType);
end

return ReturnSpecialOpenEntryView;