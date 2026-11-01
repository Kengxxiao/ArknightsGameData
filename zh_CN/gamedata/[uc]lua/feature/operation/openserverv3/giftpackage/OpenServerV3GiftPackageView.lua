

















local OpenServerV3GiftPackageView = Class("OpenServerV3GiftPackageView", UIPanel);

local OpenServerV3GiftPackageItemView = require("Feature/Operation/OpenServerV3/GiftPackage/OpenServerV3GiftPackageItemView");
local OpenServerV3GiftPackageToggleView = require("Feature/Operation/OpenServerV3/GiftPackage/OpenServerV3GiftPackageToggleView");
local TorappuAudio = CS.Torappu.TorappuAudio;
local AudioConsts = CS.Torappu.Audio;

function OpenServerV3GiftPackageView:OnInit()
  self:AddButtonClickListener(self._btnLeftArrow, self._EventLeftArrowClick);
  self:AddButtonClickListener(self._btnRightArrow, self._EventRightArrowClick);
  self.m_viewModel = nil;

  self.m_packageAdapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._gpPicContent,
      self._CreatePackageItemView, self._GetPackageItemCount, self._UpdatePackageItemView);
  self.m_packageToggleAdapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._toggleContent,
      self._CreatePackageToggleItemView, self._GetPackageItemCount, self._UpdatePackageToggleItemView);
  self.m_pagerUpdateEvent = function(index)
    self:_EventPagerUpdate(index);
  end
  self._gpPicPager:AddPageIndexChangedListener(self.m_pagerUpdateEvent);
  self.m_pagerSoundEvent = function(index)
    TorappuAudio.PlayUI(AudioConsts.Consts.InternalSounds[AudioConsts.UiInternalSoundType.TabSwitchBtn]);
  end
  self._gpPicPager:AddPageIndexListener(self.m_pagerSoundEvent);
end

function OpenServerV3GiftPackageView:OnClose()
  self._gpPicPager:RemovePageIndexChangedListener(self.m_pagerUpdateEvent);
  self.m_pagerUpdateEvent = nil;
  self._gpPicPager:RemovePageIndexListener(self.m_pagerSoundEvent);
  self.m_pagerSoundEvent = nil;
end

function OpenServerV3GiftPackageView:OnVisible(v)
  if v then
    self:_ResetPicTimer();
  else
    if self.m_picMoveTimer then
      self:DestroyTimer(self.m_picMoveTimer);
      self.m_picMoveTimer = nil;
    end
  end
end


function OpenServerV3GiftPackageView:OnViewModelUpdate(data)
  if data == nil or data.giftPackageViewModel == nil then
    return;
  end
  self.m_viewModel = data.giftPackageViewModel;
  local itemViewModelList = self.m_viewModel.itemList;
  local itemCount = itemViewModelList ~= nil and #itemViewModelList or 0;
  self._gpPicPager.pageCount = itemCount;
  self.m_packageAdapter:NotifyDataSetChanged();
  self.m_packageToggleAdapter:NotifyDataSetChanged();
  self:_SetArrowShow(itemCount > 1);
  self:_SetToggleShow(itemCount > 1);
  if self:IsVisible() and not self.m_picMoveTimer then
    self:_ResetPicTimer();
  end
end



function OpenServerV3GiftPackageView:_CreatePackageItemView(gameObj)
  local itemView = self:CreateWidgetByGO(OpenServerV3GiftPackageItemView, gameObj);
  itemView.onGiftPackageClicked = self.onGiftPackageClicked;
  return itemView;
end


function OpenServerV3GiftPackageView:_GetPackageItemCount()
  if self.m_viewModel == nil or self.m_viewModel.itemList == nil then
    return 0;
  end
  return #self.m_viewModel.itemList;
end



function OpenServerV3GiftPackageView:_UpdatePackageItemView(index, view)
  if self.m_viewModel == nil or self.m_viewModel.itemList == nil then
    return;
  end
  view.onGiftPackageClicked = self.onGiftPackageClicked;
  view:Render(self.m_viewModel.itemList[index + 1]);
end



function OpenServerV3GiftPackageView:_CreatePackageToggleItemView(gameObj)
  local itemView = self:CreateWidgetByGO(OpenServerV3GiftPackageToggleView, gameObj);
  return itemView;
end



function OpenServerV3GiftPackageView:_UpdatePackageToggleItemView(index, view)
  local current = self._gpPicPager.currentPage;
  view:Render(index == current);
end

function OpenServerV3GiftPackageView:_EventLeftArrowClick()
  if self._gpPicPager.pageCount <= 1 then
    return;
  end
  local current = self._gpPicPager.currentPage;
  local targetIdx = 0;
  if current > 0 then
    targetIdx = current - 1;
  else
    targetIdx = self._gpPicPager.pageCount - 1;
  end

  self._gpPicPager:MoveToPage(targetIdx);
end

function OpenServerV3GiftPackageView:_EventRightArrowClick()
  if self._gpPicPager.pageCount <= 1 then
    return;
  end
  local current = self._gpPicPager.currentPage;
  local targetIdx = (current + 1) % self._gpPicPager.pageCount;
  self._gpPicPager:MoveToPage(targetIdx);
end


function OpenServerV3GiftPackageView:_EventPagerUpdate(index)
  self.m_packageToggleAdapter:NotifyDataSetChanged();
  self:_ResetPicTimer();
end

function OpenServerV3GiftPackageView:_EventPicMove()
  self:_EventRightArrowClick();
end

function OpenServerV3GiftPackageView:_ResetPicTimer()
  if self.m_picMoveTimer then
    self:DestroyTimer(self.m_picMoveTimer);
    self.m_picMoveTimer = nil;
  end
  if self._gpPicPager == nil or self._gpPicPager.pageCount <= 1 then
    return;
  end
  self.m_picMoveTimer = self:Delay(self._movePicDelay, self._EventPicMove);
end


function OpenServerV3GiftPackageView:_SetArrowShow(isShow)
  SetGameObjectActive(self._panelLeftArrow, isShow);
  SetGameObjectActive(self._panelRightArrow, isShow);
end


function OpenServerV3GiftPackageView:_SetToggleShow(isShow)
  if self._toggleContent ~= nil then
    SetGameObjectActive(self._toggleContent.gameObject, isShow);
  end
end

return OpenServerV3GiftPackageView;
