
local DurbusAbilityHotfixer = Class("DurbusAbilityHotfixer", HotfixBase)

local function _KillLastPassenger(self)
  local passengerList = self.m_passengers
  local passengerCount = passengerList.Count
  for i = passengerCount - 1, 0, -1 do
    local passenger = passengerList[i]:Lock()
    if passenger ~= nil and passenger.isDisappeared then
      passengerList:RemoveAt(i)
      passenger:Suicide(true, true)
      self:_UpdatePassengerEffect()
      return true
    end
  end
  return false
end

function DurbusAbilityHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.Abilities.DurbusAbility)
  self:Fix_ex(CS.Torappu.Battle.Abilities.DurbusAbility, "KillLastPassenger", function(self)
    local ok, res = xpcall(_KillLastPassenger, debug.traceback, self)
    if not ok then
      LogError("[DurbusAbilityHotfixer] fix" .. res)
    end
    return res
  end)
end

function DurbusAbilityHotfixer:OnDispose()
end

return DurbusAbilityHotfixer