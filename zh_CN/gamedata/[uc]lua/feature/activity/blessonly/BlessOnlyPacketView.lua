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
  self.m_entryTween = self._animWrapper:PlayWithTween(self._entryAnimName):SetEase(Ease.Linear);
  CS.Torappu.TorappuAudio.PlayUI(AudioConsts.ACT1BLESSING_PACKET_ENTRY);
end

function BlessOnlyPacketView:_HidePacket()
  if self.m_hideTween ~= nil and self.m_hideTween:IsPlaying() then
    self.m_hideTween:Kill();
    self.m_hideTween = nil;
  end
  self.m_hideTween = self._canvasGroup:DOFade(self.HIDE_ALPHA, self.HIDE_DURATION):OnComplete(function()
    SetGameObjectActive(self._selfObject, false);
  end);
end

function BlessOnlyPacketView:_ShowOpenPacket()
  if self.m_entryTween ~= nil and self.m_entryTween:IsPlaying() then
    return;
  end
  if self.m_openPacketTween ~= nil and self.m_openPacketTween:IsPlaying() then
    self.m_openPacketTween:Kill();
    self.m_openPacketTween = nil;
  end
  self._animWrapper:InitIfNot();
  self._animWrapper:SampleClipAtBegin(self._openPacketAnimName);
  self.m_openPacketTween = self._animWrapper:PlayWithTween(self._openPacketAnimName):SetEase(Ease.Linear):OnComplete(function()
    self:_OnClickOpenPacketReward();
  end);
  CS.Torappu.TorappuAudio.PlayUI(AudioConsts.ACT1BLESSING_OPEN_PACKET);
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