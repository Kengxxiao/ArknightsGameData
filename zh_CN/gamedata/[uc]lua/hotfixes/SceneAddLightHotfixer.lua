
local SceneAddLightHotfixer = Class("SceneAddLightHotfixer", HotfixBase)

local function _FixInit(self)
  local levelId = CS.Torappu.Battle.BattleInOut.instance.input.stageInfo.levelId
  if levelId ~= nil and string.find(levelId, "act43side") then
    self.m_inited = false
    return
  end
  self:_Init()
end

function SceneAddLightHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Rendering.SceneAddLight)
  self:Fix_ex(CS.Torappu.Rendering.SceneAddLight, "_Init", function(self)
    local ok, error = xpcall(_FixInit, debug.traceback, self)
    if not ok then
      LogError("[SceneAddLight._Init] error : " .. error)
      self:_Init()
    end
  end)
end

function SceneAddLightHotfixer:OnDispose()
end

return SceneAddLightHotfixer