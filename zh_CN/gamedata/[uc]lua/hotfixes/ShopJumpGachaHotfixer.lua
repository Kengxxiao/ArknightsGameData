
local ShopJumpGachaHotfixer = Class("ShopJumpGachaHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

local function OnOpenGachaPageFix(self)
  if CS.Torappu.GameFlowController.currentScene == CS.Torappu.SceneConsts.HOME then
    self:OnOpenGachaPage()
  else
    CS.Torappu.UI.UINotification.TextToast(StringRes.FES_CLASSIC_SHOP_JUMP_TO_GACHA_TOAST)
  end
end

function ShopJumpGachaHotfixer:OnInit()
  self:Fix_ex(CS.Torappu.UI.Shop.QCNormalGoodItem, "OnOpenGachaPage", function(self)
    local ok, errorInfo = xpcall(OnOpenGachaPageFix, debug.traceback, self)
    if not ok then
      eutil.LogError("[ShopJumpGachaHotfixer] fix" .. errorInfo)
    end
  end)
end

function ShopJumpGachaHotfixer:OnDispose()
end

return ShopJumpGachaHotfixer