




local V045Hotfixer = Class("V045Hotfixer", HotfixBase)

local function _FixGenTweenerWithParam(self, color, fadetime, style)
  if style == "slider" then
    self._blocker.sprite = null
  end
  return self:_GenTweenerWithParam(color, fadetime, style)
end

function V045Hotfixer:OnInit()
  self:Fix_ex(CS.Torappu.AVG.AVGBlockerPanel, "_GenTweenerWithParam", function(self, color, fadetime, style)
    local ok, ret = xpcall(_FixGenTweenerWithParam, debug.traceback, self, color, fadetime, style)
    if not ok then
      LogError("[Hotfix] failed to _FixGenTweenerWithParam : ".. ret)
      return self:_GenTweenerWithParam(color, fadetime, style)
    else
      return ret
    end
  end)
end

return V045Hotfixer