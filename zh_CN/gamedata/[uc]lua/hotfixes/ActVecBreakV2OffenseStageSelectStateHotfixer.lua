
local ActVecBreakV2OffenseStageSelectStateHotfixer = Class("ActVecBreakV2OffenseStageSelectStateHotfixer", HotfixBase)

local function _OnPreResumeFix(self, isFromStack)
  if isFromStack then
    local page = self:GetPage()
    self:_ClearTowerCoroutine(page)
    self:_ClearFromBattleCoroutine(page)
  end
  self:OnPreResume(isFromStack)
end

function ActVecBreakV2OffenseStageSelectStateHotfixer:OnInit()
  xlua.private_accessible(typeof(CS.Torappu.Activity.VecBreakV2.ActVecBreakV2OffenseStageSelectState))
  self:Fix_ex(typeof(CS.Torappu.Activity.VecBreakV2.ActVecBreakV2OffenseStageSelectState), "OnPreResume", function (self, isFromStack)
    local ok, errorInfo = xpcall(_OnPreResumeFix, debug.traceback, self, isFromStack)
    if not ok then
      LogError("[Act Vec Break V2] offense stage select state: ".. errorInfo)
      self:OnPreResume(isFromStack)
    end
  end)
end

return ActVecBreakV2OffenseStageSelectStateHotfixer;