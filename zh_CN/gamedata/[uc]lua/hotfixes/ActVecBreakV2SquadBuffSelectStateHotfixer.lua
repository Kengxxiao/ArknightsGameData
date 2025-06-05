local luaUtils = CS.Torappu.Lua.Util
local VecBreakStageDefendStatus = CS.Torappu.Activity.VecBreakV2.VecBreakStageDefendStatus

local ActVecBreakV2SquadBuffSelectStateHotfixer = Class("ActVecBreakV2SquadBuffSelectStateHotfixer", HotfixBase)

local function _KickOutDefendCharsFromSquadFix(self, squadViewModel)
  if self.m_stageProvider == nil or squadViewModel == nil then
    return
  end

  if squadViewModel.members == nil then
    return
  end

  local memberCnt = squadViewModel.members.Length
  for i = 0, memberCnt-1 do
    local member = squadViewModel.members[i]
    if not member:IsEmpty() then
      local memberCharInstId = member.cardModel.chrInstId
      local defendStatus = self.m_stageProvider:CalcDefendStatus(memberCharInstId)
      if defendStatus == VecBreakStageDefendStatus.OTHER or defendStatus == VecBreakStageDefendStatus.SAME_GROUP then
        squadViewModel.members[i] = CS.Torappu.UI.Squad.SquadItemStruct.EMPTY
      end
    end
  end
end

function ActVecBreakV2SquadBuffSelectStateHotfixer:OnInit()
  xlua.private_accessible(typeof(CS.Torappu.Activity.VecBreakV2.VecBreakSquadGroupViewModel))
  self:Fix_ex(CS.Torappu.Activity.VecBreakV2.VecBreakSquadGroupViewModel, "_KickOutDefendCharsFromSquad", function(self, squadViewModel)
    local ok, errorInfo = xpcall(_KickOutDefendCharsFromSquadFix, debug.traceback, self, squadViewModel)
    if not ok then
      LogError("[Act Vec Break] SquadGroupViewModel fix error: " .. errorInfo)
      self:_KickOutDefendCharsFromSquad(squadViewModel)
    end
  end)
end

return ActVecBreakV2SquadBuffSelectStateHotfixer