local eutil = CS.Torappu.Lua.Util

---@class LimitPoolHotfixer:HotfixBase
local LimitPoolHotfixer = Class("LimitPoolHotfixer", HotfixBase)

local function fixOnResume(self)
  self:OnResume()
  if (self.isResumedFromStack) then
    self._gachaView:RefreshGachaTkState()
  end
end

function LimitPoolHotfixer:OnInit()
  self:Fix_ex(CS.Torappu.UI.Recruit.RecruitSlideState, "OnResume", function(self)
    local ok, error = xpcall(fixOnResume,debug.traceback,self)
    if not ok then
      eutil.LogError("[limitpool] fix" .. error)
    end
  end)
end


function LimitPoolHotfixer:OnDispose()
end

return LimitPoolHotfixer