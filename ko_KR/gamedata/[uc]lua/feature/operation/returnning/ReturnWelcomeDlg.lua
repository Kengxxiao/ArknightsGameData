







ReturnWelcomeDlg = DlgMgr.DefineDialog("ReturnWelcomeDlg", "Operation/Returnning/return_welcome_dlg");
ReturnWelcomeDlg.BUTTON_LOOP_ANIM = "welcome_btn_loop";
ReturnWelcomeDlg.BUTTON_CLICK_ANIM = "welcome_btn_click";

function ReturnWelcomeDlg:OnInit()
  local currentData = CS.Torappu.PlayerData.instance.data.backflow.current;
  local gotReward = currentData and currentData.reward;
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

  self._btnAnim:Play(self.BUTTON_LOOP_ANIM);
end

function ReturnWelcomeDlg:OnClose()
end

function ReturnWelcomeDlg:OnVisible(v)
  if v then
    self._btnAnim:Play(self.BUTTON_LOOP_ANIM);
  end
end


function ReturnWelcomeDlg:_EventOnShowRewards()
  
  local dlg = self:GetGroup():AddChildDlg(ReturnRewardsDlg);
  dlg:Flush(CS.Torappu.StringRes.RETURN_ONCE_REWARDS_TITLE, CS.Torappu.OpenServerDB.returnData.onceRewards);
end


function ReturnWelcomeDlg:_EventOnStart()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  if not ReturnModel.me:HasOnceReward() then
    return;
  end

  local startTime = CS.UnityEngine.Time.time;
  self._btnAnim:Play(self.BUTTON_CLICK_ANIM);
  UISender.me:SendRequest(ReturnServiceCode.GET_DISPOSABLE_REWARD,
  {
  }, 
  {
    onProceed = Event.Create(self, self._GetResponse, startTime)
  });
end 

function ReturnWelcomeDlg:_GetResponse(response, startTime)
  local animLength = 0.5;
  local anim = self._btnAnim:GetClipHandler(self.BUTTON_CLICK_ANIM);
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

function ReturnWelcomeDlg:_HandleResponse(items, blocker)
  if blocker then
    blocker:Release();
  end
  
  local this = self;
  local handler = CS.Torappu.UI.LuaUIMisc.ShowGainedItems(items, CS.Torappu.UI.UIGainItemFloatPanel.Style.DEFAULT,
  function()
    ReturnModel.me:ShowGuide(true);
    this:Close();
  end);
  self:_AddDisposableObj(handler);
end
