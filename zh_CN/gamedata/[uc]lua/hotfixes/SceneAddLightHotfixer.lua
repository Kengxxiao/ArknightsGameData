
local SceneAddLightHotfixer = Class("SceneAddLightHotfixer", HotfixBase)
local function CalculateSpotDataFix(self, innerSpotAngle, outerSpotAngle, type)
  local Mathf = CS.UnityEngine.Mathf
  local innerCos = Mathf.Cos(Mathf.Deg2Rad * 0.5 * innerSpotAngle)
  local outerCos = Mathf.Cos(Mathf.Deg2Rad * 0.5 * outerSpotAngle)
  local angleRangeInv = 1.0 / Mathf.Max(innerCos - outerCos, 0.001)
  return CS.UnityEngine.Vector4(angleRangeInv, outerCos, type == CS.UnityEngine.LightType.Spot and 1 or 0, 0)
end

local soc = nil
local RuntimePlatform = CS.UnityEngine.RuntimePlatform

local function _DisableAddLight()
  local levelId = CS.Torappu.Battle.BattleInOut.instance.input.stageInfo.levelId
  if not levelId or not string.find(levelId, "act43side") then
    return false
  end

  if CS.UnityEngine.Application.platform ~= RuntimePlatform.Android then
    return false
  end

  if CS.UnityEngine.Screen.height <= 1500 then
    return false
  end
  
  if soc == nil then
    soc = CS.Torappu.Grading.HGGradingDetector.GetAndroidSOCOrModelName()
  end
  if not soc or soc == "" or not string.find(string.lower(soc), "kirin 9000") then
    return false
  end
  
  return true
end

local function _FixInit(self)
  if _DisableAddLight() then
    self.m_inited = false
    return
  end
  self:_Init()
end
function SceneAddLightHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Rendering.SceneAddLight)
  self:Fix_ex(CS.Torappu.Rendering.SceneAddLight, "CalculateSpotData", function(self, innerSpotAngle, outerSpotAngle, type)
    local ok, error = xpcall(CalculateSpotDataFix, debug.traceback, self, innerSpotAngle, outerSpotAngle, type)
    if not ok then
      LogError("[SceneAddLight.CalculateSpotData] error : " .. error)
      return self:CalculateSpotData(innerSpotAngle, outerSpotAngle, type)
    end
    return error
  end)

  self:Fix_ex(CS.Torappu.Rendering.SceneAddLight, "_Init", function(self)
    local ok, error = xpcall(_FixInit, debug.traceback, self)
    if not ok then
      LogError("[SceneAddLight._Init] error : " .. error)
      self:_Init()
    end
  end)
end

function SceneAddLightHotfixer:OnDispose()
end

return SceneAddLightHotfixer