
WardrobeSkinGroupDetailState = Class("WardrobeSkinGroupDetailState", FadeInDlgBase);





function WardrobeSkinGroupDetailState:OnInit()
  self.onSaleObj = {}
  self.notOnSaleObj = {}
end

function WardrobeSkinGroupDetailState:OnResume()
  
  self:Render()
end

function WardrobeSkinGroupDetailState:OnClose()
  
  self._wrappedViewPager:ClearFunc()
end

function WardrobeSkinGroupDetailState:_RenderCheck(data)
  for k,v in pairs(data.skinList) do
    if (WardrobeUtil.CheckSkinOnSale(v)) then
      table.insert(self.onSaleData, v)
    else
      table.insert(self.notOnSaleData,v)
    end
  end

  table.sort(self.onSaleData, function(a, b)
      if (a.data.displaySkin.getTime ~= b.data.displaySkin.getTime)then
        return a.data.displaySkin.getTime < b.data.displaySkin.getTime
      end
    return a.data.displaySkin.sortId < b.data.displaySkin.sortId 
  end);

  table.sort(self.notOnSaleData, function(a, b)
      if (a.data.displaySkin.getTime ~= b.data.displaySkin.getTime)then
        return a.data.displaySkin.getTime < b.data.displaySkin.getTime
      end
    return a.data.displaySkin.sortId < b.data.displaySkin.sortId 
  end);


  self:Render()
  
  if (#self.onSaleData > 5) then
    local pos = self._onSaleCont.anchoredPosition
    pos.x = (#self.onSaleData - 6) * 99 + 69.5
    self._onSaleCont.anchoredPosition = pos
  end

end

function WardrobeSkinGroupDetailState:CheckData(data)
  self._brandIcon.sprite = CS.Torappu.DataConvertUtil.LoadBrandIcon(data.data.brandId, false)
  self._brandName.text = data.data.brandName
  self._brandDesc.text = CS.Torappu.FormatUtil.FormatRichTextFromData(data.data.description)
  self.onSaleData = {}
  self.notOnSaleData = {}
  self.cacheData = data

  local skinGroupTimeRef = {}
  for i,groupInfo in pairs(data.data.groupList) do
    skinGroupTimeRef[groupInfo.skinGroupId] = groupInfo.publishTime
  end

  self:_RenderCheck(data)

  local currentTime =  CS.Torappu.DateTimeUtil.timeStampNow
  local spriteList = {}
  for k,kvImgInfo in pairs(data.data.kvImgIdList) do
    local publishTime = skinGroupTimeRef[kvImgInfo.linkedSkinGroupId]
    if publishTime < currentTime then
      table.insert(spriteList,kvImgInfo.kvImgId)
    end
  end
  table.insert(spriteList,string.format("default_kv_%s",data.data.brandId))
  local pos = self._content.anchoredPosition
  pos.y = 0
  self._content.anchoredPosition = pos
  self._triEffect:ToInitScale()
  self.spriteList = spriteList
  self._wrappedViewPager:InitRenderFunc(spriteList,CS.Torappu.ResourceUrls.GetSkinKvHubPath())
end

function WardrobeSkinGroupDetailState:GetTransInfo()
  return not self.onFadeIn,nil
end

function WardrobeSkinGroupDetailState:OnClick(skinId)
  local skinList = {}
  local skinShopList = {}
  for k,v in pairs(self.onSaleData)do
    table.insert(skinShopList,v.shopData)
  end
  for k,v in pairs(self.notOnSaleData)do
    table.insert(skinList,v.data.skinId)
  end
  if (#skinList + #skinShopList > 0) then
    CS.Torappu.UI.Skin.SkinPage.OpenPageForMultiSkinList(skinId,skinShopList,skinList)
  end
end

function WardrobeSkinGroupDetailState:Render()
  local countTempObj = #self.onSaleObj
  local countTempData = #self.onSaleData
  if (countTempObj < countTempData) then
    for i = 1, countTempData - countTempObj do
      local skinItem = self:CreateWidgetByPrefab(WardrobeSkinItem, self._skinObj, self._onSaleCont);
      table.insert(self.onSaleObj,skinItem)
    end
  end

  countTempObj = #self.notOnSaleObj
  countTempData = #self.notOnSaleData
  if (countTempObj < countTempData) then
    for i = 1, countTempData - countTempObj do
      local skinItem = self:CreateWidgetByPrefab(WardrobeSkinItem, self._skinObj, self._notOnSaleCont);
      table.insert(self.notOnSaleObj,skinItem)
    end
  end
  local skinUnlockFlag = WardrobeUtil.GetSkinUnGetFlag()
  for k,v in pairs(self.onSaleObj) do
    if (self.onSaleData[k] ~= nil) then
      CS.Torappu.Lua.Util.SetActiveIfNecessary(v:RootGameObject(),true)
      v:Render(self.onSaleData[k])
      v:SetUnGetFlag(skinUnlockFlag)
    else
      CS.Torappu.Lua.Util.SetActiveIfNecessary(v:RootGameObject(),false)
    end
  end

  for k,v in pairs(self.notOnSaleObj) do
    if (self.notOnSaleData[k] ~= nil) then
      CS.Torappu.Lua.Util.SetActiveIfNecessary(v:RootGameObject(),true)
      v:Render(self.notOnSaleData[k])
      v:SetUnGetFlag(skinUnlockFlag)
    else
      CS.Torappu.Lua.Util.SetActiveIfNecessary(v:RootGameObject(),false)
    end
  end

  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._onSaleObj,#self.onSaleData~=0)
  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._notOnSaleCont.gameObject,#self.notOnSaleData~=0)
end

function WardrobeSkinGroupDetailState:OnClose()
  self.onSaleObj = {}
  self.notOnSaleObj = {}
  WardrobeSkinGroupDetailState.onSaleObj = {}
  WardrobeSkinGroupDetailState.notOnSaleObj = {}
end