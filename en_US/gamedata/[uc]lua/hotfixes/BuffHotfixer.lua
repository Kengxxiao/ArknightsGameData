local BuffHotfixer = Class("BuffHotfixer", HotfixBase)

local function _OnOtherBuffStart(self, otherBuff)
	if (not string.find(self.owner.name, "char_322_lmlee")) then
        return
    end

    self:OnOtherBuffStart(otherBuff)
end

function BuffHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.Buff.BuffContainer)

    self:Fix_ex(CS.Torappu.Battle.Buff.BuffContainer, "OnOtherBuffStart", function(self, otherBuff)
        local ok, errorInfo = xpcall(_OnOtherBuffStart, debug.traceback, self, otherBuff)
        if not ok then
            CS.UnityEngine.DLog.LogError(errorInfo)
        end
    end)
end

function BuffHotfixer:OnDispose()
end

return BuffHotfixer