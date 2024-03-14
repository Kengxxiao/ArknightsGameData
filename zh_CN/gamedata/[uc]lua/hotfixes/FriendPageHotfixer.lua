
local FriendPageHotfixer = Class("FriendPageHotfixer", HotfixBase)

local function _DeleteImageRef(self, inst)
  self:_OnInitTopMenu(inst)
  local imageObj = FindChildByPath(self.transform, "friend_state_engine/friend_name_card_skin_change_state/panel_right/bg/shadow")
  if imageObj == nil then
    return
  end
  local image = imageObj:GetComponent("UnityEngine.UI.Image")
  if image == nil then
    return
  end
  image.sprite = nil
end

function FriendPageHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.Friend.FriendPage)
  self:Fix_ex(CS.Torappu.UI.Friend.FriendPage, "_OnInitTopMenu", function(self, inst)
    local ok, info = xpcall(_DeleteImageRef, debug.traceback, self, inst)
    if not ok then 
      LogError("[FriendPage] fix" .. info)
    end
  end)
end

return FriendPageHotfixer