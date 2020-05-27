---@class TestAbilityBehaviour:BaseAbilityBehaviourBase
local ThisBehaviour = BattleMgr.me:DefineAbilityBehaviour("TestAbilityBehaviour", 'test')

---Don't invoke in lua, exported to Unity
function ThisBehaviour:ExportOnCastStart()
  print('test lua ability behaviour: cast start')
end

---Don't invoke in lua, exported to Unity
function ThisBehaviour:ExportOnCastFinish()
  print('test lua ability behaviour: cast end')
end

return ThisBehaviour