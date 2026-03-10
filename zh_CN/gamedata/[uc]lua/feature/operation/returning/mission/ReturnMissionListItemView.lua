




















local ReturnMissionListItemView = Class("ReturnMissionListItemView", UIWidget);

local UICommonItemCard = require("Feature/Supportor/UI/UICommonItemCard");

function ReturnMissionListItemView:OnInitialize()
  self.m_adapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._content,
      self._CreateRewardItemView, self._GetRewardItemCount, self._UpdateRewardItemView);
end


function ReturnMissionListItemView:Render(viewModel)
  if viewModel == nil then
    return;
  end

  self.m_viewModel = viewModel;

  self._imgComplete.sprite = self:_LoadSprite(CS.Torappu.ResourceUrls.GetReturnMissionBkgHubPath(), 
      viewModel.completeBgIcon);
  self._imgUncomplete.sprite = self:_LoadSprite(CS.Torappu.ResourceUrls.GetReturnMissionBkgHubPath(), 
      viewModel.uncompleteBgIcon);
  self._textDescUncomplete.text = viewModel.missionDesc;
  self._textDescComplete.text = viewModel.missionDesc;
  local isUncomplete = viewModel.state == ReturnMissionItemState.UNCOMPLETE;
  SetGameObjectActive(self._panelUncomplete, isUncomplete);
  if isUncomplete then
    self._textCurrent.text = viewModel.valueDesc;
    self._textTarget.text = viewModel.targetDesc;
    self._sliderProgress.value = viewModel.progress;
  end
  SetGameObjectActive(self._panelComplete, viewModel.state ~= ReturnMissionItemState.UNCOMPLETE);
  SetGameObjectActive(self._panelClaimed, viewModel.state == ReturnMissionItemState.CONFIRMED);
  self.m_adapter:NotifyDataSetChanged();
end


function ReturnMissionListItemView:GetGraphic()
  return self._graphic;
end



function ReturnMissionListItemView:_GetRewardItemCount()
  if self.m_viewModel == nil or self.m_viewModel.rewardList == nil then
    return 0;
  end
  local rewardCount = #self.m_viewModel.rewardList;
  if rewardCount >= 2 then
    return 2;
  end
  return #self.m_viewModel.rewardList;
end



function ReturnMissionListItemView:_CreateRewardItemView(gameObj)
  local itemView = self:_CreateWidgetByGO(UICommonItemCard, gameObj);
  return itemView;
end




function ReturnMissionListItemView:_UpdateRewardItemView(index, view)
  view:Render(self.m_viewModel.rewardList[index + 1], {
    itemScale = tonumber(self._itemCardScale),
    isCardClickable = true,
    showItemName = false,
    showItemNum = true,
    showBackground = true,
  });
end






function ReturnMissionListItemView:_CreateWidgetByGO(widgetCls, layout)
  if self.createWidgetByGO == nil then
    return nil;
  end
  return self.createWidgetByGO(widgetCls, layout);
end





function ReturnMissionListItemView:_LoadSprite(hubPath, spriteName)
  if self.loadFunc == nil then
    return nil;
  end
  return self.loadFunc(hubPath, spriteName);
end

return ReturnMissionListItemView;