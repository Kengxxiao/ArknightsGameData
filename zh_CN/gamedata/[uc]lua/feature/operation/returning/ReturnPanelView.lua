


















local ReturnPanelView = Class("ReturnPanelView", UIPanel);

function ReturnPanelView:OnInit()
  SetGameObjectActive(self._panelCheckinParent, false);
  SetGameObjectActive(self._panelMissionParent, false);
  SetGameObjectActive(self._panelNewsParent, false);
  SetGameObjectActive(self._panelSpecialOpenParent, false);
  SetGameObjectActive(self._panelPackageParent, false);
  SetGameObjectActive(self._objBtnNotice, false);
end


function ReturnPanelView:OnViewModelUpdate(data)
  if data == nil then
    return;
  end
  SetGameObjectActive(self._objBtnNotice, data.showNoticeBtn);

  local isSysFinish = data.sysClose;
  SetGameObjectActive(self._specialRemainGo, data.hasSpecialOpen);
  SetGameObjectActive(self._panelNewsBtn, true);
  SetGameObjectActive(self._panelCheckinBtn, not isSysFinish);
  SetGameObjectActive(self._panelMissionBtn, not isSysFinish);
  SetGameObjectActive(self._panelPackageBtn, data:GetGPTabShow());

  local state = data.tabState;
  local isCheckinOpen = state == ReturnTabState.STATE_TAB_CHECKIN;
  local isMissionOpen = state == ReturnTabState.STATE_TAB_MISSION;
  local isNewsOpen = state == ReturnTabState.STATE_TAB_NEWS;
  local isSpecialOpen = state == ReturnTabState.STATE_TAB_SPECIAL_OPEN;
  local isPackageOpen = state == ReturnTabState.STATE_TAB_PACKAGE;

  SetGameObjectActive(self._panelCheckinParent, isCheckinOpen and not isSysFinish);
  SetGameObjectActive(self._panelMissionParent, isMissionOpen and not isSysFinish);
  SetGameObjectActive(self._panelNewsParent, isNewsOpen);
  SetGameObjectActive(self._panelSpecialOpenParent, isSpecialOpen);
  SetGameObjectActive(self._panelPackageParent, isPackageOpen);

  TrackPointModel.me:UpdateNode(ReturnCheckInTrackPoint);
  TrackPointModel.me:UpdateNode(ReturnMissionTrackPoint);
  TrackPointModel.me:UpdateNode(ReturnNewsTrackPoint);
  TrackPointModel.me:UpdateNode(ReturnSpecialOpenTrackPoint);
  TrackPointModel.me:UpdateNode(ReturnPackageTrackPoint);

  local selectState = CS.Torappu.UI.TwoStateToggle.State.SELECT;
  local unselectState = CS.Torappu.UI.TwoStateToggle.State.UNSELECT;
  if isCheckinOpen then
    self._toggleCheckinBtn.state = selectState;
  else
    self._toggleCheckinBtn.state = unselectState;
  end
  if isMissionOpen then
    self._toggleMissionBtn.state = selectState;
  else
    self._toggleMissionBtn.state = unselectState;
  end
  if isNewsOpen then
    self._toggleNewsBtn.state = selectState;
  else
    self._toggleNewsBtn.state = unselectState;
  end
  if isSpecialOpen then
    self._toggleSpecialOpenBtn.state = selectState;
  else
    self._toggleSpecialOpenBtn.state = unselectState;
  end
  if isPackageOpen then
    self._togglePackageBtn.state = selectState;
  else
    self._togglePackageBtn.state = unselectState;
  end
end

return ReturnPanelView;