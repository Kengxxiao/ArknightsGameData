
local AdvancedSelectorForSandboxV3GatherHotfixer = Class("AdvancedSelectorForSandboxV3GatherHotfixer", HotfixBase)

local Map = CS.Torappu.Battle.Map
local SelectorCls = CS.Torappu.Battle.AdvancedSelectorForSandboxV3Gather
local FilterType = SelectorCls.SandboxV3GatherFilterType
local MotionMode = CS.Torappu.MotionMode

local function _OnPostFilter(self, candidates)
  self:OnPostFilter(candidates)
  if candidates and candidates.Count > 0 and Map.hasInstance and self._filterType == FilterType.SEARCH_RES then
    for i = candidates.Count - 1, 0, -1 do
      local candidate = candidates[i]
      if not Map.instance:CheckReachable(MotionMode.WALK, self.owner.gridPosition, candidate.gridPosition, false) then
        candidates:RemoveAt(i)
      end
    end
  end
end

function AdvancedSelectorForSandboxV3GatherHotfixer:OnInit()
  if HOTFIX_ENABLE then
    if xlua and xlua.private_accessible then
      xlua.private_accessible(SelectorCls)
    end

    self:Fix_ex(SelectorCls, "OnPostFilter", _OnPostFilter)
  end
end

return AdvancedSelectorForSandboxV3GatherHotfixer