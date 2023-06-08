local luaUtils = CS.Torappu.Lua.Util;






local SwitchOnlyTitleItemView = Class("SwitchOnlyTitleItemView", UIWidget)






function SwitchOnlyTitleItemView:Refresh(unlocked, rewardTitle)
  luaUtils.SetActiveIfNecessary(self._iconGot,unlocked);
  self._textTitle.text = rewardTitle;
  if unlocked then
    self._textTitle.color = CS.Torappu.ColorRes.TweenHtmlStringToColor(SwitchOnlyConst.COLOR_UNLOCKED);
    self._textConst.color = CS.Torappu.ColorRes.TweenHtmlStringToColor(SwitchOnlyConst.COLOR_UNLOCKED);
  else
    self._textTitle.color = CS.Torappu.ColorRes.TweenHtmlStringToColor(SwitchOnlyConst.COLOR_LOCKED);
    self._textConst.color = CS.Torappu.ColorRes.TweenHtmlStringToColor(SwitchOnlyConst.COLOR_LOCKED);
  end
end

return SwitchOnlyTitleItemView