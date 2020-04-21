---@class BattleAbilityBehaviourBase
---@field protected m_uStub CS.LuaAbilityBehaviourStub
local BaseClass = Class("BattleAbilityBehaviourBase")

---@private call by BattleMgr
---@param uStub CS.LuaAbilityBehaviourStub
function BaseClass:Initialize(uStub)
  self.m_uStub = uStub
end

---@private call by BattleMgr
function BaseClass:Destroy()
end

---@protected
---@param blackboard CS.Blackboard
function BaseClass:ExportSetData(blackboard)
end

---@protected
function BaseClass:ExportOnCastStart()
end

---@protected
function BaseClass:ExportOnCastFinish()
end

---@protected
---@param ev CS.AbilityStandard.Event
function BaseClass:ExportOnEvent(ev)
end

---@protected
---@param target CS.Entity
function BaseClass:ExportOnCastOnTarget(target)
end

---@protected
function BaseClass:ExportOnStopAffect()
end

---@protected
---@param timing CS.AbilityStandard.SelectTargetTiming
function BaseClass:ExportUpdatePlaybackSpeed(timing)
  return false, 1.0
end

return BaseClass