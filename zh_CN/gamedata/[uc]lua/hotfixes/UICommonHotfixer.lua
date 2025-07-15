local UICommonHotfixer = Class("UICommonHotfixer", HotfixBase)

local function RTEndingSPOperatorLoadCharStatus(self, spOperatorInfo, characterData, detailData, playerCharacter)
    self:_LoadCharStatus(spOperatorInfo, characterData, detailData, playerCharacter)
    self.toMax = self.toMax and (playerCharacter.evolvePhase:CompareTo(CS.Torappu.EvolvePhase.PHASE_2) >= 0)
end

local function RTEndingSPOperatorLoadCharStatusFix(self, spOperatorInfo, characterData, detailData, playerCharacter)
    local ok, errorInfo = xpcall(RTEndingSPOperatorLoadCharStatus, debug.traceback, self, spOperatorInfo, characterData, detailData, playerCharacter)
    if not ok then
        LogError("[UICommonHotfixer] fix" .. errorInfo)
    end
end

local function Rogue4TravelLeaveToastGenDesc(self, param)
    CS.Torappu.UI.Roguelike.RL04.RL04TravelLeaveToastView.s_stringBuilder.Length = 0
    return self:_GenDesc(param)
end

local function Rogue4TravelLeaveToastGenDescFix(self, param)
    local ok, result = xpcall(Rogue4TravelLeaveToastGenDesc, debug.traceback, self, param)
    if ok then
        return result
    else
        LogError("[UICommonHotfixer] fix" .. result)
    end
end

function UICommonHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.UI.RoguelikeTopic.Ending.RoguelikeTopicEndingSPOperatorViewModel)
    xlua.private_accessible(CS.Torappu.UI.Roguelike.RL04.RL04TravelLeaveToastView)

    self:Fix_ex(CS.Torappu.UI.RoguelikeTopic.Ending.RoguelikeTopicEndingSPOperatorViewModel, "_LoadCharStatus", RTEndingSPOperatorLoadCharStatusFix)
    self:Fix_ex(CS.Torappu.UI.Roguelike.RL04.RL04TravelLeaveToastView, "_GenDesc", Rogue4TravelLeaveToastGenDescFix)

end

function UICommonHotfixer:OnDispose()
end

return UICommonHotfixer