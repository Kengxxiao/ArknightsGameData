
local ParamVariablePoolHotfixer = Class("ParamVariablePoolHotfixer", HotfixBase)

local function _Recycle(self, variable)
 return
end

function ParamVariablePoolHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.LevelScript.ParamVariablePool)
  self:Fix_ex(CS.Torappu.Battle.LevelScript.ParamVariablePool, "Recycle", function(self, variable)
    local ok, result = xpcall(_Recycle, debug.traceback, self, variable)
    if not ok then
      LogError("[ParamVariablePoolHotfixer] fix" .. result)
    end
  end)
end

function ParamVariablePoolHotfixer:OnDispose()
end

return ParamVariablePoolHotfixer
