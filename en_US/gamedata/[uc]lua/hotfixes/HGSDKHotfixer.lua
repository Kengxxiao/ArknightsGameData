




local HGSDKHotfixer = Class("HGSDKHotfixer", HotfixBase)

local function _CheckIfGuest(loginPage)
  local availToken, isGuest = loginPage:GetAvailableToken()
  return isGuest
end

local function _LoginPageDoAuth(self, token, onSuc, onFail)
  if _CheckIfGuest(self) then
    CS.Torappu.UI.UINotification.TextToast(StringRes.ERROR_GUEST_FUNC_DISABLE)
    return
  end
  self:DoAuth(token, onSuc, onFail)
end

local function _SetPageState(self, target)
  if target:GetHashCode() == 8 then
    if _CheckIfGuest(self) then
      return
    end
  end
  self.state = target
end

function HGSDKHotfixer:OnInit()
  self:Fix_ex(CS.HGSDK.UI.SDKLoginPage, "set_state", _SetPageState)
  self:Fix_ex(CS.HGSDK.UI.SDKLoginPage, "DoAuth", _LoginPageDoAuth)
end

function HGSDKHotfixer:OnDispose()
end

return HGSDKHotfixer