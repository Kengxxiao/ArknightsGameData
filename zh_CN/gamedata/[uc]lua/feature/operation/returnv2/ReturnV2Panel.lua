local luaUtils = CS.Torappu.Lua.Util















local ReturnV2Panel = Class("ReturnV2Panel", UIPanel)

function ReturnV2Panel:OnInit()
  SetGameObjectActive(self._objCheckinParent, false)
  SetGameObjectActive(self._objTaskParent, false)
  SetGameObjectActive(self._objSpecialOpenParent, false)
end


function ReturnV2Panel:OnViewModelUpdate(data)
  if data == nil then
    return
  end

  local isSystemFinish = data.systemClose
  SetGameObjectActive(self._objCheckinTab, not isSystemFinish)
  SetGameObjectActive(self._objTaskTab, not isSystemFinish)
  SetGameObjectActive(self._objWelcomeTab, not isSystemFinish);

  local checkinStateOpen = data.tabState == ReturnV2StateTabStatus.STATE_TAB_CHECKIN
  local taskStateOpen = data.tabState == ReturnV2StateTabStatus.STATE_TAB_TASK
  local specialOpenStateOpen = data.tabState == ReturnV2StateTabStatus.STATE_TAB_ALL_OPEN
  SetGameObjectActive(self._objCheckinParent, checkinStateOpen)
  SetGameObjectActive(self._objTaskParent, taskStateOpen)
  SetGameObjectActive(self._objSpecialOpenParent, specialOpenStateOpen)

  if checkinStateOpen then
    self._twoStateCheckin.state = CS.Torappu.UI.TwoStateToggle.State.SELECT
  else
    self._twoStateCheckin.state = CS.Torappu.UI.TwoStateToggle.State.UNSELECT
  end
  if taskStateOpen then
    self._twoStateTask.state = CS.Torappu.UI.TwoStateToggle.State.SELECT
  else
    self._twoStateTask.state = CS.Torappu.UI.TwoStateToggle.State.UNSELECT
  end
  if specialOpenStateOpen then
    self._twoStateSpecialOpen.state = CS.Torappu.UI.TwoStateToggle.State.SELECT
  else
    self._twoStateSpecialOpen.state = CS.Torappu.UI.TwoStateToggle.State.UNSELECT
  end
end

return ReturnV2Panel;