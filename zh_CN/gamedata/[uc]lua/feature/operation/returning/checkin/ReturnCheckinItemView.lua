local UICommonItemCard = require("Feature/Supportor/UI/UICommonItemCard")






















local ReturnCheckinItemView = Class("ReturnCheckinItemView", UIPanel)

ReturnCheckinItemView.ITEM_SCALE = 0.55
ReturnCheckinItemView.REWARD_COUNT = 2




function ReturnCheckinItemView:Render(luaIndex, itemModel, onItemClick)
  self.m_itemModel = itemModel;
  self.onItemClick = onItemClick;
  self:_InitIfNot();

  self._numText.text = tostring(luaIndex);

  SetGameObjectActive(self._maskCollected, itemModel.state == ReturnCheckinItemState.CONFIRMED);
  SetGameObjectActive(self._panelAvail, itemModel.state ~= ReturnCheckinItemState.UNCOMPLETE);
  SetGameObjectActive(self._decoAvail, itemModel.state == ReturnCheckinItemState.COMPLETE);

  local isGold = itemModel:IsKeyItem();
  SetGameObjectActive(self. _bgNotCollected, not isGold);
  SetGameObjectActive(self. _bgNotCollectedGold, isGold);
  SetGameObjectActive(self. _bgAvail, not isGold);
  SetGameObjectActive(self. _bgAvailGold, isGold);

  SetGameObjectActive(self._shinningNormal, not isGold);
  SetGameObjectActive(self._shinningGold, isGold);
  SetGameObjectActive(self._bkgTextNormal, not isGold);
  SetGameObjectActive(self._bkgTextGold, isGold);

  self.m_rewardListAdapter:NotifyDataSetChanged();
end


function ReturnCheckinItemView:_InitIfNot()
  if self.m_hasInited then
    return;
  end
  self.m_hasInited = true;

  self.m_rewardListAdapter = self:CreateCustomComponent(
      UISimpleLayoutAdapter, self, self._rewardItemList, self._CreateRewardItemView,
      self._GetItemCount, self._UpdateRewardItemView);
  self:AddButtonClickListener(self._btnGain, self.OnItemClicked);
end



function ReturnCheckinItemView:_CreateRewardItemView(gameObj)
  local itemView = self:CreateWidgetByGO(UICommonItemCard, gameObj);
  return itemView;
end




function ReturnCheckinItemView:_UpdateRewardItemView(index, itemView)
  local rewardList = self.m_itemModel:GetRewardList()
  itemView:Render(rewardList[index], {
    itemScale = self.ITEM_SCALE,
    isCardClickable = true,
    showItemName = false,
    showItemNum = true,
    showBackground = true
  });
end


function ReturnCheckinItemView:_GetItemCount()
  return self.REWARD_COUNT;
end

function ReturnCheckinItemView:OnItemClicked()
  if self.onItemClick ~= nil and self.m_itemModel ~= nil then
    self.onItemClick:Call(self.m_itemModel.index);
  end
end

return ReturnCheckinItemView;