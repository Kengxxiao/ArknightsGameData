local Ease = CS.DG.Tweening.Ease





















local BlessOnlyPacketView = Class("BlessOnlyPacketView", UIPanel);

BlessOnlyPacketView.HIDE_ALPHA = 0;
BlessOnlyPacketView.HIDE_DURATION = 0.16;

function BlessOnlyPacketView:OnInit()
  self:AddButtonClickListener(self._openPacketBtn, self._ShowOpenPacket);
  self:AddButtonClickListener(self._closeBtn, self._OnClosePacketPanel);
  self:AddButtonClickListener(self._fullScreenBtn, self._OnClosePacketPanel);
  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._closeBtn);
  self.m_isShow = false;
  SetGameObjectActive(self._selfObject, false);
end


function BlessOnlyPacketView:OnViewModelUpdate(data)
  if data == nil then
    return;
  end
  self.m_actId = data:GetActId();
  local isCurShow = data.panelState == BlessOnlyPanelState.PACKET and not(data.isBlessListState);
  if (isCurShow ~= self.m_isShow or data.isContinueOpenPacket) and not(data.isBlessListState) then
    if isCurShow or data.isContinueOpenPacket then
      self:_ShowEntryPacket();
    else
      self:_HidePacket();
    end
    self.m_isShow = isCurShow;
  end

  if data.panelState ~= BlessOnlyPanelState.PACKET and not(data.isBlessListState)then
    return;
  end
  self._festivalNameImage:SetSprite(self._atlasObject:GetSpriteByName(data.openPacketModel.fesTitleText));
end

function BlessOnlyPacketView:_ShowEntryPacket()
  if self.m_entryTween ~= nil and self.m_entryTween:IsPlaying() then
    self.m_entryTween:Kill();
    self.m_entryTween = nil;
  end
  self._animWrapper:InitIfNot();
  SetGameObjectActive(self._selfObject, true);
  self._animWrapper:SampleClipAtBegin(self._entryAnimName);
  self.m_entryTween = self._animWrapper:PlayWithTween(self._entryAnimName):SetEase(Ease.Linear):OnComplete(function()
    self:_PlayLoopAnim();
  end);
  local audio = CS.Torappu.Lua.Util.Format(AudioConsts.BLESSONLY_PACKET_ENTRY, string.upper(self.m_actId));
  CS.Torappu.TorappuAudio.PlayUI(audio);
end

function BlessOnlyPacketView:_HidePacket()
  if self.m_hideTween ~= nil and self.m_hideTween:IsPlaying() then
    self.m_hideTween:Kill();
    self.m_hideTween = nil;
  end
  self.m_hideTween = self._canvasGroup:DOFade(self.HIDE_ALPHA, self.HIDE_DURATION):OnComplete(function()
    SetGameObjectActive(self._selfObject, false);
    self._canvasGroup.alpha = 1;
  end);
end

function BlessOnlyPacketView:_PlayLoopAnim()
  if self._loopAnimName == nil or self._loopAnimName == "" then
    return;
  end
  if self.m_loopTween ~= nil and self.m_loopTween:IsPlaying() then
    return;
  end
  self._animWrapper:SampleClipAtBegin(self._loopAnimName);
  self.m_loopTween = self._animWrapper:PlayWithTween(self._loopAnimName):SetEase(Ease.Linear):SetLoops(-1);
end

function BlessOnlyPacketView:_ShowOpenPacket()
  if self.m_entryTween ~= nil and self.m_entryTween:IsPlaying() then
    return;
  end
  if self.m_openPacketTween ~= nil and self.m_openPacketTween:IsPlaying() then
    return;
  end
  self._animWrapper:InitIfNot();
  self._animWrapper:SampleClipAtBegin(self._openPacketAnimName);
  self.m_openPacketTween = self._animWrapper:PlayWithTween(self._openPacketAnimName):SetEase(Ease.Linear):OnComplete(function()
    self:_OnClickOpenPacketReward();
  end);
  local audio = CS.Torappu.Lua.Util.Format(AudioConsts.BLESSONLY_OPEN_PACKET, string.upper(self.m_actId));
  CS.Torappu.TorappuAudio.PlayUI(audio);
end

function BlessOnlyPacketView:_OnClickOpenPacketReward()
  if self.onClickOpenPacketReward == nil then
    return;
  end
  Event.Call(self.onClickOpenPacketReward);
end

function BlessOnlyPacketView:_OnClosePacketPanel()
  if self.onClosePacketPanel == nil then
    return;
  end
  Event.Call(self.onClosePacketPanel);
end

return BlessOnlyPacketView;