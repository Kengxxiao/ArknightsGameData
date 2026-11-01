local luaUtils = CS.Torappu.Lua.Util;
















local OpenServerV3MissionStageItemView = Class("OpenServerV3MissionStageItemView", UIWidget);

function OpenServerV3MissionStageItemView:OnInitialize()
  if self._btnStage ~= nil then
    self:AddButtonClickListener(self._btnStage, self._EventOnClicked);
  end
end



function OpenServerV3MissionStageItemView:Render(viewModel, isLast)
  if viewModel == nil then
    return;
  end
  self.m_viewModel = viewModel;
  if self._textStage ~= nil then
    self._textStage.text = string.format("%02d", viewModel.index);
  end
  SetGameObjectActive(self._panelSelected, viewModel.selected);
  SetGameObjectActive(self._panelCompleted, viewModel.completed);
  SetGameObjectActive(self._panelLocked, viewModel.locked);
  SetGameObjectActive(self._separator, not isLast);
  self:_RefreshStageAlpha(viewModel);
end


function OpenServerV3MissionStageItemView:BindTrackPoint(trackType)
  if trackType == nil or self._trackPoint == nil then
    return;
  end
  self.m_trackType = trackType;
  TrackPointModel.me:BindUI(trackType, self._trackPoint);
end

function OpenServerV3MissionStageItemView:OnDispose()
  if self.m_trackType ~= nil then
    TrackPointModel.me:UnbindUI(self.m_trackType);
    self.m_trackType = nil;
  end
end



function OpenServerV3MissionStageItemView:_RefreshStageAlpha(viewModel)
  local alpha = self:_GetStageAlpha(viewModel);
  if self._imgStage ~= nil then
    luaUtils.SetGraphicAlpha(self._imgStage, alpha);
  end
  if self._textStage ~= nil then
    luaUtils.SetGraphicAlpha(self._textStage, alpha);
  end
end




function OpenServerV3MissionStageItemView:_GetStageAlpha(viewModel)
  if viewModel.locked then
    return tonumber(self._alphaLocked);
  elseif viewModel.selected then
    return tonumber(self._alphaSelected);
  end
  return tonumber(self._alphaNormal);
end


function OpenServerV3MissionStageItemView:_EventOnClicked()
  if self.m_viewModel == nil or self.onClicked == nil then
    return;
  end
  self.onClicked:Call(self.m_viewModel.index);
end

return OpenServerV3MissionStageItemView;
