
local BattleActionBase = Class("BattleActionBase")





function BattleActionBase:Execute(blackboard, sourceType, snapshot)
  return self:OnExecute(blackboard, sourceType, snapshot)
end





function BattleActionBase:OnExecute(blackboard, sourceType, snapshot)
  return false
end

return BattleActionBase