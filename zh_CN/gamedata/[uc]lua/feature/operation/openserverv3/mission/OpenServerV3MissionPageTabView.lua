







local OpenServerV3MissionPageTabView = Class("OpenServerV3MissionPageTabView", UIWidget);

local SELECT_STATE = CS.Torappu.UI.TwoStateFadeSwitcher.State.SELECT;
local UNSELECT_STATE = CS.Torappu.UI.TwoStateFadeSwitcher.State.UNSELECT;

function OpenServerV3MissionPageTabView:OnInitialize()
  if self._btnTab ~= nil then
    self:AddButtonClickListener(self._btnTab, self._EventOnClicked);
  end
end



function OpenServerV3MissionPageTabView:Init(pageState, onClicked)
  self.m_pageState = pageState;
  self.m_onClicked = onClicked;
end



function OpenServerV3MissionPageTabView:Render(selected, showNewSign)
  if self._toggleTab ~= nil then
    self._toggleTab.state = selected and SELECT_STATE or UNSELECT_STATE;
  end
  SetGameObjectActive(self._panelNew, showNewSign);
end


function OpenServerV3MissionPageTabView:BindTrackPoint(trackType)
  if trackType == nil or self._trackPoint == nil then
    return;
  end
  self.m_trackType = trackType;
  TrackPointModel.me:BindUI(trackType, self._trackPoint);
end

function OpenServerV3MissionPageTabView:OnDispose()
  if self.m_trackType ~= nil then
    TrackPointModel.me:UnbindUI(self.m_trackType);
    self.m_trackType = nil;
  end
end


function OpenServerV3MissionPageTabView:_EventOnClicked()
  if self.m_pageState == nil or self.m_onClicked == nil then
    return;
  end
  self.m_onClicked:Call(self.m_pageState);
end

return OpenServerV3MissionPageTabView;
