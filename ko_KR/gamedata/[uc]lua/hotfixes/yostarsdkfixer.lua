local xutil = require('xlua.util')
local StringRes = require('HotFixes/LuaStringRes')
local eutil = CS.Torappu.Lua.Util

---@class YostarSDKFixer:HotfixBase
local YostarSDKFixer = Class("YostarSDKFixer",HotfixBase)

function YostarSDKFixer:OnInit()
  xutil.hotfix_ex(CS.YostarSDK.StringRes, "get_YOSTAR_CONFIRM_SWITCH_GUEST_TIP",
  function()
    return StringRes.YOSTAR_CONFIRM_SWITCH_GUEST_TIP
  end)
end

function YostarSDKFixer:OnDispose()
  xlua.hotfix(CS.YostarSDK.StringRes, "get_YOSTAR_CONFIRM_SWITCH_GUEST_TIP", nil)
end

return YostarSDKFixer