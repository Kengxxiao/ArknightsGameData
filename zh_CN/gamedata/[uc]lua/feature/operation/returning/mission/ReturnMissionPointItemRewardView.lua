













local ReturnMissionPointItemRewardView = Class("ReturnMissionPointItemRewardView", UIWidget);

local UICommonItemCard = require("Feature/Supportor/UI/UICommonItemCard");


function ReturnMissionPointItemRewardView:Render(model)
  self:_InitIfNot();
  if model == nil then
    return;
  end
  SetGameObjectActive(self._panelComplete, model.state == ReturnMissionItemState.COMPLETE);
  SetGameObjectActive(self._panelUncomplete, model.state == ReturnMissionItemState.UNCOMPLETE);
  SetGameObjectActive(self._panelClaimed, model.state == ReturnMissionItemState.CONFIRMED);
  self._textPoint.text = model.pointRequire;
  if self.m_itemView ~= nil then
    self.m_itemView:Render(model.displayReward, {
      itemScale = tonumber(self._itemCardScale),
      isCardClickable = true,
      showItemName = false,
      showItemNum = false,
      showBackground = true,
    });
  end
end

function ReturnMissionPointItemRewardView:_InitIfNot()
  if self.m_hasInited then
    return;
  end
  self.m_hasInited = true;
  if self.createWidgetByPrefab ~= nil then
    self.m_itemView = self.createWidgetByPrefab(UICommonItemCard, self._itemCardPrefab, self._itemCardContainer);
  end
end

return ReturnMissionPointItemRewardView;