local eutil = CS.Torappu.Lua.Util

local PCInputFontRegistryHotfixer = Class("PCInputFontRegistryHotfixer", HotfixBase)

local TorappuPCInputHelper = CS.Torappu.Common.TorappuPCInputHelper
local AbFontResourceRegistry = CS.Torappu.UI.AbFontResourceRegistry

local function _UnloadAll(self)
  
  AbFontResourceRegistry.InvalidateAllAfterForceUnload()

  self:UnloadAll()
end

local function _UnloadAll_Xpcall(self)
  local ok, errorInfo = xpcall(_UnloadAll, debug.traceback, self)
  if not ok then
    eutil.LogHotfixError("[PCInputFontRegistryHotfixer] fix UnloadAll: " .. tostring(errorInfo))
  end
end

function PCInputFontRegistryHotfixer:OnInit()
  if HOTFIX_ENABLE then
    if xlua and xlua.private_accessible then
      xlua.private_accessible(TorappuPCInputHelper)
    end
    self:Fix_ex(TorappuPCInputHelper, "UnloadAll", _UnloadAll_Xpcall)
  end
end

return PCInputFontRegistryHotfixer
