





local OpenServerV3GiftPackageItemView = Class("OpenServerV3GiftPackageItemView", UIWidget);

function OpenServerV3GiftPackageItemView:OnInitialize()
  self:AddButtonClickListener(self._btnGiftPackage, self._EventOnGiftPackageClicked);
end


function OpenServerV3GiftPackageItemView:Render(viewModel)
  if viewModel == nil then
    return;
  end
  self.m_viewModel = viewModel;

  if self._imgGiftPackage ~= nil and viewModel.imgId ~= nil and viewModel.imgId ~= "" then
    self._imgGiftPackage.sprite =
        self:LoadSpriteFromAutoPackHub(CS.Torappu.ResourceUrls.GetOpenServerGiftPackageHubPath(),
            viewModel.imgId);
  end
end

function OpenServerV3GiftPackageItemView:_EventOnGiftPackageClicked()
  if self.m_viewModel == nil or self.m_viewModel.goodId == nil or self.m_viewModel.goodId == "" then
    return;
  end
  if self.onGiftPackageClicked ~= nil then
    self.onGiftPackageClicked:Call(self.m_viewModel.goodId, self.m_viewModel.imgId);
  end
end

return OpenServerV3GiftPackageItemView;
