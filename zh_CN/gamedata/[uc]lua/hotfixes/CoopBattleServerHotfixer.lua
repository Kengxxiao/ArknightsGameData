local CoopBattleServerHotfixer = Class("CoopBattleServerHotfixer", HotfixBase)

local function Fix_DoRev(self, step)
    if step.index ~= self.m_receivedStep then
        CS.UnityEngine.DLog.LogError(string.format("[CoopBattleServer] step index wrong:%d=>%d", self.m_receivedStep, step.index))
    end
    self:_DoRev(step)
end

function CoopBattleServerHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Multiplayer.Servers.BattleServer)

    self:Fix_ex(CS.Torappu.Multiplayer.Servers.BattleServer, "_DoRev", function(self, step)
        local ok, ret = xpcall(Fix_DoRev, debug.traceback, self, step)
        if not ok then
            LogError("[CoopBattleServerHotfixer] fix" .. ret)
        end
        return ret
    end)
end

function CoopBattleServerHotfixer:OnDispose()
end

return CoopBattleServerHotfixer