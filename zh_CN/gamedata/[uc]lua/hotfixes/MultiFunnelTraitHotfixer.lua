local MultiFunnelTraitHotfixer = Class("MultiFunnelTraitHotfixer", HotfixBase)

local function _SetNormalAtkScale(self, target, ability)
  if self.m_normalFirstFunnel == nil then
    self.m_normalFirstFunnel = ability
  end
  local mainFunnelData = self.m_mainFunnelData
  if mainFunnelData.lastTarget:Lock() ~= target then
    local wrapTemplate = xlua.get_generic_method(CS.Torappu.ObjectPtr, "Wrap")
    local wrapEntity = wrapTemplate(CS.Torappu.Battle.Entity)
    local objectPtr = wrapEntity(target)
    mainFunnelData.lastTarget = objectPtr
    mainFunnelData.curStackCnt = 0
  elseif mainFunnelData.curStackCnt < self.m_maxStackCnt then
    if string.find(self.owner.id, "whitw2") == nil or ability == self.m_normalFirstFunnel then
      mainFunnelData.curStackCnt = mainFunnelData.curStackCnt + 1
    end
  else
    mainFunnelData.curStackCnt = self.m_maxStackCnt
  end
  mainFunnelData.curAtkScale = self.m_initAtkScale + mainFunnelData.curStackCnt * self.m_deltaAtkScale
  if self.maxAtkScale < mainFunnelData.curAtkScale then
    mainFunnelData.curAtkScale = self.maxAtkScale
  end
  self.m_mainFunnelData = mainFunnelData
  return mainFunnelData.curAtkScale
end

function MultiFunnelTraitHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.Abilities.MultiFunnelTrait)
  self:Fix_ex(CS.Torappu.Battle.Abilities.MultiFunnelTrait, "SetNormalAtkScale", function(self, target, ability)
    local ok, result = xpcall(_SetNormalAtkScale, debug.traceback, self, target, ability)
    if not ok then
      LogError("[MultiFunnelTraitHotfixer] fix" .. result)
    else
      return result;
    end
  end)
end

function MultiFunnelTraitHotfixer:OnDispose()
end

return MultiFunnelTraitHotfixer