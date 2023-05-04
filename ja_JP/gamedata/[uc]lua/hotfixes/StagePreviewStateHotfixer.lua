




local StagePreviewStateHotfixer = Class("StagePreviewStateHotfixer", HotfixBase)

local function OnResumeFix(self)	
  self:OnResume()
  if self.isResumedFromStack then
    self._stateBean.selectedZoneProperty:NotifyUpdate()
  end
end

function StagePreviewStateHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.Stage.StagePreviewState)
  self:Fix_ex(CS.Torappu.UI.Stage.StagePreviewState, "OnResume", function(self)
    return OnResumeFix(self)
  end)
end

function StagePreviewStateHotfixer:OnDispose()
end

return StagePreviewStateHotfixer