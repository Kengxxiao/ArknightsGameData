
local SandboxV3BasementDetailStateHotfixer = Class("SandboxV3BasementDetailStateHotfixer", HotfixBase)

local function _DeleteDulpuliteGameController()
  local Object = CS.UnityEngine.Object
  local genericFunc = xlua.get_generic_method(Object, "FindObjectOfType")
  local FindObjectOfType = genericFunc(CS.Torappu.Battle.BattleController)
  local result = FindObjectOfType()
  local eutil = CS.Torappu.Lua.Util
  if not eutil.IsDestroyed(result) then
    Object.Destroy(result.gameObject)
  end
end

local function _HandleEnterBaseHotfix(self)
  local ok, err = xpcall(function()
    _DeleteDulpuliteGameController()
  end, debug.traceback)
  if not ok then
    LogError("[SandboxV3BasementDetailStateHotfixer] _HandleEnterBase error: " .. err)
  end
  self:_HandleEnterBase()
end

function SandboxV3BasementDetailStateHotfixer:OnInit()
  if HOTFIX_ENABLE then
    if xlua and xlua.private_accessible then
      xlua.private_accessible(CS.Torappu.UI.SandboxPerm.SandboxV3.SandboxV3BasementDetailState)
    end
    self:Fix_ex(CS.Torappu.UI.SandboxPerm.SandboxV3.SandboxV3BasementDetailState, "_HandleEnterBase", _HandleEnterBaseHotfix)
  end
end

return SandboxV3BasementDetailStateHotfixer
