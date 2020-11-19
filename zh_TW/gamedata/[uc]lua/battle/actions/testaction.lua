---@class TestAction:BattleActionBase
local TestAction = BattleMgr.me:DefineAction("TestAction", "test")

---@protected
function TestAction:OnExecute(blackboard, sourceType, snapshot)
  print('test lua action')
  return true
end