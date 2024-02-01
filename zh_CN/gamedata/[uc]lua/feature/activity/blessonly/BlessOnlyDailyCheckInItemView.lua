local UICommonItemCard = require("Feature/Supportor/UI/UICommonItemCard")














local BlessOnlyDailyCheckInItemView = Class("BlessOnlyDailyCheckInItemView", UIPanel);

BlessOnlyDailyCheckInItemView.ITEM_SCALE = 0.42;

function BlessOnlyDailyCheckInItemView:OnInit()
  self:AddButtonClickListener(self._checkBtn, self._OnClickReceiveReward);
  self.m_rewardListAdapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._rewardItemList, self._CreateRewardItemView,
      self._GetRewardItemCount, self._UpdateRewardItemView)
end


function BlessOnlyDailyCheckInItemView:Render(model)
  if model == nil then
    return;
  end
  self.m_checkInModel = model;
  
  SetGameObjectActive(self._unreceivePanel, model.checkInState == BlessOnlyCheckInState.DISABLE);
  SetGameObjectActive(self._canReceivePanel, model.checkInState == BlessOnlyCheckInState.AVAIL or model.checkInState == BlessOnlyCheckInState.RECEIVED);
  SetGameObjectActive(self._receivedPanel, model.checkInState == BlessOnlyCheckInState.RECEIVED);

  self.m_checkInOrder = model.order - 1;
  self._dayNum.text = tostring(model.order);
  local color = "";
  if model.checkInState == BlessOnlyCheckInState.DISABLE then 
    color = self._unReceiveColor;
  elseif model.checkInState == BlessOnlyCheckInState.AVAIL or model.checkInState == BlessOnlyCheckInState.RECEIVED then
    color = self._canReceiveColor;
  end
  self._dayNum.color = CS.Torappu.ColorRes.TweenHtmlStringToColor(color);
  SetGameObjectActive(self._checkBtn.gameObject, model.checkInState == BlessOnlyCheckInState.AVAIL);
  
  self.m_rewardListAdapter:NotifyDataSetChanged();
end



function BlessOnlyDailyCheckInItemView:_CreateRewardItemView(gameObj)
  local itemView = self:CreateWidgetByGO(UICommonItemCard, gameObj)
  return itemView;
end


function BlessOnlyDailyCheckInItemView:_GetRewardItemCount()
  if self.m_checkInModel == nil then
    return 0
  end

  local rewardList = self.m_checkInModel.rewardList;
  if rewardList == nil then
    return 0
  end
  return #rewardList;
end




function BlessOnlyDailyCheckInItemView:_UpdateRewardItemView(index, itemView)
  if self.m_checkInModel == nil then
    return;
  end

  local rewardList = self.m_checkInModel.rewardList;
  local luaIndex = index + 1;
  if rewardList == nil or rewardList[luaIndex] == nil then
    return;
  end

  itemView:Render(rewardList[luaIndex], {
    itemScale = self.ITEM_SCALE,
    isCardClickable = true,
    showItemName = false,
    showItemNum = true,
    showBackground = true
  })
end

function BlessOnlyDailyCheckInItemView:_OnClickReceiveReward()
  if self.onClickReceiveReward == nil then
    return;
  end
  Event.Call(self.onClickReceiveReward, self.m_checkInOrder);
end

return BlessOnlyDailyCheckInItemView;