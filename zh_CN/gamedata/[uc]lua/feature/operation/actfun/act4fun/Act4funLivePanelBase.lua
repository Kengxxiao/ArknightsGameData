


Act4funLivePanelBase = Class("Act4funLivePanelBase", UIPanel);



function Act4funLivePanelBase:BindHost(owner, viewModel)
  self.m_owner = owner;
  self.m_cachedData = viewModel;
end






Act4funLivePopPanelBase = Class("Act4funLivePopPanelBase", Act4funLivePanelBase)
Act4funLivePopPanelBase.FADE_DUR = 0.4;


function Act4funLivePopPanelBase:SetVisible(visible)
  if not self._alphaHandler then
    Act4funLivePopPanelBase.super.SetVisible(self, visible);
    return;
  end
  if self.m_fadeTween then
    self.m_fadeTween.isShow = visible;
  else
    self.m_fadeTween = CS.Torappu.UI.FadeSwitchTween(self._alphaHandler);
    self.m_fadeTween.duration = self.FADE_DUR;
  self.m_fadeTween:Reset(visible);
  end
end
