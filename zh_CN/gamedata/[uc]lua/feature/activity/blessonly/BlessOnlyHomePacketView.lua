



















local BlessOnlyHomePacketView = Class("BlessOnlyHomePacketView", UIPanel);

function BlessOnlyHomePacketView:OnInit()
  self:AddButtonClickListener(self._receivePacketBtn, self._OnClickReceivePacket);
  self:AddButtonClickListener(self._checkBlessListBtn, self._OnClickCheckBlessList);
  self.m_fesOrderInt = tonumber(self._fesOrder);
end


function BlessOnlyHomePacketView:Render(data)
  if data == nil then
    return;
  end

  local viewModel = data:GetPacketByOrder(self.m_fesOrderInt);
  if viewModel == nil then
    return;
  end

  SetGameObjectActive(self._disablePanel, viewModel.checkInState == BlessOnlyCheckInState.DISABLE);
  SetGameObjectActive(self._availPanel, viewModel.checkInState == BlessOnlyCheckInState.AVAIL);
  SetGameObjectActive(self._receivedPanel, viewModel.checkInState == BlessOnlyCheckInState.RECEIVED);
  
  if viewModel.checkInState == BlessOnlyCheckInState.DISABLE then
    self:_RenderDisablePanel(viewModel); 
  elseif viewModel.checkInState == BlessOnlyCheckInState.AVAIL then
    self:_RenderAvailPanel();
  elseif viewModel.checkInState == BlessOnlyCheckInState.RECEIVED then
    self:_RenderReceivedPanel(viewModel); 
  end
end


function BlessOnlyHomePacketView:_RenderDisablePanel(viewModel)
  self._diamondImage.color = CS.Torappu.ColorRes.TweenHtmlStringToColor(self._disableColor);
  if viewModel.isOverTime then
    self._disableText.text = viewModel.overTimeTips;
  else
    self._disableText.text = viewModel.adTips;
  end
end

function BlessOnlyHomePacketView:_RenderAvailPanel()
  self._diamondImage.color = CS.Torappu.ColorRes.TweenHtmlStringToColor(self._availColor);
end


function BlessOnlyHomePacketView:_RenderReceivedPanel(viewModel)
  self._diamondImage.color = CS.Torappu.ColorRes.TweenHtmlStringToColor(self._receivedColor);
  local hubPath = CS.Torappu.ResourceUrls.GetCharAvatarHubPath();
  self._blessCharIcon.sprite = self:LoadSpriteFromAutoPackHub(hubPath, viewModel.defaultFesCharAvatarId);
  self._blessRewardCnt.text = CS.Torappu.Lua.Util.Format(StringRes.BLESSONLY_REWARD_CNT_DISPLAY, viewModel.diamondRewardCnt);
  self._blessBlackBgText:SetSprite(self._atlasObject:GetSpriteByName(viewModel.fesBlessingText1))
  self._blessWhiteBgText:SetSprite(self._atlasObject:GetSpriteByName(viewModel.fesBlessingText2));
end

function BlessOnlyHomePacketView:_OnClickReceivePacket()
  if self.onClickHomeReceivePacketBtn == nil then
    return;
  end
  Event.Call(self.onClickHomeReceivePacketBtn, self.m_fesOrderInt);
end

function BlessOnlyHomePacketView:_OnClickCheckBlessList()
  if CS.Torappu.FastActionDetector.IsFastAction() then
    return;
  end
  if self.onClickHomeCheckBlessBtn == nil then
    return;
  end
  Event.Call(self.onClickHomeCheckBlessBtn, self.m_fesOrderInt);
end



function BlessOnlyHomePacketView:SetEventForBtn(onClickHomeReceivePacketBtn, onClickHomeCheckBlessBtn)
  self.onClickHomeReceivePacketBtn = onClickHomeReceivePacketBtn;
  self.onClickHomeCheckBlessBtn = onClickHomeCheckBlessBtn;
end

return BlessOnlyHomePacketView;