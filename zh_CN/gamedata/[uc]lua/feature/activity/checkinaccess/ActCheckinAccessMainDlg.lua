local luaUtils = CS.Torappu.Lua.Util;
ActCheckinAccessMainDlg = Class("ActCheckinAccessMainDlg", DlgBase)
ActCheckinAccessMainDlg.ServiceCode = "/activity/actCheckinAccess/getCheckInReward"












function ActCheckinAccessMainDlg:OnInit()
  
  local actId = self.m_parent:GetData("actId")
  self.m_actId = actId
  self.m_times = 0
  self:_InitFromGameData(actId)
  self:AddButtonClickListener(self._btnCheckin, self.EventOnCheckin)
end

function ActCheckinAccessMainDlg:EventOnCheckin()
  
  UISender.me:SendRequest(ActCheckinAccessMainDlg.ServiceCode, 
    {
      activityId = self.m_actId;
    }, 
    {
      onProceed = Event.Create(self, self._OnHandleWork);
    });
end

function ActCheckinAccessMainDlg:_OnHandleWork(resp)
  
  local handler = CS.Torappu.UI.LuaUIMisc.ShowGainedItems(resp.items, CS.Torappu.UI.UIGainItemFloatPanel.Style.DEFAULT, function()
      self:_RefreshPlayerDataState()
    end);
  self:_AddDisposableObj(handler);  
end

function ActCheckinAccessMainDlg:_RefreshPlayerDataState()
  
  local suc, playerData = CS.Torappu.PlayerData.instance.data.activity.checkinAccessList:TryGetValue(self.m_actId);
  if (suc) then
  	local canReach = playerData.currentStatus == 1
    CS.Torappu.Lua.Util.SetActiveIfNecessary(self._ableToGetPart, canReach)
    CS.Torappu.Lua.Util.SetActiveIfNecessary(self._alreadyCheckInPart, not canReach and playerData.rewardsCount <self.m_times)
    CS.Torappu.Lua.Util.SetActiveIfNecessary(self._allFinishPart, not canReach and playerData.rewardsCount >= self.m_times)
    self._alreadyTimesText.text = CS.Torappu.Lua.Util.Format(StringRes.ACT_ACCESS_TIMES,  playerData.rewardsCount);
    if canReach then
      self._itemCanvasGroup.alpha = 1
    else
      self._itemCanvasGroup.alpha = 0.3
    end
  end
end

function ActCheckinAccessMainDlg:_InitFromGameData(actId)
  self.m_actId = actId
  self:AddButtonClickListener(self._btnClose, self._OnClickCloseBtn);
  self:AddButtonClickListener(self._btnClose2, self._OnClickCloseBtn);
  local dynActs = CS.Torappu.ActivityDB.data.dynActs;
  if actId == nil or dynActs == nil then
    return
  end
  local suc, jObject = dynActs:TryGetValue(actId)
  if not suc then
    luaUtils.LogError("Activity not found in dynActs : "..actId)
    return
  end
  local data = luaUtils.ConvertJObjectToLuaTable(jObject)
  self.m_times = data.dayCount
  self._apSupplyTime.text = "";
  if data.apSupplyOutOfDateDict then
    for apid, endtime in pairs(data.apSupplyOutOfDateDict) do
      local apItemData = CS.Torappu.UI.UIItemViewModel();
      apItemData:LoadGameData(apid, CS.Torappu.ItemType.NONE);
      local dateTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(endtime);
      local timedesc = CS.Torappu.Lua.Util.Format(CS.Torappu.StringRes.DATE_FORMAT_YYYY_MM_DD_HH_MM,dateTime.Year, dateTime.Month, dateTime.Day,dateTime.Hour,dateTime.Minute);
      local str = CS.Torappu.StringRes.ACT4D0_AP_REMAIN;
      self._apSupplyTime.text = CS.Torappu.Lua.Util.Format(str, apItemData.name, timedesc);
      break;
    end
  end

  local suc, basicData = CS.Torappu.ActivityDB.data.basicInfo:TryGetValue(self.m_actId)
  if not suc then 
    return;
  end
  local endTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(basicData.endTime)
  self._textTime.text = CS.Torappu.Lua.Util.Format(
    StringRes.ACT_ACCESS_TIME,
    endTime.Year, 
    endTime.Month, 
    endTime.Day, 
    endTime.Hour, 
    endTime.Minute
  );
  local prefab = CS.Torappu.UI.UIAssetLoader.instance.itemCardPrefab;
  local str = ""
  for idx = 1, #data.rewardItemPerDay do
    local itemCard = CS.UnityEngine.GameObject.Instantiate(prefab, self._itemHolder);  
    local viewModel = CS.Torappu.UI.UIItemViewModel();
    local prefab = CS.Torappu.UI.UIAssetLoader.instance.itemCardPrefab;
    local item = data.rewardItemPerDay[idx]

    viewModel:LoadGameData(item.id, item.type);
    viewModel.itemCount = item.count;
    itemCard:Render(idx, viewModel);  
    itemCard.showItemNum = true;
    itemCard.isCardClickable = true;
    if (idx > 1) then
      str = str  .. CS.Torappu.StringRes.SP_CHAR_NAME_SEPARATOR
    end
    str = str  .. viewModel.name  .. "*" .. tostring(viewModel.itemCount)
    self:AsignDelegate(itemCard, "onItemClick", function(this, index)
      CS.Torappu.UI.UIItemDescFloatController.ShowItemDesc(itemCard.gameObject, viewModel);
    end);
    local scaler = itemCard:GetComponent("Torappu.UI.UIScaler");
    if scaler then
      scaler.scale = 0.6;
    end
  end
  self._dailyText.text = CS.Torappu.Lua.Util.Format(StringRes.ACT_ACCESS_REWARD_ITEM_TWO_ITEM,str)
  self:_RefreshPlayerDataState()
end

function ActCheckinAccessMainDlg:_OnClickCloseBtn()
  self:Close();
end