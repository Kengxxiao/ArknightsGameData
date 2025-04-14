local EnemyDuelBattleFinishRankItemViewHotfixer = Class("EnemyDuelBattleFinishRankItemViewHotfixer", HotfixBase)
local function Fix_RenderAvatar(self, model)
  local isInited = self._avatarContainer.childCount > 0

  if isInited then 
    self._avatarToggle.selected = model.isNPC
    if model.isNPC then
      local avatarSprite = CS.Torappu.UI.EnemyDuel.EnemyDuelUtil.LoadNpcAvatar(model.actId, model.npcAvatarId, nil)
      self._npcAvatar.sprite = avatarSprite
    else
      local child = self._avatarContainer:GetChild(0)
      if child == nil then 
        return;
      end
      local avatarView = child:GetComponent("PlayerAvatarView")
      if avatarView == nil then 
        return;
      end
      local param = CS.Torappu.UI.PlayerAvatarView.Params()
      param.forceUseStaticAvatar = false
      param.inBattleFinishScene = true
      avatarView:Render(model.avatarInfo, param)
    end
  else 
    self:_RenderAvatar(model)
  end
end
function EnemyDuelBattleFinishRankItemViewHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.EnemyDuel.EnemyDuelBattleFinishRankItemView)
  self:Fix_ex(CS.Torappu.UI.EnemyDuel.EnemyDuelBattleFinishRankItemView, "_RenderAvatar", function(self, model)
      local ok, errorInfo = xpcall(Fix_RenderAvatar, debug.traceback, self, model)
      if not ok then
          LogError("[EnemyDuelBattleFinishRankItemViewHotfixer] fix _RenderAvatar " .. errorInfo)
      end
  end)
end

return EnemyDuelBattleFinishRankItemViewHotfixer