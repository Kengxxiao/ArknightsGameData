local WangVisualStoneCtrlAbilityHotfixer = Class("WangVisualStoneCtrlAbilityHotfixer", HotfixBase)

local WangVisualStoneCtrlAbility = CS.Torappu.Battle.Abilities.WangVisualStoneCtrlAbility
local FREE_BUILD_BB_KEY = "isFreely"

local function BuildStoneLua(self, request)
  local freely = request.isFreeBuild
  local result, extraBuildUsedUp, buildPosUsedUp = self:BuildStone(request)

  if result and self.m_progressSource ~= nil and freely then
    if self._buildStoneAbility ~= nil and self._buildStoneAbility.blackboard ~= nil then
      self._buildStoneAbility.blackboard:Assign(FREE_BUILD_BB_KEY, 1.0)
    end
    local setMuteNext = rawget(_G, "__AbilityEventCounter_SetNotEmitSpareShotAudioNext")
    if setMuteNext ~= nil then
      setMuteNext(self.m_progressSource, true)
    end
  end
  return result, extraBuildUsedUp, buildPosUsedUp
end

function WangVisualStoneCtrlAbilityHotfixer:OnInit()
  xlua.private_accessible(WangVisualStoneCtrlAbility)

  self:Fix_ex(WangVisualStoneCtrlAbility, "BuildStone", function(self, request)
    local ok, resultOrError, extraBuildUsedUp, buildPosUsedUp = xpcall(BuildStoneLua, debug.traceback, self, request)
    if not ok then
      LogError("[WangVisualStoneCtrlAbilityHotfixer] fix" .. resultOrError)
      return false, false, false
    end
    return resultOrError, extraBuildUsedUp, buildPosUsedUp
  end)
end

function WangVisualStoneCtrlAbilityHotfixer:OnDispose()
end

return WangVisualStoneCtrlAbilityHotfixer
