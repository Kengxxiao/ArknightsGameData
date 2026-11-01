










local OpenServerV3TabEntryView = Class("OpenServerV3TabEntryView", UIWidget);
local SELECT_STATE = CS.Torappu.UI.TwoStateFadeSwitcher.State.SELECT;
local UNSELECT_STATE = CS.Torappu.UI.TwoStateFadeSwitcher.State.UNSELECT;

function OpenServerV3TabEntryView:OnInitialize()
  self:AddButtonClickListener(self._btnTab, self._EventOnClick);
end



function OpenServerV3TabEntryView:Init(tabState, onClickEvent)
  self.m_tabState = tabState;
  self.eventOnClick = onClickEvent;
end


function OpenServerV3TabEntryView:GetTabState()
  return self.m_tabState;
end


function OpenServerV3TabEntryView:Render(model)
  if model == nil then
    return;
  end
  SetGameObjectActive(self.m_root, model.visible);
  if not model.visible then
    return;
  end
  self._toggleTab.state = model.selected and SELECT_STATE or UNSELECT_STATE;
  SetGameObjectActive(self._panelNew, model.hasNewSign and not model.hasTrackPoint);
  SetGameObjectActive(self._panelTimeLimit, model.showTimeLimitTip);
end


function OpenServerV3TabEntryView:BindTrackPoint(trackType)
  if trackType == nil or self._trackPoint == nil then
    return;
  end
  self.m_trackType = trackType;
  TrackPointModel.me:BindUI(trackType, self._trackPoint);
end

function OpenServerV3TabEntryView:OnDispose()
  if self.m_trackType ~= nil then
    TrackPointModel.me:UnbindUI(self.m_trackType);
    self.m_trackType = nil;
  end
end


function OpenServerV3TabEntryView:_EventOnClick()
  if self.eventOnClick == nil or self.m_tabState == nil then
    return;
  end
  self.eventOnClick:Call(self.m_tabState);
end

return OpenServerV3TabEntryView;
