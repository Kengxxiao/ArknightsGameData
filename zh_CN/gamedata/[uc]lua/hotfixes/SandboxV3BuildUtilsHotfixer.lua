

local SandboxV3BuildUtilsHotfixer = Class("SandboxV3BuildUtilsHotfixer", HotfixBase)

local SandboxV3BuildUtils = CS.Torappu.Battle.SandboxV3.SandboxV3BuildUtils
local SandboxV3BuildScoreType = CS.Torappu.SandboxV3BuildScoreType

local function _GetNpcScoreHotfix(npcId, data)
  local has, npcData = data.buildScoreData:TryGetValue(npcId)
  if not has or npcData == nil then
    return false, 0
  end
  local pt = CS.System.Convert.ToInt32(npcData.paramType)
  if pt ~= CS.System.Convert.ToInt32(SandboxV3BuildScoreType.NPC) and pt ~= CS.System.Convert.ToInt32(SandboxV3BuildScoreType.ENPC) then
    return false, 0
  end
  return true, npcData.buildScore
end

function SandboxV3BuildUtilsHotfixer:OnInit()
  if HOTFIX_ENABLE then
    self:Fix_ex(SandboxV3BuildUtils, "GetNpcScore", _GetNpcScoreHotfix)
  end
end

return SandboxV3BuildUtilsHotfixer
