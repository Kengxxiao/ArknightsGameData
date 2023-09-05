local luaUtils = CS.Torappu.Lua.Util;








local SwitchOnlyTitleItemView = Class("SwitchOnlyTitleItemView", UIWidget)




function SwitchOnlyTitleItemView:Refresh(unlocked, rewardTitle)
  luaUtils.SetActiveIfNecessary(self._iconGot,unlocked)
  self._textTitle.text = rewardTitle
  local textColor = nil

  if unlocked then
    textColor = self._unlockedColor
    if textColor == nil then
      textColor = SwitchOnlyConst.COLOR_UNLOCKED
    end
  else
    textColor = self._lockedColor
    if textColor == nil then
      textColor = SwitchOnlyConst.COLOR_LOCKED
    end
  end

  self._textTitle.color = CS.Torappu.ColorRes.TweenHtmlStringToColor(textColor)
  self._textConst.color = CS.Torappu.ColorRes.TweenHtmlStringToColor(textColor)
end

return SwitchOnlyTitleItemView