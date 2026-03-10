local UICommonItemCard = require("Feature/Supportor/UI/UICommonItemCard")







local ReturnNewsItemRewardView = Class("ReturnNewsItemRewardView", UIPanel);

function ReturnNewsItemRewardView:_InitIfNot()
  if (self.m_hasInited) then
    return;
  end
  self.m_hasInited = true;
  self.m_adapter = self:CreateCustomComponent(
      UISimpleLayoutAdapter, self, self._layout, self._CreateItemView,
      self._GetItemCount, self._UpdateItemView);
end

function ReturnNewsItemRewardView:_GetItemCount()
  if self.m_itemList == nil then
    return 0;
  end
  if #self.m_itemList > 2 then
    return 2;
  end
  return #self.m_itemList;
end

function ReturnNewsItemRewardView:_CreateItemView(gameObj)
  local itemView = self:CreateWidgetByGO(UICommonItemCard, gameObj);
  return itemView;
end



function ReturnNewsItemRewardView:_UpdateItemView(index, item)
  item:Render(self.m_itemList[index + 1], {
    itemScale = self._itemScale,
    isCardClickable = true,
    showItemName = false,
    showItemNum = false,
    showBackground = true,
    fastClickBlock = true,
  });
end


function ReturnNewsItemRewardView:Render(items)
  self:_InitIfNot();
  self.m_itemList = ToLuaArray(items);
  self.m_adapter:NotifyDataSetChanged();
end

return ReturnNewsItemRewardView;