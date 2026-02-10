local PCHotfixer = Class("PCHotfixer", HotfixBase)
local SDKHelper = CS.Torappu.SDK.SDKHelper
local SDKViewState = SDKHelper.SDKViewState

local ShopCashPurchaseUtil = CS.Torappu.ShopCashPurchaseUtil

local function _Fix_Pay(storeId, orderInfo)
  SDKHelper.instance:MaskSdkViewState(SDKViewState.SDK_VIEW_PAY)
  ShopCashPurchaseUtil._Pay(storeId, orderInfo)
end

local function _Fix_OnPurchaseSuc(response)
  SDKHelper.instance:UnmaskSdkViewState(SDKViewState.SDK_VIEW_PAY)
  ShopCashPurchaseUtil._OnPurchaseSuc(response)
end

local function _Fix_OnPurchaseFail()
  SDKHelper.instance:UnmaskSdkViewState(SDKViewState.SDK_VIEW_PAY)
  ShopCashPurchaseUtil._OnPurchaseFail()
end

local function _FixSDKHandleExtraInfo(self, extraData)
  self:HandleExtraInfo(extraData)
  if extraData == nil then
     return 
  end
  local code = extraData.code:GetHashCode()
  if code == 12 then
    SDKHelper.instance:UnmaskSdkViewState(SDKViewState.SDK_VIEW_INIT_LICENSE)
  end
end

function PCHotfixer:OnInit()
  if not CS.Torappu.DeviceInfoUtil:IsPCMode() or CS.U8.SDK.U8SDKInterface.Instance.isNativePlugin then
    return
  end
  
  xlua.private_accessible(ShopCashPurchaseUtil)

  self:Fix_ex(ShopCashPurchaseUtil, "_Pay", function(storeId, orderInfo)
    local ok, err = xpcall(_Fix_Pay, debug.traceback, storeId, orderInfo)
    if not ok then
      LogError("[PCHotfixer] _Pay fix: " .. tostring(err))
      ShopCashPurchaseUtil._Pay(storeId, orderInfo)
    end
  end)

  self:Fix_ex(ShopCashPurchaseUtil, "_OnPurchaseSuc", function(response)
    local ok, err = xpcall(_Fix_OnPurchaseSuc, debug.traceback, response)
    if not ok then
      LogError("[PCHotfixer] _OnPurchaseSuc fix: " .. tostring(err))
      ShopCashPurchaseUtil._OnPurchaseSuc(response)
    end
  end)

  self:Fix_ex(ShopCashPurchaseUtil, "_OnPurchaseFail", function()
    local ok, err = xpcall(_Fix_OnPurchaseFail, debug.traceback)
    if not ok then
      LogError("[PCHotfixer] _OnPurchaseFail fix: " .. tostring(err))
      ShopCashPurchaseUtil._OnPurchaseFail()
    end
  end)

  
  self:Fix_ex(CS.Torappu.SDK.SDKExtraInfoHandler, "HandleExtraInfo", function(self, extraData)
    local ok, err = xpcall(_FixSDKHandleExtraInfo, debug.traceback, self, extraData)
    if not ok then
      LogError("[PCHotfixer] HandleExtraInfo fix: " .. tostring(err))
    end
  end)
end

function PCHotfixer:OnDispose()
end

return PCHotfixer