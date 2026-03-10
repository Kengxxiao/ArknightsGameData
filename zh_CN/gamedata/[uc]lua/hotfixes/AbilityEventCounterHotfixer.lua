local AbilityEventCounterHotfixer = Class("AbilityEventCounterHotfixer", HotfixBase)

local AbilityEventCounter = CS.Torappu.Battle.Abilities.AbilityEventCounter
local AbilityEvent = CS.Torappu.Battle.AbilityStandard.Event
local AbilityBehaviour = CS.Torappu.Battle.AbilityStandard.Behaviour
local BattleController = CS.Torappu.Battle.BattleController
local DefaultEffects = CS.Torappu.Battle.DefaultEffects
local AudioSignals = CS.Torappu.Battle.AudioSignals
local Vector3 = CS.UnityEngine.Vector3
local TARGET_ABILITY_TYPE_NAME = "Torappu.Battle.Abilities.WangVisualStoneMarkAbility"
local FREE_BUILD_BB_KEY = "isFreely"

local g_hotfixState = rawget(_G, "__AbilityEventCounterHotfixState")
if g_hotfixState == nil then
  g_hotfixState = {
    muteNextSpareShotMap = setmetatable({}, { __mode = "k" })
  }
  _G.__AbilityEventCounterHotfixState = g_hotfixState
end
local s_localState = {
  castStartNotCountNextMap = setmetatable({}, { __mode = "k" }),
  isTargetAbilityMap = setmetatable({}, { __mode = "k" })
}

local function _SetNotEmitSpareShotAudioNext(counter, notEmit)
  if counter == nil then
    return
  end
  if notEmit == nil then
    notEmit = true
  end
  if notEmit then
    g_hotfixState.muteNextSpareShotMap[counter] = true
  else
    g_hotfixState.muteNextSpareShotMap[counter] = nil
  end
end

local function _IsNotEmitSpareShotAudioNext(counter)
  return counter ~= nil and g_hotfixState.muteNextSpareShotMap[counter] == true
end

local function _ClearNotEmitSpareShotAudioNext(counter)
  if counter ~= nil then
    g_hotfixState.muteNextSpareShotMap[counter] = nil
  end
end

local function _ClearCastStartNotCountNext(counter)
  if counter ~= nil then
    s_localState.castStartNotCountNextMap[counter] = false
  end
end

local function _CacheIsTargetAbility(counter)
  if counter == nil or counter.ability == nil then
    s_localState.isTargetAbilityMap[counter] = false
    return false
  end
  local abilityType = counter.ability:GetType()
  local isTarget = abilityType ~= nil and abilityType.FullName == TARGET_ABILITY_TYPE_NAME
  s_localState.isTargetAbilityMap[counter] = isTarget
  return isTarget
end

local function _IsTargetAbility(counter)
  if counter == nil then
    return false
  end
  return s_localState.isTargetAbilityMap[counter] == true
end

local function _RecordCastStartNotCountNext(counter)
  if counter ~= nil and _IsTargetAbility(counter) then
    s_localState.castStartNotCountNextMap[counter] = counter.m_notCountNext == true
  end
end

local function _GetRecordedNotCountNext(counter)
  if counter == nil then
    return false
  end
  return s_localState.castStartNotCountNextMap[counter] == true
end

local function _TryGetIsFreelyFromAbilityBlackboard(counter)
  if counter == nil or counter.ability == nil then
    return false
  end
  if not _IsTargetAbility(counter) then
    return false
  end
  local blackboard = counter.ability.blackboard
  if blackboard == nil then
    return false
  end
  local freelyVal = blackboard:GetBoolOrDefault(FREE_BUILD_BB_KEY, false, false)
  return freelyVal
end

local function _ResetIsFreelyInAbilityBlackboard(counter)
  if counter == nil or counter.ability == nil then
    return
  end
  if not _IsTargetAbility(counter) then
    return
  end
  local blackboard = counter.ability.blackboard
  if blackboard == nil then
    return
  end
  blackboard:Assign(FREE_BUILD_BB_KEY, 0.0)
