
local ThisBehaviour = BattleMgr.me:DefineAbilityBehaviour("TestAbilityBehaviour", 'test')


function ThisBehaviour:ExportOnCastStart()
  print('test lua ability behaviour: cast start')
end


function ThisBehaviour:ExportOnCastFinish()
  print('test lua ability behaviour: cast end')
end

return ThisBehaviour