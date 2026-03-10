local AdvancedSelectorWithEnemyOptionsHotfixer = Class("AdvancedSelectorWithEnemyOptionsHotfixer", HotfixBase)

function AdvancedSelectorWithEnemyOptionsHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.AdvancedSelectorWithEnemyOptions)

  self:Fix_ex(CS.Torappu.Battle.AdvancedSelectorWithEnemyOptions, "SetData", function(self, blackboard)
    self:SetData(blackboard)
    if self.m_enemyKey == nil then
      self.m_enemyKey = ""
    end
  end)
end

function AdvancedSelectorWithEnemyOptionsHotfixer:OnDispose()
end

return AdvancedSelectorWithEnemyOptionsHotfixer
