
local FriendShowQRDialogHotfixer = Class("FriendShowQRDialogHotfixer", HotfixBase)

local function _ApplyAvatarLocalScale(dialog)
  local avatarView = dialog.m_avatarView
  if avatarView == nil then
    return
  end
  local scaler = avatarView:GetComponent(typeof(CS.Torappu.UI.UIScaler))
  if scaler == nil or math.abs(scaler.scale - 1) < 0.001 then
    return
  end
  local nameCardScale = scaler.scale
  
  
  scaler.scale = 1
  avatarView.transform.localScale = CS.UnityEngine.Vector3(nameCardScale, nameCardScale, 1)
end

function FriendShowQRDialogHotfixer:OnInit()
  self:Fix_ex(CS.Torappu.UI.Friend.FriendShowQRDialog, "OnRender", function(self, input)
    self:OnRender(input)
    _ApplyAvatarLocalScale(self)
  end)
end

return FriendShowQRDialogHotfixer
