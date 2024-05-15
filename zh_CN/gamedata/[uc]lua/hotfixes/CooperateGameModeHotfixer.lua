
local CooperateGameModeHotfixer = Class("CooperateGameModeHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

function _HardSetPlayerSpeedFix(self, side, speedOn)
    self:_HardSetPlayerSpeed(side, speedOn)
    local sideInt = 0
    if side == CS.Torappu.PlayerSide.SIDE_A then
        sideInt = 1
    else
        sideInt = 2
    end

    if self.isResting and speedOn then
        local mask = 1 << sideInt
        self.m_playerSkipRestingMask = self.m_playerSkipRestingMask | mask
	    self.m_cooperateUIPlugin:OnPlayerSkipResting(side)
	    local checkMaskA = 1 << 1
	    local checkMaskB = 1 << 2
	    checkMaskB = checkMaskB | checkMaskA
	    if self.m_playerSkipRestingMask == checkMaskB then
	        self:OnRestingFinished()
	    end
    end
end

function CooperateGameModeHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.GameMode.GameModeFactory.CooperateGameMode)
    self:Fix_ex(CS.Torappu.Battle.GameMode.GameModeFactory.CooperateGameMode, "_HardSetPlayerSpeed", function(self, side, speedOn) 
        local ok, errorInfo = xpcall(_HardSetPlayerSpeedFix, debug.traceback, self, side, speedOn)
        if not ok then
          eutil.LogError("[CooperateGameModeHotfixer] _HardSetPlayerSpeed fix" .. errorInfo)
        end
    end)
end

function CooperateGameModeHotfixer:OnDispose()
end

return CooperateGameModeHotfixer