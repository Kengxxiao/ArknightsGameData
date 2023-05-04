

local BaseClass = Class("BattleAbilityBehaviourBase")



function BaseClass:Initialize(uStub)
  self.m_uStub = uStub
end


function BaseClass:Destroy()
end



function BaseClass:ExportSetData(blackboard)
end


function BaseClass:ExportOnCastStart()
end


function BaseClass:ExportOnCastFinish()
end



function BaseClass:ExportOnEvent(ev)
end



function BaseClass:ExportOnCastOnTarget(target)
end


function BaseClass:ExportOnStopAffect()
end



function BaseClass:ExportUpdatePlaybackSpeed(timing)
  return false, 1.0
end

return BaseClass