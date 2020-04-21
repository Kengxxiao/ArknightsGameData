---@class BattleActionBase
local BattleActionBase = Class("BattleActionBase")

---@private
---@param blackboard CS.Blackboard
---@param sourceType CS.ActionNode.SourceType
---@param snapshot CS.Context.Snapshot
function BattleActionBase:Execute(blackboard, sourceType, snapshot)
  return self:OnExecute(blackboard, sourceType, snapshot)
end

---@protected
---@param blackboard CS.Blackboard
---@param sourceType CS.ActionNode.SourceType
---@param snapshot CS.Context.Snapshot
function BattleActionBase:OnExecute(blackboard, sourceType, snapshot)
  return false
end

return BattleActionBase