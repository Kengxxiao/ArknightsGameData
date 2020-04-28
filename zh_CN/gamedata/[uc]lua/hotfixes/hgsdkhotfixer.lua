local eutil = CS.Torappu.Lua.Util

---@class HGSDKHotfixer:HotfixBase
local HGSDKHotfixer = Class("HGSDKHotfixer", HotfixBase)

local function _FixDoQuit(self)
  CS.UnityEngine.Application.Quit()
end

function HGSDKHotfixer:OnInit()
  xlua.private_accessible(CS.HGSDK.HGSDK)
  xlua.private_accessible(CS.HGSDK.HGSDK.PingManager)
  self:Fix_ex(CS.HGSDK.HGSDK.PingManager, "_DoQuit", function(self)
    local ok, error = xpcall(_FixDoQuit, debug.traceback, self)
    if not ok then
      eutil.LogError("[HGSDKFix] " .. error)
    end
  end)
end

function HGSDKHotfixer:OnDispose()
end

return HGSDKHotfixer