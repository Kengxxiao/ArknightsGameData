
















local ReturnPackageView = Class("ReturnPackageView", UIPanel);

local ReturnPackageItemView = require("Feature/Operation/Returning/Package/ReturnPackagePicItemView");
local ReturnPackagePicItemToggleView = require("Feature/Operation/Returning/Package/ReturnPackagePicItemToggleView");

function ReturnPackageView:OnInit()
  self.m_picItemView = {};
  self:AddButtonClickListener(self._btnLeftArrow, self._EventLeftArrowClick);
  self:AddButtonClickListener(self._btnRightArrow, self._EventRightArrowClick);
  self.m_viewModel = nil;

  self.m_packageAdapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._transPicContent,
      self._CreatePackageItemView, self._GetPackageItemCount, self._UpdatePackageItemView);
  self.m_packageToggleAdapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self,self._transToggleGroupSwitch,
      self._CreatePackageToggleItemView, self._GetPackageItemCount, self._UpdatePackageToggleItemView);
  self.m_pagerUpdateEvent = function(index)
    self:_EventPagerUpdate(index);
  end
  self._giftPackagePicPage:AddPageIndexChangedListener(self.m_pagerUpdateEvent);
end

function ReturnPackageView:OnClose()
  self._giftPackagePicPage:RemovePageIndexChangedListener(self.m_pagerUpdateEvent);
  self.m_pagerUpdateEvent = nil;
end

function ReturnPackageView:OnVisible(v)
  if v then
    self:_ResetPicTimer();
  else
    if self.m_picMoveTimer then
      self:DestroyTimer(self.m_picMoveTimer);
      self.m_picMoveTimer = nil;
    end
  end
end


function ReturnPackageView:OnViewModelUpdate(data)
  if data == nil or data.packageViewModel == nil then
    return;
  end
  self.m_viewModel = data.packageViewModel;
  self.m_picItemView = {};
  local packageViewModel = data.packageViewModel;
  local itemViewModelList = packageViewModel.giftPackagePicItemList;
  self._giftPackagePicPage.pageCount = #itemViewModelList;
  self.m_packageAdapter:NotifyDataSetChanged();
  self.m_packageToggleAdapter:NotifyDataSetChanged();
  self:_SetArrowShow(#itemViewModelList > 1);
  SetGameObjectActive(self._objToggleGroup, #itemViewModelList > 1);
end



function ReturnPackageView:_CreatePackageItemView(gameObj)
  local itemView = self:CreateWidgetByGO(ReturnPackageItemView, gameObj);
  return itemView;
end


function ReturnPackageView:_GetPackageItemCount()
  if self.m_viewModel == nil or self.m_viewModel.giftPackagePicItemList == nil then
    return 0;
  end
  return #self.m_viewModel.giftPackagePicItemList;
end



function ReturnPackageView:_UpdatePackageItemView(index, view)
  if self.m_viewModel == nil or self.m_viewModel.giftPackagePicItemList == nil then
    return;
  end
  view:Render(self.m_viewModel.giftPackagePicItemList[index + 1]);
end


function ReturnPackageView:_CreatePackageToggleItemView(gameObj)
  local itemView = self:CreateWidgetByGO(ReturnPackagePicItemToggleView, gameObj);
  return itemView;
end



function ReturnPackageView:_UpdatePackageToggleItemView(index, view)
  local current = self._giftPackagePicPage.currentPage;
  view:Render(index == current);
end

function ReturnPackageView:_EventLeftArrowClick()
  local current = self._giftPackagePicPage.currentPage;
  local targetIdx = 0;
  if current > 0 then
    targetIdx = current - 1;
  else
    targetIdx = self._giftPackagePicPage.pageCount - 1;
  end

  self._giftPackagePicPage:MoveToPage(targetIdx);
end

function ReturnPackageView:_EventRightArrowClick()
  local current = self._giftPackagePicPage.currentPage;
  local targetIdx = (current + 1) % self._giftPackagePicPage.pageCount;
  self._giftPackagePicPage:MoveToPage(targetIdx);
end


function ReturnPackageView:_EventPagerUpdate(index)
  self.m_packageToggleAdapter:NotifyDataSetChanged();
  self:_ResetPicTimer();
end

function ReturnPackageView:_EventPicMove()
  self:_EventRightArrowClick();
end

function ReturnPackageView:_ResetPicTimer()
  if self.m_picMoveTimer then
    self:DestroyTimer(self.m_picMoveTimer);
  end
    self.m_picMoveTimer = self:Delay(self._timeMovePic, self._EventPicMove);
end


function ReturnPackageView:_SetArrowShow(isShow)
  SetGameObjectActive(self._objLeftArrow, isShow);
  SetGameObjectActive(self._objRightArrow, isShow);
end

return ReturnPackageView;