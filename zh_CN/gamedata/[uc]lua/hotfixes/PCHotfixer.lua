local PCHotfixer = Class("PCHotfixer", HotfixBase)

local SDKHelper = CS.Torappu.SDK.SDKHelper
local CallbackCode = CS.Hypergryph.SDK.CallbackCode

local function HGSDKV2LoginDialogOnRenderLua(self, options)
    self:OnRender(options)
    if self._btnScanLogin then
        self._btnScanLogin:SetActive(false)
    end
end




local function HGSDKV2LoginDialogEventOnLoginLua(self)
    SDKHelper.instance:MaskSdkViewState(SDKHelper.SDKViewState.SDK_VIEW_LOGIN)
    self:EventOnLogin()
end


local function HGSDKV2LoginDialogEventOnSwitchAccountLua(self)
    SDKHelper.instance:MaskSdkViewState(SDKHelper.SDKViewState.SDK_VIEW_LOGIN)
    self:EventOnSwitchAccount()
end
local function OnExtraInfoLua(self, code, msg)
    self:OnExtraInfo(code, msg)
    if code == CallbackCode.WEBVIEW_OPEN then
        SDKHelper.instance:MaskSdkViewState(SDKHelper.SDKViewState.SDK_VIEW_WEBVIEW)
    elseif code == CallbackCode.MINIWEB_OPEN then
        SDKHelper.instance:MaskSdkViewState(SDKHelper.SDKViewState.SDK_VIEW_MINI_WEBVIEW)
    elseif code == CallbackCode.WEBVIEW_CLOSE then
        SDKHelper.instance:UnmaskSdkViewState(SDKHelper.SDKViewState.SDK_VIEW_WEBVIEW)
        SDKHelper.instance:UnmaskSdkViewState(SDKHelper.SDKViewState.SDK_VIEW_MINI_WEBVIEW)
    elseif code == CallbackCode.GAME_URL_SCHEME then
        SDKHelper.instance:UnmaskSdkViewState(SDKHelper.SDKViewState.SDK_VIEW_WEBVIEW)
        SDKHelper.instance:UnmaskSdkViewState(SDKHelper.SDKViewState.SDK_VIEW_MINI_WEBVIEW)
    end
end

local function _StartSceneLua(self, sceneName, options)
    if options then
        self:_StartScene(sceneName, options)
    else
        self:_StartScene(sceneName)
    end
    SDKHelper.instance:ClearSdkViewState()
end
local function InvokeLicenseLua(self, callback)
    self:InvokeLicense(callback)
    SDKHelper.instance:MaskSdkViewState(SDKHelper.SDKViewState.SDK_VIEW_INIT_LICENSE)
end
local function EventOnLicenseRetMessageLua(self, licenseRet)
    self:_EventOnLicenseRetMessage(licenseRet)   
    SDKHelper.instance:UnmaskSdkViewState(SDKHelper.SDKViewState.SDK_VIEW_INIT_LICENSE)
end



local function SDKLoginImplLua(self, nextStep)
    self:_SDKLoginImpl(nextStep)
    SDKHelper.instance:UnmaskSdkViewState(SDKHelper.SDKViewState.SDK_VIEW_LOGIN)
end

local function OnProcessLua(self)
    local list = self.m_wheelHandlerList
    if list == nil then
        return
    end
    for i = list.Count - 1, 0, -1 do
        local handler = list[i]
        if handler ~= nil then
            list:RemoveAt(i)
        end
    end
end

function PCHotfixer:OnInit()
    if CS.Torappu.DeviceInfoUtil:IsPCMode() then
        xlua.private_accessible(CS.HGSDK.V2.HGSDKV2LoginDialog)
        xlua.private_accessible(CS.Torappu.UI.UIWebWindow)
        xlua.private_accessible(CS.Torappu.GameFlowController)
        xlua.private_accessible(CS.Torappu.UI.Login.LoginNativeLicense)
        xlua.private_accessible(CS.Torappu.UI.Login.LoginViewController)
        self:Fix_ex(CS.HGSDK.V2.HGSDKV2LoginDialog, "OnRender", function(self, options)
            local ok, errorInfo = xpcall(HGSDKV2LoginDialogOnRenderLua, debug.traceback, self, options)
            if not ok then
                LogError("[PCHotfixer] fix" .. errorInfo)
            end
        end)
        self:Fix_ex(CS.HGSDK.V2.HGSDKV2LoginDialog, "EventOnLogin", function(self)
            local ok, errorInfo = xpcall(HGSDKV2LoginDialogEventOnLoginLua, debug.traceback, self)
            if not ok then
                LogError("[PCHotfixer] fix" .. errorInfo)
            end
        end)
        self:Fix_ex(CS.HGSDK.V2.HGSDKV2LoginDialog, "EventOnSwitchAccount", function(self)
            local ok, errorInfo = xpcall(HGSDKV2LoginDialogEventOnSwitchAccountLua, debug.traceback, self)
            if not ok then
                LogError("[PCHotfixer] fix" .. errorInfo)
            end
        end)
        self:Fix_ex("Torappu.UI.UIWebWindow+HGWebAdapter", "OnExtraInfo", function(self, code, msg)
            local ok, errorInfo = xpcall(OnExtraInfoLua, debug.traceback, self, code, msg)
            if not ok then
                LogError("[PCHotfixer] fix" .. errorInfo)
            end
        end)
        self:Fix_ex(CS.Torappu.GameFlowController, "_StartScene", function(self, sceneName, options)
            local ok, errorInfo = xpcall(_StartSceneLua, debug.traceback, self, sceneName, options)
            if not ok then
                LogError("[PCHotfixer] fix" .. errorInfo)
            end
        end)
        self:Fix_ex(CS.Torappu.UI.Login.LoginNativeLicense, "InvokeLicense", function(self, callback)
            local ok, errorInfo = xpcall(InvokeLicenseLua, debug.traceback, self, callback)
            if not ok then
                LogError("[PCHotfixer] fix" .. errorInfo)
            end
        end)
        self:Fix_ex(CS.Torappu.UI.Login.LoginNativeLicense, "_EventOnLicenseRetMessage", function(self, licenseRet)
            local ok, errorInfo = xpcall(EventOnLicenseRetMessageLua, debug.traceback, self, licenseRet)
            if not ok then
                LogError("[PCHotfixer] fix" .. errorInfo)
            end
        end)
        self:Fix_ex(CS.Torappu.UI.Login.LoginViewController, "_SDKLoginImpl", function(self, nextStep)
            local ok, errorInfo = xpcall(SDKLoginImplLua, debug.traceback, self, nextStep)
            if not ok then
                LogError("[PCHotfixer] fix" .. errorInfo)
            end
        end)
    end 
    if not CS.Torappu.DeviceInfoUtil:IsPCMode() then
        self:Fix_ex(CS.Torappu.Common.TorappuPCInputHelper , "OnProcess", function(self)
            local ok, ret = xpcall(OnProcessLua, debug.traceback, self)
            if not ok then
                LogError("[PCHotfixer] fix" .. ret)
            end
        end)
    end
end

function PCHotfixer:OnDispose()
end

return PCHotfixer