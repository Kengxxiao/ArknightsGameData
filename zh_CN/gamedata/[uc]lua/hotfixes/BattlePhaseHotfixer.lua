
local BattlePhaseHotfixer = Class("BattlePhaseHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

function _PreserveToFix(self, frameCount)
    if self.m_leftFrameInStepInFast > 0 then
        while self.m_leftFrameInStepInFast >= 1 do
            self.m_gameMode:NextFrame()
            self.m_leftFrameInStepInFast = self.m_leftFrameInStepInFast - 1
            self.m_playFramesOnce = self.m_playFramesOnce - 1
        end
    end
    if frameCount < 0 then
        self.m_preserveCnt = 0
    else
        self.m_preserveCnt = frameCount
    end
end

function BattlePhaseHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Multiplayer.BattlePhase)
    
    self:Fix_ex(CS.Torappu.Multiplayer.BattlePhase, "_PreserveTo", function(self, frameCount)
        local ok, errorInfo = xpcall(_PreserveToFix, debug.traceback, self, frameCount)
        if not ok then
            eutil.LogError("[BattlePhaseHotfixer] BattlePhase fix" .. errorInfo)
        end
    end)
end

function BattlePhaseHotfixer:OnDispose()
end

return BattlePhaseHotfixer