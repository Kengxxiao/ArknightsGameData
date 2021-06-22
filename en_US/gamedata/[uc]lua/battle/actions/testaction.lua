
local TestAction = BattleMgr.me:DefineAction("TestAction", "test")


function TestAction:OnExecute(blackboard, sourceType, snapshot)
  print('test lua action')
  return true
end