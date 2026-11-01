









local OpenServerV3StageResourceView = Class("OpenServerV3StageResourceView", UIWidget);

function OpenServerV3StageResourceView:OnInitialize()
  self:AddButtonClickListener(self._btnMain, self._EventOnMainClicked);
end


function OpenServerV3StageResourceView:Render(model)
  if model == nil then
    return;
  end
  SetGameObjectActive(self._panelLocked, not model.isResourceUnlock);
  SetGameObjectActive(self._panelUnlocked, model.isResourceUnlock);
  self._textLocked.text = model.resourceLockedTip or "";
  SetGameObjectActive(self._panelFullOpen, model.showResourceFullOpen);
  SetGameObjectActive(self._panelPause, model.isResourceFullOpenPaused);
  SetGameObjectActive(self._partRemainTime,
      model.showResourceFullOpen or model.isResourceFullOpenPaused);
  self._textRemainTime.text = model.resourceRemainTimeDesc or "";
end


function OpenServerV3StageResourceView:_EventOnMainClicked()
  if self.onMainClicked ~= nil then
    self.onMainClicked:Call();
  end
end

return OpenServerV3StageResourceView;
