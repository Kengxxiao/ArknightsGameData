














local RecruitOnlyItemView = Class("RecruitOnlyItemView", UIPanel);


function RecruitOnlyItemView:OnInit(isPreview)
  self.m_isPreview = isPreview;
end


function RecruitOnlyItemView:OnViewModelUpdate(data)
  if data == nil then
    return; 
  end

  local viewModel = data.recruitModel;
  if self.m_isPreview then
    viewModel = data.previewModel;
  end

  if viewModel == nil then
    return; 
  end
  
  SetGameObjectActive(self._panelNotUse, not viewModel.isUsed);
  SetGameObjectActive(self._phaseOne, not viewModel.isPhaseTwo);
  SetGameObjectActive(self._phaseTwo, viewModel.isPhaseTwo);

  self._upperTagName.text = viewModel.tagName;
  self._centerTagName.text = viewModel.tagName;
  self._upTimes1.text = tostring(viewModel.upTimes);
  self._bottomDesc.text = viewModel.desc1;

  if self._panelUsed ~= nil then 
    SetGameObjectActive(self._panelUsed, viewModel.isUsed);
  end
  if self._centerDesc ~= nil then 
    self._centerDesc.text = viewModel.desc2;
  end
  if self._startTime ~= nil then 
    self._startTime.text = viewModel.startTimeDesc;
  end
  if self._endTime ~= nil then 
    self._endTime.text = viewModel.endTimeDesc;
  end
  if self._upTimes2 ~= nil then 
    self._upTimes2.text = viewModel.upTimes;
  end
end

return RecruitOnlyItemView