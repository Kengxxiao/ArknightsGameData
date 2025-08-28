
local CroslyHotfixer = Class("CroslyHotfixer", HotfixBase)
local StunMask = 524289 

local function IsModYBuff(buff)
  return buff ~= nil and buff.m_data ~= nil and buff.m_data.templateKey == "crosly_e_003_t2[status-resist]"
end
local function IsSourceCrosly(entity)
  return entity ~= nil and entity.id == "char_1502_crosly"
end
local function IsStunBuff(buff)
  return (buff.abnormalFlagMask & StunMask) > 0
end

local function IsDurationBuff(buff)
  return CS.Torappu.MathUtil.GT(buff.m_lifeTime, CS.Torappu.FP.Zero)
end

local function _OnOtherResistableBuffStart(buff)
  if IsModYBuff(buff) then
    local mainBuff = buff.context.mainBuff.value
    if mainBuff ~= nil and IsSourceCrosly(mainBuff.source) and IsStunBuff(mainBuff) and IsDurationBuff(mainBuff) then
      local hasValue, multiValue = buff.blackboard:TryGetFloat("one_minus_status_resistance")
      if hasValue then
        mainBuff.m_lifeTime = CS.Torappu.FP.FromFloat(mainBuff.m_lifeTime:AsFloat() * (1 + multiValue))
        mainBuff.m_remainingTime = mainBuff.m_lifeTime
      end
    end
  end
  buff:OnOtherResistableBuffStart()
end

function CroslyHotfixer:OnInit()
  if HOTFIX_ENABLE then
    xlua.private_accessible(CS.Torappu.Battle.Buff)
    self:Fix_ex(CS.Torappu.Battle.Buff, "OnOtherResistableBuffStart", function(buff)
      local ok, res = xpcall(_OnOtherResistableBuffStart, debug.traceback, buff)
      if not ok then
        LogError("[CroslyHotfixer] fix" .. res)
      end
    end)
  end
end

return CroslyHotfixer