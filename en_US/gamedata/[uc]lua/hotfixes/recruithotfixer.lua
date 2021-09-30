local xutil = require('xlua.util')
local eutil = CS.Torappu.Lua.Util


local RecruitHotfixer = Class("RecruitHotfixer", HotfixBase)

local function _CheckIfCanFastFinish(stateBean, slotIndex)
  local groupModel = stateBean.slotGroupProperty.Value
  if groupModel == nil or groupModel.buildSlots == nil then
    return false
  end
  if slotIndex < 0 or slotIndex >= groupModel.buildSlots.Count then
    return false
  end
  local slotModel = groupModel.buildSlots[slotIndex]
  if slotModel == nil then
    return false
  end
  return slotModel.state == CS.Torappu.RecruitBuildSlotState.BUILDING
end

local function OnConfirmFastFinish(self, slotIndex)
  if not _CheckIfCanFastFinish(self._stateBean, slotIndex) then
    return
  end

  self:OnConfirmFastFinish(slotIndex)
end

function RecruitHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.UI.Recruit.RecruitSlideState)

    self:Fix_ex(CS.Torappu.UI.Recruit.RecruitSlideState, "OnConfirmFastFinish", OnConfirmFastFinish)
end

function RecruitHotfixer:OnDispose()
end

return RecruitHotfixer