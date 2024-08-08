local CameraControllerHotfixer = Class("CameraControllerHotfixer", HotfixBase)

local function ReplaceCameraHotfix(self, newCamera)
    if newCamera == nil or self._camera == nil then
        return
    end

    newCamera.transform.localPosition = self._camera.transform.localPosition
    newCamera.transform.localRotation = self._camera.transform.localRotation
    self:ReplaceCamera(newCamera)
end

function CameraControllerHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.CameraController)

    self:Fix_ex(CS.Torappu.Battle.CameraController, "ReplaceCamera", function(self, newCamera)
        local ok, errorInfo = xpcall(ReplaceCameraHotfix, debug.traceback, self, newCamera)
        if not ok then
            LogError("[CameraControllerHotfixer] fix" .. errorInfo)
        end
    end)
end

function CameraControllerHotfixer:OnDispose()
end

return CameraControllerHotfixer