
local eutil = CS.Torappu.Lua.Util


local MultiRangedAttackHotfixer = Class("MultiRangedAttackHotfixer", HotfixBase)

local function _OnCastEnd(self, reason)
  self:OnCastEnd(reason)
  if self.owner ~= nil and (string.find(self.owner.name, "char_2024_chyue")) then
    self.spellCnt = 0
  end
end

function MultiRangedAttackHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.AbilityStandard)
  xlua.private_accessible(CS.Torappu.Battle.Abilities.MultiRangedAttack)
	
  self:Fix_ex(CS.Torappu.Battle.Abilities.MultiRangedAttack, "OnCastEnd", function ( self, reason )
    local ok, errorInfo = xpcall(_OnCastEnd, debug.traceback, self, reason)
    if not ok then
      eutil.LogError("[MultiRangedAttackHotfixer] OnCastEnd fix" .. errorInfo)
    end
  end)
end

function MultiRangedAttackHotfixer:OnDispose()
end

return MultiRangedAttackHotfixer