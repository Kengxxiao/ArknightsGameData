local luaUtil = CS.Torappu.Lua.Util















local ReturnV2MissionGroupItem = Class("ReturnV2MissionGroupItem", UIWidget)

function ReturnV2MissionGroupItem:OnInitialize()
  self:AddButtonClickListener(self._btnClick, ReturnV2MissionGroupItem._HandleClick)
  self.m_hubPath = CS.Torappu.ResourceUrls.GetReturnV2MissionGroupIconHubPath()
end



function ReturnV2MissionGroupItem:Render(groupViewModel, activeGroupId)
  if groupViewModel == nil or activeGroupId == nil or self.loadSpriteFunc == nil then
    return
  end
  local colorRes = CS.Torappu.ColorRes
  self.m_groupId = groupViewModel.groupId
  self._textGroupTitle.text = groupViewModel.tabTitle
  self._imgMissionGroupTab.sprite = self.loadSpriteFunc(self.m_hubPath, groupViewModel.iconId)

  luaUtil.SetActiveIfNecessary(self._objSelected, groupViewModel.groupId == activeGroupId)
  luaUtil.SetActiveIfNecessary(self._objHaveReward, groupViewModel.groupState == ReturnV2TaskGroupState.HAVE_REWARD)
  local isAllCompleted = groupViewModel.groupState == ReturnV2TaskGroupState.ALL_COMPLETED
  luaUtil.SetActiveIfNecessary(self._objAllMissionFinished, isAllCompleted)
  SetGameObjectActive(self._objTrackPoint, not groupViewModel:HasClickedMissionGroupTab())
  if isAllCompleted then
    self._textGroupTitle.color = colorRes.TweenHtmlStringToColor(self._htmlColorTextTabCompleted)
    self._imgMissionGroupTab.color = colorRes.TweenHtmlStringToColor(self._htmlColorImgTabCompleted)
  else
    self._textGroupTitle.color = colorRes.TweenHtmlStringToColor(self._htmlColorNormal)
    self._imgMissionGroupTab.color = colorRes.TweenHtmlStringToColor(self._htmlColorNormal)
  end
end

function ReturnV2MissionGroupItem:_HandleClick()
  if self.clickEvent and self.m_groupId ~= nil then
    self.clickEvent:Call(self.m_groupId)
  end
end

return ReturnV2MissionGroupItem