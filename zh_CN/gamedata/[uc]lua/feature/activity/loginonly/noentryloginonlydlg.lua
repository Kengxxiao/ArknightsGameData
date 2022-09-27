















NoEntryLoginOnlyDlg = DlgMgr.DefineDialog("NoEntryLoginOnlyDlg", nil, LoginOnlyDlg);

function NoEntryLoginOnlyDlg:OnInit()
  self.m_activityId = self.m_parent:GetData("actId");

  self:AddButtonClickListener(self._btnGetReward, self._HandleGetReward);
  self:AddButtonClickListener(self._btnClose, self._HandleSysClose);
  self:_RefreshUI();
  self:_BindDismissControl();
end

function LoginOnlyDlg:_BindDismissControl()
  local bridge = self.m_parent:GetCompLuaBinder(CS.Torappu.Lua.LuaActivityEntry.KEY_DISMISS_CONTROL);
  if bridge == nil then
    return;
  end
  bridge:Bind({
    TryDismiss = function()
      return self.m_hasReward ~= nil and self.m_hasReward;
    end
  })
end

function NoEntryLoginOnlyDlg:_RefreshUI()
  self._btnGetReward.interactable = false;

  local showItemContainer = self._showItemContainer == "true";
  
  local suc, basicData = CS.Torappu.ActivityDB.data.basicInfo:TryGetValue(self.m_activityId);
  if not suc then
    self:_HandleSysClose();
    return;
  end
  local suc, actData = CS.Torappu.ActivityDB.data.activity.defaultLoginData:TryGetValue(self.m_activityId);
  if not suc then
    self:_HandleSysClose();
    return;
  end
  local suc, playerActData = CS.Torappu.PlayerData.instance.data.activity.loginOnlyActivityList:TryGetValue(self.m_activityId);
  if not suc then
    self:_HandleSysClose();
    return;
  end

  local endTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(basicData.endTime);
  self.m_hasReward = playerActData.reward > 0;
  self._textTime.text = CS.Torappu.Lua.Util.Format(
    CS.Torappu.StringRes.DATE_FORMAT_YYYY_MM_DD_HH_MM,
    endTime.Year,
    endTime.Month,
    endTime.Day,
    endTime.Hour,
    endTime.Minute
  );
  self._btnGetReward.interactable = true;
  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._panelGetReward, self.m_hasReward);
  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._panelRewardGot, not self.m_hasReward);

  local titleEndTime = self._textTitleEndTime;
  if titleEndTime ~= nil then
    titleEndTime.text = StringRes.ACTLOGIN_END_TIME_TITLE;
  end

  if showItemContainer then
    self:_CreateItems();
  end
end

function LoginOnlyDlg:_HandleGetReward()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  
  UISender.me:SendRequest(
    LoginOnlyServiceCode.GET_REWARD,
    {
      activityId = self.m_activityId
    }, 
    {
      hideMask = true,
      onProceed = Event.Create(self, self._HandleGetRewardResponse)
    }
  );
end

function LoginOnlyDlg:_HandleGetRewardResponse(response)
  CS.Torappu.Activity.ActivityUtil.DoShowGainedItems(response.reward);
  self:_RefreshUI();
end

function LoginOnlyDlg:_HandleItemClicked(index)
  if (index <= 0 or index > #self.m_itemList) then
    return;
  end

  local itemCard = self.m_itemList[index];
  CS.Torappu.UI.UIItemDescFloatController.ShowItemDesc(itemCard.gameObject, itemCard.model);
end