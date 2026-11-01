














local OpenServerV3MilestoneItemView = Class("OpenServerV3MilestoneItemView", UIWidget);

local UICommonItemCard = require("Feature/Supportor/UI/UICommonItemCard");

function OpenServerV3MilestoneItemView:OnInitialize()
  if self._btnClaimArea ~= nil then
    self:AddButtonClickListener(self._btnClaimArea, self._EventOnClaimClicked);
  end
end


function OpenServerV3MilestoneItemView:Render(viewModel)
  if viewModel == nil then
    return;
  end
  self:_InitIfNot();
  self.m_viewModel = viewModel;
  self:_RefreshBaseInfo(viewModel);
  self:_RefreshReward(viewModel);
  self:_RefreshState(viewModel);
end



function OpenServerV3MilestoneItemView:_RefreshBaseInfo(viewModel)
  if self._textLevel ~= nil then
    self._textLevel.text = tostring(viewModel.level);
  end
end



function OpenServerV3MilestoneItemView:_RefreshReward(viewModel)
  if self.m_rewardItemView == nil then
    return;
  end
  self.m_rewardItemView:Render(viewModel.rewardModel, {
    itemScale = tonumber(self._itemCardScale),
    isCardClickable = true,
    showItemName = false,
    showItemNum = true,
    showBackground = true,
  });
end



function OpenServerV3MilestoneItemView:_RefreshState(viewModel)
  local isClaimable = viewModel.state == OpenServerV3MilestoneItemState.COMPLETE;
  local isConfirmed = viewModel.state == OpenServerV3MilestoneItemState.CONFIRMED;
  local isReached = isClaimable or isConfirmed;
  SetGameObjectActive(self._bgNormal, not viewModel.isBonus and not isReached);
  SetGameObjectActive(self._bgNormalComplete, not viewModel.isBonus and isReached);
  SetGameObjectActive(self._bgBonus, viewModel.isBonus and not isReached);
  SetGameObjectActive(self._bgBonusComplete, viewModel.isBonus and isReached);
  SetGameObjectActive(self._panelConfirmed, isConfirmed);
  if self._btnClaimArea ~= nil then
    SetGameObjectActive(self._btnClaimArea.gameObject, not isConfirmed and isReached);
  end
end


function OpenServerV3MilestoneItemView:_InitIfNot()
  if self.m_hasInited then
    return;
  end
  self.m_hasInited = true;
  if self.createWidgetByGO == nil or self._itemCardLayout == nil then
    return;
  end
  self.m_rewardItemView = self.createWidgetByGO(UICommonItemCard, self._itemCardLayout);
end


function OpenServerV3MilestoneItemView:_EventOnClaimClicked()
  if self.m_viewModel == nil or self.onItemClicked == nil then
    return;
  end
  if self.m_viewModel.state ~= OpenServerV3MilestoneItemState.COMPLETE then
    return;
  end
  self.onItemClicked:Call(self.m_viewModel.level);
end

return OpenServerV3MilestoneItemView;
