-- local BaseHotfixer = require ("Module/Core/BaseHotfixer")
-- local xutil = require('xlua.util')
local eutil = CS.Torappu.Lua.Util

local classToInject = CS.Torappu.Activity.Act3D0.Act3D0MileStoneObj
---@class ShopHotfixer:HotfixBase
local MilestoneTweenHotfixer = Class("MilestoneTweenHotfixer", HotfixBase)


local function ResetTweenState(self)
  if self.m_cacheTween ~= nil then
    self._canvasGroup.alpha = 1
  end
end

function MilestoneTweenHotfixer:OnInit()
  self:Fix_ex(classToInject,"RenderAgain",
  function(self,viewModel)
    local ok, error = xpcall(ResetTweenState, debug.traceback, self)
    if not ok then 
      eutil.LogError("[MilestoneTweenHotfixer] fix milestoneTween Error:" .. error)
    end
    self:RenderAgain(viewModel)
  end)
end

function MilestoneTweenHotfixer:OnDispose()
  --xlua.hotfix(classToInject,"RenderAgain",nil)
end

return MilestoneTweenHotfixer