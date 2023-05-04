
WardrobeBrandItem = Class("WardrobeBrandItem", UIWidget);

function WardrobeBrandItem:Render(data)
  self.cacheData = data
  self._brandIcon.sprite = CS.Torappu.DataConvertUtil.LoadBrandIcon(data.data.brandId, false)
  self._brandName.text =data.data.brandName
  self:AddButtonClickListener(self._button, self._OnClick);
  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._onSaleFlag,WardrobeUtil.CheckSkinListOnSale(data.skinList))
end

function WardrobeBrandItem:_OnClick()
  if (self.cacheData~=nil)then
    self.parent:JumpToDetail(self.cacheData)
  end
end