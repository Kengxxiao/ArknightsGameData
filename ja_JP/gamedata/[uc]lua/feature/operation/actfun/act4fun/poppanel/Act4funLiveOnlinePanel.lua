

local Act4funLiveOnlinePanel = Class("Act4funLiveOnlinePanel", Act4funLivePopPanelBase);
Act4funLiveOnlinePanel.ANIM_NAME = "act4fun_live_online";



function Act4funLiveOnlinePanel:OnViewModelUpdate(data)
  local valid = data.currStep == Act4funLiveStep.ONLINE;
  self:SetVisible(valid);
  if not valid then
    return;
  end
  CS.Torappu.TorappuAudio.PlayUI(AudioConsts.ACT4FUN_LIVELOADING);

  local this = self;
  self._anim:InitIfNot();
  self._anim:Stop(self.ANIM_NAME, false);
  self._anim:Play(self.ANIM_NAME, {
    isFillAfter = true,
    isInverse = false,
    onAnimEnd = function()
      this:_CompleteAnim();
    end
  });
end

function Act4funLiveOnlinePanel:_CompleteAnim()
  self.m_cachedData:CompleteOnline();
end

return Act4funLiveOnlinePanel;