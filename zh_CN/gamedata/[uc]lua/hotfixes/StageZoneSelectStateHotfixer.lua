local StageZoneSelectStateHotfixer = Class("StageZoneSelectStateHotfixer", HotfixBase)

local function OnResumeFix(self)
    local eventMask = self._globalEventMask
    if (eventMask ~= nil) then
        eventMask:SetActive(false)
    end
    local stateBean = self._stateBean
    stateBean:SetSelectZone(null)
    if (not self.isResumedFromStack) then
        return
    end
    stateBean:UpdateZoneGroupStatus()
end

function StageZoneSelectStateHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.UI.Stage.StageZoneSelectState)

    self:Fix_ex(CS.Torappu.UI.Stage.StageZoneSelectState, "OnResume", function(self)
        local ok, errorInfo = xpcall(OnResumeFix, debug.traceback, self)
        if not ok then
            LogError("[StageZoneSelectStateHotfixer] fix" .. errorInfo)
        end
    end)
end

function StageZoneSelectStateHotfixer:OnDispose()
end

return StageZoneSelectStateHotfixer