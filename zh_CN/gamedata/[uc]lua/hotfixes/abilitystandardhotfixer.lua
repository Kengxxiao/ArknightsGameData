
local eutil = CS.Torappu.Lua.Util


local AbilityStandardHotfixer = Class("AbilityStandardHotfixer", HotfixBase)

local function _OnCastEnd(self, reason)
  self:OnCastEnd(reason)
  if (string.find(self.owner.name, "char_2024_chyue")) then
    self.spellCnt = 0
  end
end

function AbilityStandardHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.AbilityStandard)
	
  self:Fix_ex(CS.Torappu.Battle.AbilityStandard, "OnCastEnd", function ( self, reason )
    local ok, errorInfo = xpcall(_OnCastEnd, debug.traceback, self, reason)
    if not ok then
      eutil.LogError("[AbilityStandardHotfixer] OnCastEnd fix" .. errorInfo)
    end
  end)
end

function AbilityStandardHotfixer:OnDispose()
end

return AbilityStandardHotfixer