
local CooperateHintPanelHotfixer = Class("CooperateHintPanelHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

function UpdateFix(self)
    self:Update()
    if self.m_gameMode.isResting then
        self._hintRect.anchoredPosition = self.m_fixPos
    else
        self._hintRect.anchoredPosition = self.m_originPos
    end
end

function CooperateHintPanelHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Activity.Cooperate.Battle.UI.CoopereteHintPanel)
    self:Fix_ex(CS.Torappu.Activity.Cooperate.Battle.UI.CoopereteHintPanel, "Update", function(self) 
        local ok, errorInfo = xpcall(UpdateFix, debug.traceback, self)
        if not ok then
          eutil.LogError("[CooperateHintPanelHotfixer] Update fix" .. errorInfo)
        end
    end)
end

function CooperateHintPanelHotfixer:OnDispose()
end

return CooperateHintPanelHotfixer