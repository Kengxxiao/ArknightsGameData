











local ReturnPointDetailRewardGroupView = Class("ReturnPointDetailRewardGroupView", UIWidget);

local UICommonItemCard = require("Feature/Supportor/UI/UICommonItemCard");

function ReturnPointDetailRewardGroupView:OnInitialize()
  self.m_adapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._content,
      self._CreateRewardItemView, self._GetRewardItemCount, self._UpdateRewardItemView);
end


function ReturnPointDetailRewardGroupView:Render(viewModel)
  if viewModel == nil then
    return;
  end

  self._textPoint.text = viewModel.pointRequire;
  self._textDesc.text = viewModel.desc;
  SetGameObjectActive(self._panelClaimed, viewModel.state == ReturnMissionItemState.CONFIRMED);

  self.m_rewardList = viewModel.rewardList;
  self.m_adapter:NotifyDataSetChanged();
end



function ReturnPointDetailRewardGroupView:_GetRewardItemCount()
  if self.m_rewardList == nil then
    return 0;
  end
  return #self.m_rewardList;
end



function ReturnPointDetailRewardGroupView:_CreateRewardItemView(gameObj)
  local itemView = self:_CreateWidgetByGO(UICommonItemCard, gameObj);
  return itemView;
end




function ReturnPointDetailRewardGroupView:_UpdateRewardItemView(index, view)
  view:Render(self.m_rewardList[index + 1], {
    itemScale = tonumber(self._itemCardScale),
    isCardClickable = true,
    showItemName = false,
    showItemNum = true,
    showBackground = true,
  });
end






function ReturnPointDetailRewardGroupView:_CreateWidgetByGO(widgetCls, layout)
  if self.createWidgetByGO == nil then
    return nil;
  end
  return self.createWidgetByGO(widgetCls, layout);
end

return ReturnPointDetailRewardGroupView;