


local GradingControllerHotfixer = Class("GradingControllerHotfixer", HotfixBase)

local GradingController = CS.Torappu.Grading.GradingController
local GradingLevel = GradingController.GradingLevel

local function _Get_SP_ADDITIONAL_LIGHT_ViaLevel_Fixed(self, level)
  if level == GradingLevel.LOW then
    return false
  elseif level == GradingLevel.MEDIUM then
    return false  
  elseif level == GradingLevel.HIGH then
    return true
  else
    return true
  end
end

function GradingControllerHotfixer:OnInit()
  if not HOTFIX_ENABLE then
    return
  end

  xlua.private_accessible(CS.Torappu.Grading.GradingController)

  self:Fix_ex(GradingController, "_Get_SP_ADDITIONAL_LIGHT_ViaLevel", function(self, level)
    local ok, res = xpcall(_Get_SP_ADDITIONAL_LIGHT_ViaLevel_Fixed, debug.traceback, self, level)
    if not ok then
      LogError("[GradingControllerHotfixer] _Get_SP_ADDITIONAL_LIGHT_ViaLevel error: " .. tostring(res))
      return false
    end
    return res
  end)
end

function GradingControllerHotfixer:OnDispose()
end

return GradingControllerHotfixer
