
local ActVecBreakV2OffenseTowerViewHotfixer  = Class("ActVecBreakV2OffenseTowerViewHotfixer", HotfixBase)

local function _PlayTowerTranslateTweenFix(self, model)
  if self.m_translateTween and self.m_translateTween:IsPlaying() then
    self.m_translateTween:Kill()
    self.m_translateTween = nil
  end
  self:_PlayTowerTranslateTween(model)
end

function ActVecBreakV2OffenseTowerViewHotfixer:OnInit()
  xlua.private_accessible(typeof(CS.Torappu.Activity.VecBreakV2.ActVecBreakV2OffenseTowerView))
  self:Fix_ex(typeof(CS.Torappu.Activity.VecBreakV2.ActVecBreakV2OffenseTowerView), "_PlayTowerTranslateTween", function (self, model)
    local ok, errorInfo = xpcall(_PlayTowerTranslateTweenFix, debug.traceback, self, model)
    if not ok then
      LogError("[Act Vec Break V2] offense stage select tower view: ".. errorInfo)
      self:_PlayTowerTranslateTween(model)
    end
  end)
end

return ActVecBreakV2OffenseTowerViewHotfixer;