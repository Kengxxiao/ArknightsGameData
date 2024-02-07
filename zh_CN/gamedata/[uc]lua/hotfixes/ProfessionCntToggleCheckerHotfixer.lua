




local ProfessionCntToggleCheckerHotfixer = Class("ProfessionCntToggleCheckerHotfixer", HotfixBase)

local function _Fix_CheckMaxSameProfessionCount(self)
  self.m_professionCount:Clear();
  local units = CS.Torappu.Battle.BattleController.instance.unitManager.characters
  for  i = 0, units.count - 1  do
    local target = units[i]
    if target ~= nil and target.alive and target.playerSide == self.owner.playerSide and self:_CheckProfession(target) then
      self.m_professionCount[target.data.profession] = self.m_professionCount[target.data.profession] + 1
    end
  end
  local count = 0
  for  i = 0, self.m_professionCount.Count - 1  do
    count = math.max(count, self.m_professionCount:Get(i).Value)
  end
  return count
end

local function _Fix_CheckMaxDifferentProfessionCount(self)
  self.m_professionCount:Clear();
  local units = CS.Torappu.Battle.BattleController.instance.unitManager.characters
  for  i = 0, units.count - 1  do
    local target = units[i]
    if target ~= nil and target.alive and target.playerSide == self.owner.playerSide and self:_CheckProfession(target) then
      self.m_professionCount[target.data.profession] = self.m_professionCount[target.data.profession] + 1
    end
  end
  return self.m_professionCount.Count
end

function ProfessionCntToggleCheckerHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.Abilities.ProfessionCntToggleChecker)
  self:Fix_ex(CS.Torappu.Battle.Abilities.ProfessionCntToggleChecker, "_CheckMaxSameProfessionCount", function(self)
    local ok, ret = xpcall(_Fix_CheckMaxSameProfessionCount, debug.traceback, self)
    if not ok then
      LogError("[Hotfix] failed to _Fix_CheckMaxSameProfessionCount : ".. ret)
      return self:_CheckMaxSameProfessionCount()
    else
      return ret
    end
  end)

  self:Fix_ex(CS.Torappu.Battle.Abilities.ProfessionCntToggleChecker, "_CheckMaxDifferentProfessionCount", function(self)
    local ok, ret = xpcall(_Fix_CheckMaxDifferentProfessionCount, debug.traceback, self)
    if not ok then
      LogError("[Hotfix] failed to _Fix_CheckMaxDifferentProfessionCount : ".. ret)
      return self:_CheckMaxDifferentProfessionCount()
    else
      return ret
    end
  end)
end

return ProfessionCntToggleCheckerHotfixer