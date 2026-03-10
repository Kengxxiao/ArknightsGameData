









local ReturnSpecialOpenResOnlyView = Class("ReturnSpecialOpenResOnlyView", UIPanel);

function ReturnSpecialOpenResOnlyView:OnInit()
  self:AddButtonClickListener(self._gotoBtn, self._EventOnClick);
end


function ReturnSpecialOpenResOnlyView:Render(model)
  if model == nil then
    return;
  end
  local selectedModel = model:GetSelectedOpenTypeModel();
  if selectedModel == nil then
    return;
  end

  SetGameObjectActive(self._pauseGo, selectedModel.openState == ReturnSpecialOpenState.PAUSE);

  local isActive = selectedModel.openState ~= ReturnSpecialOpenState.END;
  self._tagToggle.selected = isActive;
  self._pauseNoticeText.text = selectedModel.pauseDesc;
  self._contentText.text = selectedModel.desc;
  self._remainTimeText.text = selectedModel.remainTimeDesc;
  self._textTitle.text = selectedModel.title;
end

function ReturnSpecialOpenResOnlyView:_EventOnClick()
  if self.onGotoClick == nil then
    return;
  end
  self.onGotoClick:Call();
end

return ReturnSpecialOpenResOnlyView;