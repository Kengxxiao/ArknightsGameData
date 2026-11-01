local UICommonItemCard = require("Feature/Supportor/UI/UICommonItemCard");

















local OpenServerV3CheckInItemView = Class("OpenServerV3CheckInItemView", UIPanel);

local ITEM_SCALE = 0.58;
local MAX_REWARD_COUNT = 2;




function OpenServerV3CheckInItemView:Render(luaIndex, itemModel, onItemClick)
  self.m_itemModel = itemModel;
  self.m_onItemClick = onItemClick;
  self:_InitIfNot();

  self._textDay.text = tostring(luaIndex);

  local state = itemModel.state;
  local isKeyItem = itemModel.isKeyItem;
  local isUncomplete = state == OpenServerV3CheckInItemState.UNCOMPLETE;
  local isComplete = state == OpenServerV3CheckInItemState.COMPLETE;
  local isConfirmed = state == OpenServerV3CheckInItemState.CONFIRMED;

  SetGameObjectActive(self._panelUncompleteNormalItem, isUncomplete and not isKeyItem);
  SetGameObjectActive(self._panelUncompleteKeyItem, isUncomplete and isKeyItem);
  SetGameObjectActive(self._panelCompleteNormalItem, isComplete and not isKeyItem);
  SetGameObjectActive(self._panelCompleteKeyItem, isComplete and isKeyItem);
  SetGameObjectActive(self._panelComplete, isComplete);
  SetGameObjectActive(self._panelCompleteGlow, isComplete);
  SetGameObjectActive(self._panelConfirmed, isConfirmed);

  self.m_rewardListAdapter:NotifyDataSetChanged();
end


function OpenServerV3CheckInItemView:_InitIfNot()
  if self.m_hasInited then
    return;
  end
  self.m_hasInited = true;

  self.m_rewardListAdapter = self:CreateCustomComponent(
      UISimpleLayoutAdapter, self, self._rewardItemList, self._CreateRewardItemView,
      self._GetRewardItemCount, self._UpdateRewardItemView);
  if self._btnGain ~= nil then
    self:AddButtonClickListener(self._btnGain, self.OnItemClicked);
  end
end



function OpenServerV3CheckInItemView:_CreateRewardItemView(gameObj)
  local itemView = self:CreateWidgetByGO(UICommonItemCard, gameObj);
  return itemView;
end


function OpenServerV3CheckInItemView:_GetRewardItemCount()
  if self.m_itemModel == nil or self.m_itemModel.rewardList == nil then
    return 0;
  end
  local count = self.m_itemModel.rewardList.Count;
  if count > MAX_REWARD_COUNT then
    return MAX_REWARD_COUNT;
  end
  return count;
end




function OpenServerV3CheckInItemView:_UpdateRewardItemView(index, itemView)
  local rewardList = self.m_itemModel.rewardList;
  if rewardList == nil then
    return;
  end
  itemView:Render(rewardList[index], {
    itemScale = ITEM_SCALE,
    isCardClickable = true,
    showItemName = false,
    showItemNum = true,
    showBackground = true,
  });
end

function OpenServerV3CheckInItemView:OnItemClicked()
  if self.m_onItemClick ~= nil and self.m_itemModel ~= nil then
    self.m_onItemClick:Call(self.m_itemModel.index);
  end
end

return OpenServerV3CheckInItemView;