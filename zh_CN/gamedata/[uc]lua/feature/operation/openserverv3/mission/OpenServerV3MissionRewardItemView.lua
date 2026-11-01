




local OpenServerV3MissionRewardItemView = Class("OpenServerV3MissionRewardItemView", UIWidget);

local UICommonItemCard = require("Feature/Supportor/UI/UICommonItemCard");



function OpenServerV3MissionRewardItemView:Render(itemModel, itemCardScale)
  local hasReward = itemModel ~= nil;
  if self.m_itemView ~= nil then
    SetGameObjectActive(self.m_itemView:RootGameObject(), hasReward);
  end
  SetGameObjectActive(self._panelEmpty, not hasReward);
  if not hasReward then
    return;
  end
  self:_CreateItemViewIfNeed();
  if self.m_itemView == nil then
    return;
  end
  SetGameObjectActive(self.m_itemView:RootGameObject(), true);
  self.m_itemView:Render(itemModel, {
    itemScale = itemCardScale,
    isCardClickable = true,
    showItemName = false,
    showItemNum = true,
    showBackground = true,
  });
end


function OpenServerV3MissionRewardItemView:_CreateItemViewIfNeed()
  if self.m_itemView ~= nil or self.createWidgetByGO == nil or self._itemCardLayout == nil then
    return;
  end
  self.m_itemView = self.createWidgetByGO(UICommonItemCard, self._itemCardLayout);
end

return OpenServerV3MissionRewardItemView;
