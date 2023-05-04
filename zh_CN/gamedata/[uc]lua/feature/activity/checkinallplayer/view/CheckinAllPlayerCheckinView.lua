













local CheckinAllPlayerDailyItem = Class("CheckinAllPlayerDailyItem", UIWidget);
CheckinAllPlayerDailyItem.REWARD_MAX = 2;
CheckinAllPlayerDailyItem.ITEM_CARD_SCALE = 0.4;

function CheckinAllPlayerDailyItem:OnInitialize()
  self:AddButtonClickListener(self._btn, self._HandleClick);
end


function CheckinAllPlayerDailyItem:Render(vm)
  self.m_idx = vm.dayIdx;
  local dayIdxStr = tostring(vm.dayIdx + 1);
  self._dayIdxLabel.text = dayIdxStr;
  self._cangetDayIdxLabel.text = dayIdxStr;

  local defaultState = vm.state == CheckinAllPlayerRewardStatus.NONE;
  SetGameObjectActive(self._normalNode, defaultState);
  SetGameObjectActive(self._cangetNode, not defaultState);
  SetGameObjectActive(self._cangetGlow, vm.state ~= CheckinAllPlayerRewardStatus.RECEIVED)
  SetGameObjectActive(self._maskGot, vm.state == CheckinAllPlayerRewardStatus.RECEIVED);
  if defaultState then
    local isKeyDay = vm.data.keyItem;
    SetGameObjectActive(self._defaultBg, not isKeyDay);
    SetGameObjectActive(self._keyDayDefaultBg, isKeyDay);
  end

  if not self.m_itemCards then
    self.m_itemCards = {};
    local prefab = CS.Torappu.UI.UIAssetLoader.instance.itemCardPrefab;
    for _ = 1, self.REWARD_MAX do
      local itemCard = CS.UnityEngine.GameObject.Instantiate(prefab, self._rewardRoot);
      local scaler = itemCard:GetComponent("Torappu.UI.UIScaler");
      if scaler then
        scaler.scale = self.ITEM_CARD_SCALE;
      end
      table.insert(self.m_itemCards, itemCard);
    end
  end

  local rewards = vm.data.itemList;
  local rewardCnt = rewards.Count;
  for idx, itemCard in ipairs(self.m_itemCards) do
    if idx <= rewardCnt then
      local item = rewards[idx-1];
      local viewModel = CS.Torappu.UI.UIItemViewModel();
      viewModel:LoadGameData(item.id, item.type);
      viewModel.itemCount = item.count;

      itemCard:Render(idx, viewModel);
      itemCard.showItemNum = true;
      itemCard.isCardClickable = true;
      self:AsignDelegate(itemCard, "onItemClick", function(this, index)
        CS.Torappu.UI.UIItemDescFloatController.ShowItemDesc(itemCard.gameObject, viewModel);
      end);
      SetGameObjectActive(itemCard.gameObject, true);
    else
      SetGameObjectActive(itemCard.gameObject, false);
    end
  end
  
end

function CheckinAllPlayerDailyItem:_HandleClick()
  if self.clickEvent then
    self.clickEvent:Call(self.m_idx);
  end
end









local CheckinAllPlayerCheckinView = Class("CheckinAllPlayerCheckinView", UIPanel);
CheckinAllPlayerCheckinView.MAX_VIEW_COUNT = 5;


function CheckinAllPlayerCheckinView:OnViewModelUpdate(model)
  if not self.m_adapter then
    self.m_adapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._itemListLayout, 
      self._CreateItem, self._GetItemCount, self._UpdateItem);
  end

  self.m_cachedModel = model;
  self.m_adapter:NotifyDataSetChanged();
  if model.focusDay >= self.MAX_VIEW_COUNT then
    self:StartCoroutine(self._Scroll)
  end
end

function CheckinAllPlayerCheckinView:_Scroll()
  coroutine.yield();
  self._scrollView.verticalNormalizedPosition = 0;
end



function CheckinAllPlayerCheckinView:_CreateItem(gameObj)
  local dayItem = self:CreateWidgetByGO(CheckinAllPlayerDailyItem, gameObj)
  dayItem.clickEvent = self.checkEvent;
  return dayItem;
end

function CheckinAllPlayerCheckinView:_GetItemCount()
  if self.m_cachedModel == nil or self.m_cachedModel.checkinList == nil then
    return 0;
  end
  return #self.m_cachedModel.checkinList;
end


function CheckinAllPlayerCheckinView:_UpdateItem(index, item)
  local idx = index + 1;
  item:Render(self.m_cachedModel.checkinList[idx]);
end



return CheckinAllPlayerCheckinView; 