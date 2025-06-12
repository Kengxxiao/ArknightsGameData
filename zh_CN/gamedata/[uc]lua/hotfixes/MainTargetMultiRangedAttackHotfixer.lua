
local MainTargetMultiRangedAttackHotfixer = Class("MainTargetMultiRangedAttackHotfixer", HotfixBase)

function MainTargetMultiRangedAttackHotfixer:OnInit()
  xlua.private_accessible(typeof(CS.Torappu.Battle.Abilities.MainTargetMultiRangedAttack))
  self:Fix(typeof(CS.Torappu.Battle.Abilities.MainTargetMultiRangedAttack), "UpdateTargets", function(this, updateInputPos)
    local baseObj = base(this)
    local result = baseObj:UpdateTargets(updateInputPos)
    if this.spellCnt > 0 then
      if this.m_castTargets.Count > 1 then
        this.m_castTargets:RemoveRange(1, this.m_castTargets.Count - 1)
      end
    else
      this.m_remainTimes = this.additionalTimes + 1;
      if this.m_remainTimes < this.m_castTargets.Count then
        this.m_castTargets:RemoveRange(this.m_remainTimes - 1, this.m_castTargets.Count - this.m_remainTimes)
      end
      this.m_remainTimes = this.m_remainTimes - this.m_castTargets.Count
    end
    return result
  end)
end

return MainTargetMultiRangedAttackHotfixer