end


_G.__AbilityEventCounter_SetNotEmitSpareShotAudioNext = _SetNotEmitSpareShotAudioNext

local function OnEventLua(self, ev)
  
  if ev == AbilityEvent.ON_CAST_START and _IsTargetAbility(self) then
    _RecordCastStartNotCountNext(self)
  end

  local notCountByFreely = false
  if ev == self._countEvent then
    notCountByFreely = _TryGetIsFreelyFromAbilityBlackboard(self)
  end
  local recordedNotCountNext
  if _IsTargetAbility(self) then
    recordedNotCountNext = _GetRecordedNotCountNext(self)
  else
    recordedNotCountNext = self.m_notCountNext
  end
  local shouldNotCount = recordedNotCountNext or notCountByFreely
  self:OnCountEvent(ev, self.m_eventCount, shouldNotCount or self.m_triggerOnce)
  if ev == self._countEvent and (not self.m_triggerOnce or self.ignoreTriggerOnce) then
    self.m_triggerOnce = true
    local shouldMuteSpareShot = _IsNotEmitSpareShotAudioNext(self)
    if shouldNotCount and not shouldMuteSpareShot then
      BattleController.instance:CreateEffect(DefaultEffects.SPARE_SHOT, self.owner, nil)
      BattleController.PlayAudioAtPos(
        AudioSignals.ON_TALENT_TRIGGER,
        AudioSignals.SPARE_SHOT,
        self.owner ~= nil and self.owner.worldPosition or Vector3.zero,
        self.owner)
    end
    self.m_eventCount = self.m_eventCount + (shouldNotCount and 0 or self._expendPerTrigger)
    self:OnEventCountConsumed(self._expendPerTrigger)
  end

  
  if ev == AbilityEvent.ON_CAST_END or ev == AbilityEvent.ON_DETACHED then
    self.m_notCountNext = false
    self.m_triggerOnce = false
    _ResetIsFreelyInAbilityBlackboard(self)
    _ClearNotEmitSpareShotAudioNext(self)
    _ClearCastStartNotCountNext(self)
    if self._resetAfterEnd and self.reachEnd then
      self.m_readyToReset = true
    end
  end

  if self._resetWhenAttackFinished and ev == AbilityEvent.ON_ATTACK_FINISH then
    self.m_notCountNext = false
    self.m_triggerOnce = false
    _ResetIsFreelyInAbilityBlackboard(self)
    _ClearNotEmitSpareShotAudioNext(self)
    _ClearCastStartNotCountNext(self)
    if self.reachEnd then
      self.m_readyToReset = true
    end
  end
end

local function SetDataLua(self, blackboard)
  self:SetData(blackboard)
  _CacheIsTargetAbility(self)
  _ResetIsFreelyInAbilityBlackboard(self)
  _ClearNotEmitSpareShotAudioNext(self)
  _ClearCastStartNotCountNext(self)
end

function AbilityEventCounterHotfixer:OnInit()
  xlua.private_accessible(AbilityEventCounter)
  xlua.private_accessible(AbilityBehaviour)

  self:Fix_ex(AbilityEventCounter, "SetData", function(self, blackboard)
    local ok, errorInfo = xpcall(SetDataLua, debug.traceback, self, blackboard)
    if not ok then
      LogError("[AbilityEventCounterHotfixer] fix" .. errorInfo)
    end
  end)

  self:Fix_ex(AbilityEventCounter, "OnEvent", function(self, ev)
    local ok, errorInfo = xpcall(OnEventLua, debug.traceback, self, ev)
    if not ok then
      LogError("[AbilityEventCounterHotfixer] fix" .. errorInfo)
    end
  end)
end

function AbilityEventCounterHotfixer:OnDispose()
end

return AbilityEventCounterHotfixer
