




local UIHotfixer = Class("UIHotfixer", HotfixBase)

local function _FixSDKExitGameDialog(self, onDismiss)
  CS.Torappu.UI.Login.LoginViewController._ShowExitGameDialog(onDismiss)
end

function UIHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.Login.LoginViewController)
  self:Fix_ex(CS.Torappu.UI.Login.LoginViewController, "SDKExitGameDialog", function(self, onDismiss)
    local ok, ret = xpcall(_FixSDKExitGameDialog, debug.traceback, self, onDismiss)
    if not ok then
      LogError("[_FixSDKExitGameDialog] error : " .. ret)
    end
  end)
end

function UIHotfixer:OnDispose()
end

return UIHotfixer