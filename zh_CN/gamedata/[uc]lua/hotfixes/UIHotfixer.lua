




local UIHotfixer = Class("UIHotfixer", HotfixBase)

local function _FixSDKExitGameDialog(self, onDismiss)
  CS.Torappu.UI.Login.LoginViewController._ShowExitGameDialog(onDismiss)
end

local function _FixHomeOnCreate(self, bundle) 
  self:OnCreate(bundle)
  self:_InitHomeMusic()
end

function UIHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.Login.LoginViewController)
  self:Fix_ex(CS.Torappu.UI.Login.LoginViewController, "SDKExitGameDialog", function(self, onDismiss)
    local ok, ret = xpcall(_FixSDKExitGameDialog, debug.traceback, self, onDismiss)
    if not ok then
      LogError("[_FixSDKExitGameDialog] error : " .. ret)
    end
  end)

  xlua.private_accessible(CS.Torappu.UI.Home.HomePage)
  self:Fix_ex(CS.Torappu.UI.Home.HomePage, "OnCreate", function(self, bundle) 
    local ok, ret = xpcall(_FixHomeOnCreate, debug.traceback, self, bundle)
    if not ok then
      LogError("[_FixHomeOnCreate] error : " .. ret)
    end
  end)

  local RL03TotemDataUtil = CS.Torappu.UI.Roguelike.RL03.RL03TotemDataUtil
  xlua.private_accessible(RL03TotemDataUtil)
  self:Fix_ex(RL03TotemDataUtil, "_FindSelectableNodeWithOnlyForVert", function(curZone, curDepth, isInPortal, viewModel, nodeSet)
    local ok, ret = xpcall(function(_1, _2, _3, _4, _5)
      return RL03TotemDataUtil._FindSelectableNodeWithOnlyForVert(_1, _2, _3, _4, _5)
    end, debug.traceback, curZone, curDepth, isInPortal, viewModel, nodeSet)
    if not ok then
      return nodeSet
    end
    return ret
  end)
  self:Fix_ex(RL03TotemDataUtil, "_FindSelectableNodesWithExpandLength", function(curZone, curDepth, isInPortal, viewModel, nodeSet)
    local ok, ret = xpcall(function(_1, _2, _3, _4, _5)
      return RL03TotemDataUtil._FindSelectableNodesWithExpandLength(_1, _2, _3, _4, _5)
    end, debug.traceback, curZone, curDepth, isInPortal, viewModel, nodeSet)
    if not ok then
      return nodeSet
    end
    return ret
  end)
end

function UIHotfixer:OnDispose()
end

return UIHotfixer