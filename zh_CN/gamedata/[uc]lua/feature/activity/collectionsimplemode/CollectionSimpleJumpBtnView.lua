local luaUtils = CS.Torappu.Lua.Util









local CollectionSimpleJumpBtnView = Class("CollectionSimpleJumpBtnView", UIWidget)

function CollectionSimpleJumpBtnView:OnInitialize()
  self:AddButtonClickListener(self._hotspot, self._EventOnJumpBtnClicked)
end



function CollectionSimpleJumpBtnView:Render(canJump, color)
  self._jumpToggle.selected = canJump
  if canJump then
    self._rootCanvasGroup.alpha = tonumber(self._canJumpAlpha)
  else
    self._rootCanvasGroup.alpha = tonumber(self._cannotJumpAlpha)
  end
  self._themeColorOutLight.color = color
end

function CollectionSimpleJumpBtnView:_EventOnJumpBtnClicked()
  if not self.onJumpBtnClicked then
    return
  end
  Event.Call(self.onJumpBtnClicked)
end

return CollectionSimpleJumpBtnView