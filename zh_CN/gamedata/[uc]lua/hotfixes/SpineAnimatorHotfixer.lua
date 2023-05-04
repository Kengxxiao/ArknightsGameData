local eutil = CS.Torappu.Lua.Util
local SpineAnimatorHotfixer = Class("SpineAnimatorHotfixer", HotfixBase)


local function PlayAnimationFix(self, data, forceFromStart, speed)	
	result = self:PlayAnimation(data, forceFromStart, speed)
	self.skeleton.cacheFixedBoundsCenterOnce = false;
    return result
end

local function StartFix(self)	
	self:Start()
	CS.Torappu.Battle.CameraController.instance.camera.transparencySortMode = CS.UnityEngine.TransparencySortMode.Orthographic
end

function SpineAnimatorHotfixer:OnInit()
	self:Fix_ex(CS.Torappu.Battle.SpineAnimator, "PlayAnimation", function(self, data, forceFromStart, speed)
        return PlayAnimationFix(self, data, forceFromStart, speed)
    end)

    self:Fix_ex(CS.Torappu.Battle.CameraController, "Start", function (self)
	    local ok, errorInfo = xpcall(StartFix, debug.traceback, self)
	    if not ok then
	        eutil.LogError("[CameraController] StartFix " .. errorInfo)
	    end
    end)
end

function SpineAnimatorHotfixer:OnDispose()
end

return SpineAnimatorHotfixer