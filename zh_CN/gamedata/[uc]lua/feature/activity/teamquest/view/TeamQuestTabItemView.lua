local luaUtils = CS.Torappu.Lua.Util














local TeamQuestTabItemView = Class("TeamQuestTabItemView", UIWidget)

TeamQuestTabItemView.ALPHA_UNSELECT = 0.7

function TeamQuestTabItemView:OnInitialize()
  self:AddButtonClickListener(self._btnClick, self._EventOnBtnClick)
end

function TeamQuestTabItemView:_EventOnBtnClick()
  if self.m_tabType == nil or self.onItemClick == nil then
    return
  end
  CS.Torappu.EventTrack.EventLogTrace.instance:EventOnSwitchTabClicked(self.actId,self.m_tabType)
  self.onItemClick:Call(self.m_tabType)
end





function TeamQuestTabItemView:Render(tabModel, themeColorStr, isTabSelect, hasTrackPoint)
  self.m_tabType = tabModel.tabType

  luaUtils.SetActiveIfNecessary(self._unselectPartGO, not isTabSelect)
  luaUtils.SetActiveIfNecessary(self._selectPartGO, isTabSelect)
  luaUtils.SetActiveIfNecessary(self._goTrack, hasTrackPoint)

  local themeColor = luaUtils.FormatColorFromData(themeColorStr)
  luaUtils.SetColorWithoutAlpha(self._imgBgSelect, themeColor)

  local alphaGraphic = 1
  if not isTabSelect then
    alphaGraphic = self.ALPHA_UNSELECT
  end
  self._textName.text = tabModel.tabName
  luaUtils.SetGraphicAlpha(self._textName, alphaGraphic)

  local spriteTabIcon = nil
  if tabModel.tabType == TeamQuestTabType.MILESTONE then
    spriteTabIcon = self._spriteMilestone
  elseif tabModel.tabType == TeamQuestTabType.MISSION then
    spriteTabIcon = self._spriteMission
  elseif tabModel.tabType == TeamQuestTabType.TEAM then
    spriteTabIcon = self._spriteTeam
  end
  self._imgTabIcon.sprite = spriteTabIcon
  luaUtils.SetGraphicAlpha(self._imgTabIcon, alphaGraphic)
end

return TeamQuestTabItemView