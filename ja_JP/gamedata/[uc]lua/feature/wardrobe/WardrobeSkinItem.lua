
WardrobeSkinItem = Class("WardrobeSkinItem", UIWidget);

WardrobeSkinItem.ANIM_PARAM = "alpha_add"

function WardrobeSkinItem:OnInitialize()
  
  
  
  self.cacheHaveFlag = true

  self:AddButtonClickListener(self._button, self._OnClick);
end

function WardrobeSkinItem:Render(skin)
  local succ, brandImg = CS.Torappu.DataConvertUtil.TryLoadSkinGroupIcon(skin.data.displaySkin.skinGroupId, true)
  if (succ) then 
    self._brandImg.sprite = brandImg
  end 
  self.cacheData = skin
  
  local sprite = CS.Torappu.CharacterUtil.LoadCharPortrait(skin.data:GetPortraitId())
  self._skinImg:SetSprite(sprite)
  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._onSaleObj,WardrobeUtil.CheckSkinOnSale(skin))
  self._skinName.text = skin.data.displaySkin.skinName
  self._brandName.text = CS.Torappu.DataConvertUtil.GetSkinBrandCapitalName(skin.data.displaySkin.skinGroupId)
  if (skin.data.displaySkin.displayTagId ~= nil) then
    CS.Torappu.Lua.Util.SetActiveIfNecessary(self._tagItem,true)
    self._tagText.text = skin.data.displaySkin.displayTagId
  else
    CS.Torappu.Lua.Util.SetActiveIfNecessary(self._tagItem,false)
  end
end

function WardrobeSkinItem:SetUnGetFlag(flag)
  self.unGetFlag = flag
  if (self.cacheData == nil) then
    return
  end
  if (flag) then
    local haveFlag = CS.Torappu.CharacterUtil.CheckSkinAvailable(self.cacheData.data.skinId)
    CS.Torappu.Lua.Util.SetActiveIfNecessary(self._dontHaveItem, not haveFlag)
    if (not haveFlag and haveFlag ~= self.cacheHaveFlag) then
      self._animWrapper:PlayWithTween(WardrobeSkinItem.ANIM_PARAM)
    end
    self.cacheHaveFlag = haveFlag
  else
    CS.Torappu.Lua.Util.SetActiveIfNecessary(self._dontHaveItem,false)
    self.cacheHaveFlag = true
  end
end

function WardrobeSkinItem:_OnClick()
  if(self.m_parent~=nil and self.m_parent.OnClick~=nil)then
    self.m_parent:OnClick(self.cacheData.data.skinId)
  end
end