local luaUtils = CS.Torappu.Lua.Util











local TeamQuestGetAllBtnView = Class("TeamQuestGetAllBtnView", UIWidget)




function TeamQuestGetAllBtnView:Render(hasRewardAvail, themeColor, onBtnAllClick)
  self.m_onBtnAllClick = onBtnAllClick
  self:_InitIfNot()
  
  SetGameObjectActive(self._imgGlow.gameObject, hasRewardAvail)
  self._btnGetAll.enabled = hasRewardAvail

  local colorBtnBg
  local colorCaption
  if hasRewardAvail then
    colorBtnBg = luaUtils.FormatColorFromData(themeColor)
    colorCaption = luaUtils.FormatColorFromData(self._colorCaptionActive)
  else
    colorBtnBg = luaUtils.FormatColorFromData(self._colorBtnInactive)
    colorCaption = luaUtils.FormatColorFromData(self._colorCaptionInactive)
  end
  self._imgBg.color = colorBtnBg
  self._imgGlow.color = colorBtnBg
  self._textCaption.color = colorCaption
end

function TeamQuestGetAllBtnView:_InitIfNot()
  if self.m_hasInited then
    return
  end
  self.m_hasInited = true

  self:AddButtonClickListener(self._btnGetAll, self.EventOnBtnClick)
end

function TeamQuestGetAllBtnView:EventOnBtnClick()
  if self.m_onBtnAllClick == nil then
    return
  end

  self.m_onBtnAllClick:Call()
end

return TeamQuestGetAllBtnView