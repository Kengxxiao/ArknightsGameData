local Whitw2Skill3FunnelRangedAttackHotfixer = Class("Whitw2Skill3FunnelRangedAttackHotfixer", HotfixBase)

local function _OnDetached(self)
 self:OnDetached()
 self.m_cruiseProjectile:Clear()
 self.m_funnelProjectile:Clear()
end

local function _RuntimeApplyAttack(self, target)
  self.m_activeCnt = self.options.blackboard:GetIntOrDefault("cnt", 0, false) + 1
  if self.m_extraActiveCntStorage ~= nil then
    self.m_activeCnt = self.m_activeCnt + self.m_extraActiveCntStorage:GetExtraFunnelActiveCnt(self.name)
  end
  if self.m_alreadyAttackCnt > 0 then
    self:_DoPlayAttack(target)
  end
end
function Whitw2Skill3FunnelRangedAttackHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.Abilities.Whitw2Skill3FunnelRangedAttack)
  self:Fix_ex(CS.Torappu.Battle.Abilities.Whitw2Skill3FunnelRangedAttack, "OnDetached", function(self)
    local ok, result = xpcall(_OnDetached, debug.traceback, self)
    if not ok then
      LogError("[Whitw2Skill3FunnelRangedAttackHotfixer] fix" .. result)
    end
  end)
  self:Fix_ex(CS.Torappu.Battle.Abilities.Whitw2Skill3FunnelRangedAttack, "RuntimeApplyAttack", function(self, target)
    local ok, result = xpcall(_RuntimeApplyAttack, debug.traceback, self, target)
    if not ok then
      LogError("[Whitw2Skill3FunnelRangedAttackHotfixer] fix" .. result)
    end
  end)
end

function Whitw2Skill3FunnelRangedAttackHotfixer:OnDispose()
end

return Whitw2Skill3FunnelRangedAttackHotfixer