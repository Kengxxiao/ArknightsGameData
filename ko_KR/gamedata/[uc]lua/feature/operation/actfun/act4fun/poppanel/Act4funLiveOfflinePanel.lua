



local Act4funLiveOfflinePanel = Class("Act4funLiveOfflinePanel", Act4funLivePopPanelBase);
Act4funLiveOfflinePanel.ENTRY_ANIM = "act4fun_live_offline_entry";
Act4funLiveOfflinePanel.LOOP_ANIM = "act4fun_live_offline_loop";


function Act4funLiveOfflinePanel:OnInit()
  self:AddButtonClickListener(self._btnBg, self._EndLive);
end



function Act4funLiveOfflinePanel:OnViewModelUpdate(data)
  local valid = data.currStep == Act4funLiveStep.OFFLINE;
  self:SetVisible(valid);
  if not valid then
    return;
  end
  CS.Torappu.TorappuAudio.PlayUI(AudioConsts.ACT4FUN_LIVELOADING);

  self._anim:InitIfNot();
  self._anim:Stop(self.ENTRY_ANIM, false);
  self._anim:Play(self.ENTRY_ANIM);

  self._loopAnim:InitIfNot();
  self._loopAnim:Stop(self.LOOP_ANIM, false);
  self._loopAnim:Play(self.LOOP_ANIM);
end

function Act4funLiveOfflinePanel:_EndLive()
  self.m_owner:Close();
end

return Act4funLiveOfflinePanel;