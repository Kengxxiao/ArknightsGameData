


local ReturnConstructMaterialProcessorHolderHotfixer = Class("ReturnConstructMaterialProcessorHolderHotfixer", HotfixBase)
local MathUtil = CS.Torappu.MathUtil
local function _DoProcess(self, inout)
  local times = 1
  local ok, value = inout.originValue:TryGetValue(self.m_filterRecipe.outputItemId, nil)
  if ok then
    times = value
  end
  for itemId, count in pairs(self.m_filterRecipe.materials) do
    local plusCnt = MathUtil.Float2Int(self.m_returnPercent:AsFloat() * count, self.m_roundingMode) * times
    if plusCnt > 0 then
      local ok, value = inout.extraValue:TryGetValue(itemId, nil)
      if ok then
        inout.extraValue[itemId] = value + plusCnt
      else
        inout.extraValue:Add(itemId, plusCnt)
      end
    end
  end
  return inout
end
function ReturnConstructMaterialProcessorHolderHotfixer:OnInit()
  if HOTFIX_ENABLE then
    if xlua and xlua.private_accessible then
      xlua.private_accessible(CS.Torappu.Battle.SandboxV3.ReturnConstructMaterialProcessorHolder)
    end

    self:Fix_ex(CS.Torappu.Battle.SandboxV3.ReturnConstructMaterialProcessorHolder, "_DoProcess", _DoProcess)
  end
end

return ReturnConstructMaterialProcessorHolderHotfixer