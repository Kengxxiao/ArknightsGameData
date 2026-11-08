

local SpineAnimatorHotfixer = Class("SpineAnimatorHotfixer", HotfixBase)

local SpineAnimator = CS.Torappu.Battle.SpineAnimator
local Vector3 = CS.UnityEngine.Vector3
local Quaternion = CS.UnityEngine.Quaternion


local function _ReattachConstMuzzlesToHost(self, host)
  local dirTrans = host ~= nil and host.directionTransform or nil
  if dirTrans == nil then
    return
  end
  local muzzles = self.m_constMuzzles
  if muzzles == nil then
    return
  end
  local animTrans = self.transform
  for i = 0, muzzles.Length - 1 do
    local muzzle = muzzles[i]
    if muzzle ~= nil then
      local t = muzzle.transform
      if not t:IsChildOf(animTrans) and t.parent ~= dirTrans then
        local offset = t.localPosition
        t:SetParent(dirTrans, false )
        
        t.localScale = Vector3.one
        t.localRotation = Quaternion.identity
        t.localPosition = offset
      end
    end
  end
end

function SpineAnimatorHotfixer:OnInit()
  
  xlua.private_accessible(SpineAnimator)
  self:Fix_ex(SpineAnimator, "Init", function(self, host)
    self:Init(host)
    _ReattachConstMuzzlesToHost(self, host)
  end)
end

return SpineAnimatorHotfixer
