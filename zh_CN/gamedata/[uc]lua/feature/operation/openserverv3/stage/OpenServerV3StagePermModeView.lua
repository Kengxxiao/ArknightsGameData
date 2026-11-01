




local OpenServerV3StagePermModeView = Class("OpenServerV3StagePermModeView", UIWidget);

function OpenServerV3StagePermModeView:OnInitialize()
  self:AddButtonClickListener(self._btnMain, self._EventOnMainClicked);
end


function OpenServerV3StagePermModeView:Render(model)
  if model == nil then
    return;
  end
  SetGameObjectActive(self._panelLocked, not model.isPermModeUnlock);
  self._textLocked.text = model.permModeLockedTip or "";
end


function OpenServerV3StagePermModeView:_EventOnMainClicked()
  if self.onMainClicked ~= nil then
    self.onMainClicked:Call();
  end
end

return OpenServerV3StagePermModeView;
