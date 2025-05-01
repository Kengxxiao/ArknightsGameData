
local AbilityStandardHotfixer = Class("AbilityStandardHotfixer", HotfixBase)

local function _Fix_OnAttackFinished(self, arg)
  if arg == nil then
    self:OnAttackFinished(self)
  else
    self:OnAttackFinished(arg)
  end
end

function AbilityStandardHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.AbilityStandard)

  self:Fix_ex(CS.Torappu.Battle.AbilityStandard, "OnAttackFinished",
  function(self, arg)
    local ok, errorInfo = xpcall(_Fix_OnAttackFinished, debug.traceback, self, arg)
      if not ok then
        LogError("fix AbilityStandard OnAttackFinished error" .. errorInfo)
      end
  end)
end

return AbilityStandardHotfixer