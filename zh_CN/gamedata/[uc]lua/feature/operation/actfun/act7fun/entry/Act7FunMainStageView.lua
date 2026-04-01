











Act7FunMainStageView = Class("Act7FunMainStageView", UIWidget)

function Act7FunMainStageView:OnInitWithDlg(dlg, viewModel)
  self.m_dlg = dlg

  self:AddButtonClickListener(self._btnStage, self._EventOnStageClick)
  if viewModel == nil or self._stageId == nil or self._stageId == "" then
    return;
  end
  local stageModel = viewModel.stageModels[self._stageId];
  if stageModel == nil or stageModel.stageData == nil then
    return;
  end
  self:_Render(stageModel);
end

function Act7FunMainStageView:_Render(stageModel)
  SetGameObjectActive(self._partLocked, not stageModel.isUnlocked);
  SetGameObjectActive(self._partOpened, stageModel.isUnlocked);
  self._textCode.text = stageModel.stageData.code;
  SetGameObjectActive(self._partPass, stageModel.hasPassed);
  SetGameObjectActive(self._partPerfect, stageModel.hasPerfect);
  SetGameObjectActive(self._newTrackPoint, self:_CheckNewTrack());
  self._textStageName.text = stageModel.stageData.name;
end

function Act7FunMainStageView:_EventOnStageClick()
  if self.m_dlg == nil then
    return;
  end
  self.m_dlg:EventOnStageClick(self._stageId);
end

function Act7FunMainStageView:_CheckNewTrack()
  return CS.Torappu.LocalTrackStore.instance:CheckTrack(CS.Torappu.Activity.Act7fun.Act7FunUtils.ACT7FUN_NEW_STAGE_TRACK_TYPE, self._stageId);
end

return Act7FunMainStageView