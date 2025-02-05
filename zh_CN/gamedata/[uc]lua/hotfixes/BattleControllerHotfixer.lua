local BattleControllerHotfixer = Class("BattleControllerHotfixer", HotfixBase)

local function Fix_OnRallyPointLikeReborn(self, unit)
  for i = 0, self.m_globalBuffs.Count - 1 do
    if unit.id == "char_1040_blaze2" then
      self.m_globalBuffs[i]:TryRemoveBuff(unit)
    end
    self.m_globalBuffs[i]:TryAddBuff(unit)
  end
end

local function Fix_OnEnemyRebornAfterFakeDeath(self, unit)
  for i = 0, self.m_globalBuffs.Count - 1 do
    if unit.id == "char_1040_blaze2" then
      self.m_globalBuffs[i]:TryRemoveBuff(unit)
    end
    self.m_globalBuffs[i]:TryAddBuff(unit)
  end
end


function BattleControllerHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.BattleController)
  self:Fix_ex(CS.Torappu.Battle.BattleController, "OnRallyPointLikeReborn",
  function(self, unit)
    local ok, errorInfo = xpcall(Fix_OnRallyPointLikeReborn, debug.traceback, self, unit)
      if not ok then
        LogError("fix BattleController OnRallyPointLikeReborn error" .. errorInfo)
      end
  end)

  self:Fix_ex(CS.Torappu.Battle.BattleController, "OnEnemyRebornAfterFakeDeath",
  function(self, unit)
    local ok, errorInfo = xpcall(Fix_OnEnemyRebornAfterFakeDeath, debug.traceback, self, unit)
      if not ok then
        LogError("fix BattleController OnEnemyRebornAfterFakeDeath error" .. errorInfo)
      end
  end)
end

return BattleControllerHotfixer