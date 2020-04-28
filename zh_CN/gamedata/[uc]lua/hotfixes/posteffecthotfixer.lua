local eutil = CS.Torappu.Lua.Util

---@class PostEffectHotfixer:HotfixBase
local PostEffectHotfixer = Class("PostEffectHotfixer", HotfixBase)

local function _FixPostEffectDepth(self)
  local stateType = self:GetType()
  if (stateType == typeof(CS.Torappu.Building.UI.Float.BuildingFloatVaultState) or
      stateType == typeof(CS.Torappu.Building.UI.Float.BuildingFloatVisitState)) then
    local camController = CS.Torappu.Building.Vault.VCameraController.instance
    if camController ~= nil and camController.camera ~= nil then
      local camera = camController.camera
      local bloom = eutil.GetComponent(camera.gameObject, "MobileBloom")
      if bloom ~= nil then
        bloom.depthBuffer = 24
      end

      xlua.private_accessible(CS.Torappu.PostEffect.PostEffectLoader)
      local loader = eutil.GetComponent(camera.gameObject, "PostEffectLoader")
      if loader ~= nil then
        loader._useStencil = true
      end
    end
  end
end

function PostEffectHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Building.UI.Float.BuildingFloatState)
  self:Fix_ex(CS.Torappu.Building.UI.Float.BuildingFloatState, "OnEnter", function(self)
    local ok, error = xpcall(_FixPostEffectDepth, debug.traceback, self)
    if not ok then
      eutil.LogError("[PostEffectHotfixer] " .. error)
    end
  end)
end

function PostEffectHotfixer:OnDispose()
end

return PostEffectHotfixer