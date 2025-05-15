



local AnimationWrapperHotfixer = Class("AnimationWrapperHotfixer", HotfixBase)

local function _FixIsAnimating(self, name)
  local ok, runtime = self.m_animPool:TryGetValue(name)
  if not ok or runtime == nil then
    return false
  end
  if not runtime.isPlaying then
    return false
  end
  local isPlaying = self.m_target:IsPlaying(name)
  if not isPlaying then
    self:_FinishAnimation(runtime, true)
  end
  return runtime.isPlaying
end
function AnimationWrapperHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.AnimationWrapper)
  self:Fix_ex(CS.Torappu.UI.AnimationWrapper, "_IsAnimating", function(self, name)
    local ok, ret = xpcall(_FixIsAnimating, debug.traceback, self, name)
    if ok then
      return ret
    end
    LogError("[AnimationWrapper] Failed to fix _IsAnimating : " .. ret)
    return self:_IsAnimating(name)
  end)
end

return AnimationWrapperHotfixer