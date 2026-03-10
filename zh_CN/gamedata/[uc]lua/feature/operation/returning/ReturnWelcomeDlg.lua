local Ease = CS.DG.Tweening.Ease




















ReturnWelcomeDlg = DlgMgr.DefineDialog("ReturnWelcomeDlg", "Operation/[UC]Returning/ReturnWelcome/return_welcome_dlg");

function ReturnWelcomeDlg:OnInit()
  local gotReward = ReturnModel.me:HasOnceRewardGot();

  self:AddButtonClickListener(self._btnReceive, self._EventOnGetReward);
  self:AddButtonClickListener(self._btnDetail, self._EventOnDetailClicked);
  if(gotReward) then
    self:AddButtonClickListener(self._btnBackPress, function ()
      self:Close();
    end);
    CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnBackPress);
  end

  self._animWrapper:InitIfNot();
  if self.m_switchBlessSequence ~= nil and self.m_switchBlessSequence:IsPlaying() then
    self.m_switchBlessSequence:Kill();
  end

  local openLevelHigh = ReturnModel.me:GetReturnOpenLevel();

  SetGameObjectActive(self._imgOpenLevel1, not openLevelHigh);
  SetGameObjectActive(self._imgOpenLevel2, openLevelHigh);
  SetGameObjectActive(self._objReceived, gotReward);
  SetGameObjectActive(self._imgBtnReceive, not gotReward);
  SetGameObjectActive(self._imgBtnReceived, gotReward);
  if gotReward then
    self:_ShowSecondTimeEffect();
  else
    self:_ShowFirstTimeEffect();
  end
end


function ReturnWelcomeDlg:_ShowFirstTimeEffect()
  self._textAmiyaWords.text = CS.Torappu.Lua.Util.Format(I18NTextRes.COMMON_RETURN_WELCOME_MESSAGE, CS.Torappu.PlayerData.instance.data.status.nickName);
  self._animWrapper:SampleClipAtBegin(self._animStage1);
  self.m_switchBlessSequence = CS.DG.Tweening.DOTween.Sequence();
  self.m_switchBlessSequence:Append(self._animWrapper:PlayWithTween(self._animStage1, nil, true):SetEase(Ease.Linear));
  self.m_switchBlessSequence:AppendCallback(function()
    self._animWrapper:SampleClipAtBegin(self._animStage2);
  end);
  self.m_switchBlessSequence:Append(self._animWrapper:PlayWithTween(self._animStage2, nil, true):SetEase(Ease.Linear));
end


function ReturnWelcomeDlg:_ShowSecondTimeEffect()
  self._animWrapper:SampleClipAtBegin(self._animSecondIn);
  self.m_switchBlessSequence = CS.DG.Tweening.DOTween.Sequence();
  self.m_switchBlessSequence:Append(self._animWrapper:PlayWithTween(self._animSecondIn, nil, true):SetEase(Ease.Linear));
end


function ReturnWelcomeDlg:_EventOnDetailClicked()
  
  local dlg = self:GetGroup():AddChildDlg(ReturnWelcomeRewardDetailDlg);
  dlg:Flush(ReturnModel:GetOnceRewardItemList());
end

function ReturnWelcomeDlg:_EventOnGetReward()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  if ReturnModel.me:HasOnceReward() then
    UISender.me:SendRequest(ReturnServiceCode.GET_DISPOSABLE_REWARD,
    {
    },
    {
      onProceed = Event.Create(self, self._HandleGotRewardResponse),
    });
  end
  if ReturnModel.me:HasOnceRewardGot() then
    if self.m_switchBlessSequence ~= nil and self.m_switchBlessSequence:IsPlaying() then
      self.m_switchBlessSequence:Kill();
    end
    self._animWrapper:SampleClipAtBegin(self._animSecondOut);
    self.m_switchBlessSequence = CS.DG.Tweening.DOTween.Sequence();
    self.m_switchBlessSequence:Append(self._animWrapper:PlayWithTween(self._animSecondOut, nil, true):SetEase(Ease.Linear));
    self.m_switchBlessSequence:AppendCallback(function()
      self:Close();
    end);
  end
end


function ReturnWelcomeDlg:_HandleGotRewardResponse(response)
  if self.m_switchBlessSequence ~= nil and self.m_switchBlessSequence:IsPlaying() then
    self.m_switchBlessSequence:Kill();
  end
  self._animWrapper:SampleClipAtBegin(self._animStage3);
  self.m_switchBlessSequence = CS.DG.Tweening.DOTween.Sequence();
  self.m_switchBlessSequence:Append(self._animWrapper:PlayWithTween(self._animStage3, nil, true):SetEase(Ease.Linear));
  self.m_switchBlessSequence:AppendCallback(function()
    self:_ShowGainItems(response.items);
  end);
end



function ReturnWelcomeDlg:_ShowGainItems(items)
  local handler = CS.Torappu.UI.LuaUIMisc.ShowGainedItems(items,
    CS.Torappu.UI.UIGainItemFloatPanel.Style.DEFAULT,
    function()
      self:_End()
    end
  );
  self:_AddDisposableObj(handler);
end

function ReturnWelcomeDlg:_End()
  if self.m_switchBlessSequence ~= nil and self.m_switchBlessSequence:IsPlaying() then
    self.m_switchBlessSequence:Kill();
  end
  self._animWrapper:SampleClipAtBegin(self._animStage4);
  self.m_switchBlessSequence = CS.DG.Tweening.DOTween.Sequence();
  self.m_switchBlessSequence:Append(self._animWrapper:PlayWithTween(self._animStage4, nil, true):SetEase(Ease.Linear));
  self.m_switchBlessSequence:AppendCallback(function()
    self:Close();
  end);
end