local luaUtils = CS.Torappu.Lua.Util;
local StagePageHotfixer = Class("StagePageHotfixer", HotfixBase)

local function BaseDimissSelf(self)
  if (not self:_PreCheckEngine()) then
    return
  end

  local engine = self:GetSupportStateEngine()
  if (engine:GetFrontState() == self) then
    engine:RemoveTop()
  end
end

local function Fix_DismissSelf(self)
  local isState = (self:GetType()) == typeof(CS.Torappu.UI.Stage.StagePreviewState)

  if (not isState) then
    BaseDimissSelf(self)
    return
  end

  local current = CS.UnityEngine.EventSystems.EventSystem.m_EventSystems
  CS.UnityEngine.EventSystems.EventSystem.m_EventSystems = CS.System.Collections.Generic.List(typeof(CS.UnityEngine.EventSystems.EventSystem))();
  local ok, errorInfo = xpcall(BaseDimissSelf, debug.traceback,self)
  if not ok then
        LogError("run Base DismissSelf error:" .. errorInfo)
  end
  CS.UnityEngine.EventSystems.EventSystem.m_EventSystems = current;
end

function StagePageHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.State)
  xlua.private_accessible(CS.UnityEngine.EventSystems.EventSystem)
  self:Fix_ex(CS.Torappu.UI.State, "DismissSelf", function(self)
    local ok, errorInfo = xpcall(Fix_DismissSelf, debug.traceback, self)
      if not ok then
        LogError("fix DismissSelf error:" .. errorInfo)
      end
    end)

end

function StagePageHotfixer:OnDispose()

end

return StagePageHotfixer