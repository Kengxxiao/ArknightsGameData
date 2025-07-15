
local ContinuousRangeWithConditionsHotfixer = Class("ContinuousRangeWithConditionsHotfixer", HotfixBase)

local function _FixOnCharacterMenuShow(self, _)
  return
end

function ContinuousRangeWithConditionsHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.ContinuousRangeWithConditions)

  self:Fix_ex(CS.Torappu.Battle.ContinuousRangeWithConditions, "_OnCharacterMenuShow", function(self, characterObj)
    local ok, result = xpcall(_FixOnCharacterMenuShow, debug.traceback, self, characterObj)
    if not ok then
      LogError("[ContinuousRangeWithConditions._OnCharacterMenuShow] error : " .. tostring(result))
    end
  end)
end

function ContinuousRangeWithConditionsHotfixer:OnDispose()
end

return ContinuousRangeWithConditionsHotfixer