



local ReturnPackagePicItemView = Class("ReturnPackagePicItemView", UIWidget);

function ReturnPackagePicItemView:OnInitialize()
  self:AddButtonClickListener(self._btnGiftPackage, self._EventOnJumpGPShopClick);
end


function ReturnPackagePicItemView:Render(viewModel)
  if viewModel == nil then
    return;
  end
  self.m_viewModel = viewModel;

  self._imgGiftPackage.sprite = 
      self:LoadSpriteFromAutoPackHub(CS.Torappu.ResourceUrls.GetReturnGiftPackagePicHubPath(),
          viewModel.giftPackagePic);
end

function ReturnPackagePicItemView:_EventOnJumpGPShopClick()
  if self.m_viewModel == nil then
    return;
  end
  if not _ToastIfLocked(CS.Torappu.UI.UILockTarget.SHOP_ENTRY) then
    return;
  end
  CS.Torappu.GameAnalytics.RecordShopTitleClicked(CS.Torappu.ShopType.GIFTPACKAGE, CS.Torappu.UI.Shop.ShopPage.Referrer.BACKFLOW);
  CS.Torappu.GameAnalytics.RecordShopTabClicked("");
  CS.Torappu.GameAnalytics.RecordShopItemClicked(self.m_viewModel.giftPackageId);
  local param = CS.Torappu.UI.Shop.ShopPage.Params();
  param.targetShop = CS.Torappu.ShopRouteTarget.GIFTPACKAGE;
  param.targetGoodId = self.m_viewModel.giftPackageId;
  
  CS.Torappu.UI.UIRouteUtil.RouteToShopAndResetStack(param);
end

function _ToastIfLocked(lockTarget)
  local isUnlocked = CS.Torappu.UI.UIGuideController.CheckIfUnlocked(lockTarget);
  if not isUnlocked then
    CS.Torappu.UI.UIGuideController.ToastOnLockedItemClicked(lockTarget);
  end
  return isUnlocked;
end

return ReturnPackagePicItemView;