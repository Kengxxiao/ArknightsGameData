



local VCameraControllerHotfixer = Class("VCameraControllerHotfixer", HotfixBase)

local function _Fix_ForcusCharacterInControl(self, roomChar, targetX, targetZ, focusTime)
  local plane = roomChar.room.floorPlane
  local targetY = plane.worldCenter.y + self._planeHeightOffset
  local position = CS.UnityEngine.Vector3(targetX, targetY, targetZ)
  position.x = CS.UnityEngine.Mathf.Clamp(position.x, self._touchCamera.CamPosMin.x, self._touchCamera.CamPosMax.x)
  position.y = CS.UnityEngine.Mathf.Clamp(position.y, self._touchCamera.CamPosMin.y, self._touchCamera.CamPosMax.y)

  local offset = position - self._touchCamera.transform.position
  local ratio = offset.magnitude / 2.4
  if ratio >= 1 then
    offset = 2.4 * offset.normalized
  else
    offset = (ratio * ratio) * offset.normalized
  end

  if CS.Torappu.MathUtil.GT(offset.magnitude, 0) then
    self._touchCamera.transform.position = self._touchCamera.transform.position + offset
    self._touchCamera:ResetCameraBoundaries()
  end
  return nil
end

function VCameraControllerHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Building.Vault.VCameraController)
  self:Fix_ex(CS.Torappu.Building.Vault.VCameraController, "ForcusCharacterInControl",
      function(self, roomChar, targetX, targetZ, focusTime)
        local ok, ret =
            xpcall(_Fix_ForcusCharacterInControl, debug.traceback, self, roomChar, targetX, targetZ, focusTime)
        if not ok then
          LogError("[Hotfix] failed to fix ForcusCharacterInControl : " .. ret)
          return self:ForcusCharacterInControl(roomChar, targetX, targetZ, focusTime)
        else
          return ret
        end
      end)
end

return VCameraControllerHotfixer