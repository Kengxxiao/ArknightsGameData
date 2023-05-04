local luaUtils = CS.Torappu.Lua.Util




local ReturnCheckinProgressDot = Class("ReturnCheckinProgressDot",UIWidget)


ReturnCheckinProgressDot.DOT_STATE = {
  NORMAL = 1,
  IMPORTANT = 2,
  CURRENT = 3
}
local COLLECTABLE_COLOR = {r = 1, g = 1, b = 1, a = 1}
local UNCOLLECTABLE_COLOR = {r = 0.30, g = 0.30, b = 0.30, a = 1}



function ReturnCheckinProgressDot:SetState(dotState,isCollectable)
  local activeImg = nil
  if dotState == self.DOT_STATE.NORMAL then
    activeImg = self._normalDot
  elseif dotState == self.DOT_STATE.IMPORTANT then
    activeImg = self._importantDot
  elseif dotState == self.DOT_STATE.CURRENT then
    activeImg = self._currentDot
  end
  SetGameObjectActive(self._normalDot.gameObject,dotState == self.DOT_STATE.NORMAL)
  SetGameObjectActive(self._importantDot.gameObject,dotState == self.DOT_STATE.IMPORTANT)
  SetGameObjectActive(self._currentDot.gameObject,dotState == self.DOT_STATE.CURRENT)
  if isCollectable then
    activeImg.color = COLLECTABLE_COLOR
  else
    activeImg.color = UNCOLLECTABLE_COLOR
  end
end

function  ReturnCheckinProgressDot:Render()
end

return ReturnCheckinProgressDot