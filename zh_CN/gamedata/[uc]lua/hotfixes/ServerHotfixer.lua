local Server = CS.Torappu.SocketNetwork.ServerBase.Server
local ConnectionState = CS.Torappu.SocketNetwork.Connections.ConnectionState
local eutil = CS.Torappu.Lua.Util


local ServerHotfixer = Class("ServerHotfixer", HotfixBase)

local function _OnClosedByRemote(self, state)
  if self.m_rrpProcessor ~= nil then
    self.m_rrpProcessor:OnDisconnect()
  end
  self:OnNetStateChanged(state)
end

function ServerHotfixer:OnInit()
  xlua.private_accessible(Server)
  self:Fix_ex(Server, "_NetStateChanged", function(self, state)
    if state ~= ConnectionState.CLOSED_BY_REMOTE then
      self:_NetStateChanged(state)
      return
    end
    local ok, err = xpcall(_OnClosedByRemote, debug.traceback, self, state)
    if not ok then
      eutil.LogHotfixError("[ServerHotfixer] _NetStateChanged: " .. err)
      self:_NetStateChanged(state)
    end
  end)
end

function ServerHotfixer:OnDispose()
end

return ServerHotfixer
