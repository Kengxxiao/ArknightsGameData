local luaUtils = CS.Torappu.Lua.Util;















GridGachaLineView = Class("GridGachaLineView", UIWidget)

local function _CreateSwitch(canvasGroup, fadetime)
  fadetime = fadetime or 0.08;
  local ret = CS.Torappu.UI.FadeSwitchTween(canvasGroup, fadetime);
  ret:Reset(false);
  return ret;
end

function GridGachaLineView:OnInit()
  self.gachaEndSwitch = _CreateSwitch(self._gachaEnd);
  self.gachaRandomSwitch = _CreateSwitch(self._gachaRandom);
  self.triangleSwitch = _CreateSwitch(self._canvasTri);
  self.lineEndSwitch = _CreateSwitch(self._canvasLineEnd);

  self.gachaRandomSwitch.isShow = false;
end

function GridGachaLineView:Render(flag)
  self.gachaEndSwitch.isShow = flag;
end

return GridGachaLineView;