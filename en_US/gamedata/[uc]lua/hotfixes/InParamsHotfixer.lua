local InParamsHotfixer = Class("InParamsHotfixer", HotfixBase)

local function GetFinalDifficultyFix(self)	
	if self.difficulty == CS.Torappu.LevelData.Difficulty.FOUR_STAR then
		return self.difficulty
	end
    return self:GetFinalDifficulty()
end

function InParamsHotfixer:OnInit()
	self:Fix_ex(CS.Torappu.Battle.BattleInOut.InParams, "GetFinalDifficulty", function(self)
        return GetFinalDifficultyFix(self)
    end)
end

function InParamsHotfixer:OnDispose()
end

return InParamsHotfixer