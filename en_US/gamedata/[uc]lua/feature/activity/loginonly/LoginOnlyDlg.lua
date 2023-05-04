



LoginOnlyDlg = Class("LoginOnlyDlg", DlgBase);

function LoginOnlyDlg:OnInit()
  self.m_activityId = self.m_parent:GetData("actId");
  
  if self._buttonBackScreen ~= nil then
    self:AddButtonClickListener(self._buttonBackScreen, self._HandleSysClose);
  end
  self:AddButtonClickListener(self._buttonGetReward, self._HandleGetReward);

  self:_RefreshUI();
end

function LoginOnlyDlg:_RefreshUI()
  self._buttonGetReward.interactable = false;

  local suc, basicData = CS.Torappu.ActivityDB.data.basicInfo:TryGetValue(self.m_activityId);
  if not suc then
    return;
  end

  local suc, actData = CS.Torappu.ActivityDB.data.activity.defaultLoginData:TryGetValue(self.m_activityId);
  if not suc then
    return;
  end
  
  local suc, playerActData = CS.Torappu.PlayerData.instance.data.activity.loginOnlyActivityList:TryGetValue(self.m_activityId);
  if not suc then
    return;
  end

  local endTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(basicData.endTime);
  local hasReward = playerActData.reward > 0;

  self._textDesc.text = CS.Torappu.FormatUtil.FormatRichTextFromData(actData.description);
  self._textTime.text = CS.Torappu.Lua.Util.Format(
    CS.Torappu.StringRes.DATE_FORMAT_YYYY_MM_DD_HH_MM,
    endTime.Year, 
    endTime.Month, 
    endTime.Day, 
    endTime.Hour, 
    endTime.Minute
  );
  self._buttonGetReward.interactable = hasReward;
  self._imageGetRewardOutline:SetActive(hasReward);
  self._textGetReward:SetActive(hasReward);
  self._textRewardGot:SetActive(not hasReward);
  
  local titleEndTime = self._titleEndTime;
  if titleEndTime ~= nil then
    titleEndTime.text = StringRes.ACTLOGIN_END_TIME_TITLE
  end

  self:_CreateItems();
end

function LoginOnlyDlg:_CreateItems()
  
  if (self.m_itemList ~= nil) then
    return;
  end

  local suc, actData = CS.Torappu.ActivityDB.data.activity.defaultLoginData:TryGetValue(self.m_activityId);
  if not suc then
    return;
  end
  
  self.m_itemList = {};

  local items = ToLuaArray(actData.itemList);
  for idx = 1, #items do
    local item = items[idx];
    local viewModel = CS.Torappu.UI.UIItemViewModel();
    local prefab = CS.Torappu.UI.UIAssetLoader.instance.itemCardPrefab;
    local itemContainer = self:_PickItemContainer(idx);
    local itemCard = CS.UnityEngine.GameObject.Instantiate(prefab, itemContainer);

    viewModel:LoadGameData(item.id, item.type);
    viewModel.itemCount = item.count;
    itemCard:Render(idx, viewModel);
    itemCard.isCardClickable = true;
    itemCard.showItemNum = true;
    self:AsignDelegate(itemCard, "onItemClick", self._HandleItemClicked);
    local scaler = itemCard:GetComponent("Torappu.UI.UIScaler");
    if scaler then
      scaler.scale = LoginOnlyConst.ITEM_CARD_SCALE;
    end

    table.insert(self.m_itemList, itemCard);
  end
end



function LoginOnlyDlg:_PickItemContainer(index)
  if (self.m_itemContainerList == nil) then
    local rectTransList = self._panelItemContainers:GetComponentsInChildren(typeof(CS.UnityEngine.RectTransform));
    self.m_itemContainerList = {};

    
    for i = 1, rectTransList.Length - 1 do
      table.insert(self.m_itemContainerList, rectTransList[i]);
    end
  end

  if (#self.m_itemContainerList == 0) then
    return nil
  end

  
  local containerIndex = (index - 1) % #self.m_itemContainerList + 1;
  return self.m_itemContainerList[containerIndex];
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