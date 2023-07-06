









ReturnV2WelcomeDlg = DlgMgr.DefineDialog("ReturnV2WelcomeDlg", "Operation/ReturnV2/return_v2_welcome_dlg");

function ReturnV2WelcomeDlg:OnInit()
  local gotReward = ReturnV2Model.me:HasOnceRewardGot()
  SetGameObjectActive(self._startNode, not gotReward);
  SetGameObjectActive(self._gotNode, gotReward);
  SetGameObjectActive(self._gotMask, gotReward);
  self:AddButtonClickListener(self._btnStart, self._EventOnStart);
  self:AddButtonClickListener(self._btnRewards, self._EventOnShowRewards);

  if gotReward then
    CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._closeBtn);
  else
    CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnStart);
  end

  self._btnAnim:Play(self._animButtonLoop);
end

function ReturnV2WelcomeDlg:OnClose()
end

function ReturnV2WelcomeDlg:OnVisible(v)
  if v then
    self._btnAnim:Play(self._animButtonLoop);
  end
end


function ReturnV2WelcomeDlg:_EventOnShowRewards()
  
  local dlg = self:GetGroup():AddChildDlg(ReturnV2RewardsDlg);
  dlg:Flush(StringRes.RETURN_ONCE_REWARDS_TITLE, ReturnV2Model.me:GetOnceRewardItemList());
end


function ReturnV2WelcomeDlg:_EventOnStart()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  if not ReturnV2Model.me:HasOnceReward() then
    return;
  end

  local startTime = CS.UnityEngine.Time.time;
  self._btnAnim:Play(self._animButtonClick);
  UISender.me:SendRequest(ReturnV2ServiceCode.GET_DISPOSABLE_REWARD,
  {
  }, 
  {
    onProceed = Event.Create(self, self._GetResponse, startTime)
  });
end 

function ReturnV2WelcomeDlg:_GetResponse(response, startTime)
  local animLength = 0.5;
  local anim = self._btnAnim:GetClipHandler(self._animButtonClick);
  if anim then
    animLength = anim:GetClipLength();
  end
  local waitTime = animLength * 0.8;

  local cost = CS.UnityEngine.Time.time - startTime;
  if cost >= waitTime then
    self:_HandleResponse(response.items);
  else
    local blocker = CS.Torappu.UI.UIPopupWindow.BlockRaycast();
    self:Delay(waitTime - cost, self._HandleResponse, response.items, blocker);
  end
end

function ReturnV2WelcomeDlg:_HandleResponse(items, blocker)
  if blocker then
    blocker:Release();
  end
  
  local this = self;
  local handler = CS.Torappu.UI.LuaUIMisc.ShowGainedItems(items, CS.Torappu.UI.UIGainItemFloatPanel.Style.DEFAULT, function()
    this:Close();
  end);
  self:_AddDisposableObj(handler);
end
