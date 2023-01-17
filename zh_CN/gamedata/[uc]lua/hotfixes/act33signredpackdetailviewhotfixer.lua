

local eutil = CS.Torappu.Lua.Util


local Act33SignRedpackDetailViewHotfixer = Class("Act33SignRedpackDetailViewHotfixer", HotfixBase)

local function _SendOpenRedpack_Fixed(self)
  local switchTw = self:_EnsureSwitchTween()
  if switchTw ~= nil and not switchTw.isShow then
    return
  else
    if not self.gameObject.activeSelf then
      return
    end
  end
  self:_SendOpenRedpack()
end

local function CloseView_Fixed(self)
  if self.m_consumed then
    return
  end
  self:CloseView()
end

function Act33SignRedpackDetailViewHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Activity.Act33Sign.Act33SignRedpackDetailView)

  self:Fix_ex(CS.Torappu.Activity.Act33Sign.Act33SignRedpackDetailView, "_SendOpenRedpack", function(self)
    local ok, errorInfo = xpcall(_SendOpenRedpack_Fixed, debug.traceback, self)
    if not ok then
      eutil.LogError("[Act33SignRedpackDetailViewHotfixer] fix" .. errorInfo)
    end
  end)
  self:Fix_ex(CS.Torappu.Activity.Act33Sign.Act33SignRedpackDetailView, "CloseView", function(self)
    local ok, errorInfo = xpcall(CloseView_Fixed, debug.traceback, self)
    if not ok then
      eutil.LogError("[Act33SignRedpackDetailViewHotfixer] fix" .. errorInfo)
    end
  end)
end

function Act33SignRedpackDetailViewHotfixer:OnDispose()
end

return Act33SignRedpackDetailViewHotfixer