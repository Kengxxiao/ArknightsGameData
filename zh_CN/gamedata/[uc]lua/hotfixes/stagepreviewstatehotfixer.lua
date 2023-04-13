local StagePreviewStateHotfixer = Class("StagePreviewStateHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util
local StagePreviewState = CS.Torappu.UI.Stage.StagePreviewState

local function OnResumeFix(self)
  self:OnResume()
  local fromStack = self.isResumedFromStack
  if fromStack then 
    local selectProp = self._stateBean.selectedZoneProperty
    local model = selectProp.Value
    if model == nil then
      return
    end
    local zoneId = model.id
    if zoneId == nil or zoneId == '' then
      return
    end
    model.rewardBuffViewModel:LoadData(zoneId)
    selectProp:NotifyUpdate()
  end
end

function StagePreviewStateHotfixer:OnInit()
  xlua.private_accessible(StagePreviewState)

  self:Fix_ex(StagePreviewState, "OnResume", function(self)
    local ok, errorInfo = xpcall(OnResumeFix, debug.traceback, self)
    if not ok then
      eutil.LogError("[StagePreviewStateHotfixer] fix" .. errorInfo)
    end
  end)
end

function StagePreviewStateHotfixer:OnDispose()
end

return StagePreviewStateHotfixer