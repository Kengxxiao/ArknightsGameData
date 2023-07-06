









local ReturnV2MissionPointRewardDetailItem = Class("ReturnV2MissionPointRewardDetailItem", UIPanel);
local UICommonItemCard = require("Feature/Supportor/UI/UICommonItemCard");

function ReturnV2MissionPointRewardDetailItem:OnInit()
  self.m_rewardItemList = {};
  self.m_adapter = self:CreateCustomComponent(
      UISimpleLayoutAdapter, self, self._rewardItemContent,
      self._CreatePointRewardItemView, self._GetPointRewardItemCount, 
      self._UpdatePointRewardItemView);
  self.m_hubPath = CS.Torappu.ResourceUrls.GetReturnV2PointIconHubPath();
end





function ReturnV2MissionPointRewardDetailItem:Render(iconId, title, rewardItemList, haveClaimed)
  if self.loadSpriteFunc == nil then
    return
  end
  self._imgPointStateIcon.sprite = self.loadSpriteFunc(self.m_hubPath, iconId);
  self._textPointStateTitle.text = title;
  self.m_rewardItemList = rewardItemList;
  SetGameObjectActive(self._objHaveClaimed, haveClaimed);

  self.m_adapter:NotifyDataSetChanged();
end



function ReturnV2MissionPointRewardDetailItem:_CreatePointRewardItemView(gameObj)
  local itemView = self:CreateWidgetByGO(UICommonItemCard, gameObj);
  return itemView;
end


function ReturnV2MissionPointRewardDetailItem:_GetPointRewardItemCount()
  if self.m_rewardItemList == nil then
    return 0;
  end
  return #self.m_rewardItemList;
end



function ReturnV2MissionPointRewardDetailItem:_UpdatePointRewardItemView(index, view)
  view:Render(self.m_rewardItemList[index + 1], {
    itemScale = tonumber(self._itemScale),
    isCardClickable = true,
    showItemName = false,
    showItemNum = true,
    showBackground = true,
  });
end

return ReturnV2MissionPointRewardDetailItem;