local luaUtils = CS.Torappu.Lua.Util;









local Act4funLiveEndPanel = Class("Act4funLiveEndPanel", Act4funLivePopPanelBase);
Act4funLiveEndPanel.BREAK_ENTRY = "act4fun_live_warning_entry";
Act4funLiveEndPanel.SUCC_ENTRY = "act4fun_live_end_entry";
Act4funLiveEndPanel.SUCC_LOOP = "act4fun_live_end_loop";


function Act4funLiveEndPanel:OnInit()
  self:AddButtonClickListener(self._btnBg, self._EndLive);
end



function Act4funLiveEndPanel:OnViewModelUpdate(data)
  local currStep = data.currStep;
  local v = currStep == Act4funLiveStep.REQ_LIVE_END or currStep == Act4funLiveStep.LIVE_END;
  self:SetVisible(v);
  if not v then
    return;
  end

  if currStep == Act4funLiveStep.REQ_LIVE_END and not self.m_requesting then
    SetGameObjectActive(self._succNode, false);
    SetGameObjectActive(self._breakNode, false);
    if not self.m_requesting then
      self.m_owner:ReqLiveEnd();
    end
    return;
  end

  if currStep == Act4funLiveStep.LIVE_END then
    if not data.liveEnding then
      return;
    end
    local isGood = data.liveEnding.isGoodEnding;
    SetGameObjectActive(self._succNode, isGood);
    SetGameObjectActive(self._breakNode, not isGood);
    self._anim:InitIfNot();
    self._anim:Stop(self.SUCC_ENTRY, false);
    self._anim:Stop(self.BREAK_ENTRY, false);
    self._textAnim:InitIfNot();
    self._textAnim:Stop(self.SUCC_LOOP, false);

    if isGood then
      self._anim:Play(self.SUCC_ENTRY);
      self._textAnim:Play(self.SUCC_LOOP);
      CS.Torappu.TorappuAudio.PlayUI(AudioConsts.ACT4FUN_LIVELOADING);
    else
      self._anim:Play(self.BREAK_ENTRY);
      self._breakEndLabel.text = data.liveEnding.endingDesc;
      CS.Torappu.TorappuAudio.PlayUI(AudioConsts.ACT4FUN_END_FAILED);
    end
  end
end

function Act4funLiveEndPanel:_EndLive()
  
  local avg = self.m_cachedData.liveEnding.endingAvg;
  luaUtils.PlayAvgBackWithMusic(avg)
  self.m_owner:Close();
end

return Act4funLiveEndPanel;