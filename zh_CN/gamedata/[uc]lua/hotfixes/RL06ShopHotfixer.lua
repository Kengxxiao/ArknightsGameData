local eutil = CS.Torappu.Lua.Util

local RL06ShopHotfixer = Class("RL06ShopHotfixer", HotfixBase)

local RoguelikeShopState = CS.Torappu.UI.Roguelike.RoguelikeShopState;
local RoguelikeShopLeaveBtnView = CS.Torappu.UI.Roguelike.RoguelikeShopLeaveBtnView;

local ILoadAsset = CS.Torappu.UI.ILoadAsset;
local RoguelikeShopControllerBase = CS.Torappu.UI.Roguelike.RoguelikeShopControllerBase;
local GameObject = CS.UnityEngine.GameObject;


local function _EnsureShopController(self, iLoadAsset, controllerPath)
  if self.m_cachedControllerPath == controllerPath then
    return;
  end
  local shopController = self.m_shopController;
  if shopController ~= nil then
    GameObject.DestroyImmediate(shopController.gameObject);
  end

  local genericWrap = xlua.get_generic_method(ILoadAsset, "LoadAsset");
  local loadAssetsWrap = genericWrap(RoguelikeShopControllerBase);

  local prefab = loadAssetsWrap(iLoadAsset, controllerPath);

  if prefab ~= nil then
    self.m_shopController = GameObject.Instantiate(prefab, self._shopControllerContainer);
  end
  self.m_cachedControllerPath = controllerPath;
end

local function _EnsureShopControllerFixer(self, iLoadAsset, controllerPath)
  local ok, errorInfo = xpcall(_EnsureShopController, debug.traceback, self, iLoadAsset, controllerPath);
  if not ok then
    eutil.LogHotfixError("[RL06ShopHotfixer] fix _EnsureShopController: " .. tostring(errorInfo));
    self:_EnsureShopController(iLoadAsset, controllerPath);
  end
end


local function _OnBtnConfirmLeaveShow(self)
  eutil.SetActiveIfNecessary(self._confirmLeavePanelGo, true);
  if self.m_leaveConfirmSwitchTween ~= nil then
    self.m_leaveConfirmSwitchTween.isShow = true;
  end
  if self.m_leaveSwitchTween ~= nil then
    self.m_leaveSwitchTween.isShow = false;
  end
end

local function _OnBtnConfirmLeaveShowFixer(self)
  local ok, errorInfo = xpcall(_OnBtnConfirmLeaveShow, debug.traceback, self);
  if not ok then
    eutil.LogHotfixError("[RL06ShopHotfixer] fix OnBtnConfirmLeaveShow: " .. tostring(errorInfo));
    self:OnBtnConfirmLeaveShow();
  end
end


local function _OnBtnConfirmLeaveHide(self)
  if self.m_leaveConfirmSwitchTween ~= nil then
    self.m_leaveConfirmSwitchTween.isShow = false;
  end
  if self.m_leaveSwitchTween ~= nil then
    self.m_leaveSwitchTween.isShow = true;
  end
end

local function _OnBtnConfirmLeaveHideFixer(self)
  local ok, errorInfo = xpcall(_OnBtnConfirmLeaveHide, debug.traceback, self);
  if not ok then
    eutil.LogHotfixError("[RL06ShopHotfixer] fix OnBtnConfirmLeaveHide: " .. tostring(errorInfo));
    self:OnBtnConfirmLeaveHide();
  end
end

function RL06ShopHotfixer:OnInit()
  if HOTFIX_ENABLE then
    if xlua and xlua.private_accessible then
      xlua.private_accessible(RoguelikeShopState)
      xlua.private_accessible(RoguelikeShopLeaveBtnView)
    end
    self:Fix_ex(RoguelikeShopState, "_EnsureShopController", _EnsureShopControllerFixer)
    self:Fix_ex(RoguelikeShopLeaveBtnView, "OnBtnConfirmLeaveShow", _OnBtnConfirmLeaveShowFixer)
    self:Fix_ex(RoguelikeShopLeaveBtnView, "OnBtnConfirmLeaveHide", _OnBtnConfirmLeaveHideFixer)
  end
end

return RL06ShopHotfixer
