local BackgroundMultiFormHotfixer = Class("BackgroundMultiFormHotfixer", HotfixBase)



local function ImageHandlerOnMultiFormChangedLua(self, formModel, shouldReset)
    if formModel == nil or formModel.formId == nil or formModel.formId == "" then
        return
    end
    local shouldForceReset = shouldReset or self.m_cachedFormId == nil or self.m_cachedFormId == ""

    self:OnMultiFormChanged(formModel, shouldForceReset)
end

local function RingStateGraphGetSegmentLua(self, stateId)
    if stateId == nil or self.stateId == "" then
        return nil
    end
    return self:GetSegment(stateId)
end


function BackgroundMultiFormHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.UI.Home.HomeBackgroundMultiFormImageHandler)
    xlua.private_accessible(CS.Torappu.UI.UIRingStateGraph)

    self:Fix_ex(CS.Torappu.UI.Home.HomeBackgroundMultiFormImageHandler, "OnMultiFormChanged", function(self, formModel, shouldReset)
        local ok, errorInfo = xpcall(ImageHandlerOnMultiFormChangedLua, debug.traceback, self, formModel, shouldReset)
        if not ok then
            LogError("[BackgroundMultiFormHotfixer] fix" .. errorInfo)
        end
    end)

    self:Fix_ex(CS.Torappu.UI.UIRingStateGraph, "GetSegment", function(self, stateId)
        local ok, result = xpcall(RingStateGraphGetSegmentLua, debug.traceback, self, stateId)
        if not ok then
            LogError("[BackgroundMultiFormHotfixer] fix" .. result)
        end
        return result
    end)
end

function BackgroundMultiFormHotfixer:OnDispose()
end

return BackgroundMultiFormHotfixer