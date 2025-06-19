
local AbilityEventCounterHotfixer = Class("AbilityEventCounterHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util
local BattleController = CS.Torappu.Battle.BattleController

local function IsBlaze2(entity)
  return entity.id == "char_1040_blaze2"
end

local function IsExcu2(entity)
  return entity.id == "char_1032_excu2"
end

local function IsBlaze2BuffInContext()
  local context = BattleController.instance.context
  local buff = context.buff.value
  if eutil.IsDestroyed(buff) then
    return false
  end

  return buff.key == "blaze2_s_3[listener]"
end

local function IsExcu2BuffInContext()
  local context = BattleController.instance.context
  local buff = context.buff.value
  if eutil.IsDestroyed(buff) then
    return false
  end

  return buff.key == "excu2_s_2"
end

local function _RecoverEventCountImp(self, count)
  local realCnt = math.max(math.min(count, self.m_eventCount), 0)
  self.m_eventCount = self.m_eventCount - realCnt
  return realCnt
end


local function RecoverEventCount(self, count)
  local ability = self.ability
  if eutil.IsDestroyed(ability) then
    return self:RecoverEventCount(count)
  end

  local entity = ability.owner
  if eutil.IsDestroyed(entity) then
    return self:RecoverEventCount(count)
  end

  if IsBlaze2(entity) and IsBlaze2BuffInContext() then
    return _RecoverEventCountImp(self, count)
  end
  
  if IsExcu2(entity) and IsExcu2BuffInContext() then
    return _RecoverEventCountImp(self, count)
  end
  
  return self:RecoverEventCount(count)
end

function AbilityEventCounterHotfixer:OnInit()
    xlua.private_accessible(typeof(CS.Torappu.Battle.Abilities.AbilityEventCounter))
    self:Fix_ex(typeof(CS.Torappu.Battle.Abilities.AbilityEventCounter), "RecoverEventCount", function(self, count) 
        local ok, result, errorInfo = xpcall(RecoverEventCount, debug.traceback, self, count)
        if ok then
            return result
        else
          eutil.LogError("[AbilityEventCounterHotfixer] RecoverEventCount fix" .. errorInfo)
          return self:RecoverEventCount(count)
        end
    end)
end

function AbilityEventCounterHotfixer:OnDispose()
end

return AbilityEventCounterHotfixer
