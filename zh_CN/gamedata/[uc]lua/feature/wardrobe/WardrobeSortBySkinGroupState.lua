WardrobeSortBySkinGroupState = Class("WardrobeSortBySkinGroupState", UIPanel);

WardrobeSortBySkinGroupState.initFlag = false
WardrobeSortBySkinGroupState.ANIM_PARAM = "wardrobe_list"

function WardrobeSortBySkinGroupState:OnInit()
end


function WardrobeSortBySkinGroupState:GetTransInfo()
	return not self.onFadeIn and self.effectFlag , self.cacheData
end


function WardrobeSortBySkinGroupState:JumpToDetail(skinGroup)
  self.cacheData = skinGroup
  self.parent:ToState(WardrobePageHolder.StateEnum.SkinGroupDetailStateIndex)
end

function WardrobeSortBySkinGroupState:PlayAnim()
  
  self.selfTween = self._animWrapper:PlayWithTween(WardrobeSortBySkinGroupState.ANIM_PARAM )  
end

function WardrobeSortBySkinGroupState:CheckData(data)
  if (self.sequence~= nil) then
    self.sequence:Kill()
  end
  if (self.selfTween~=nil) then
    self.selfTween:Kill()
  end
  self._animWrapper:SampleClipAtBegin(WardrobeSortBySkinGroupState.ANIM_PARAM)
  self.sequence =  CS.DG.Tweening.DOTween.Sequence();
  self.sequence:AppendInterval(0.05)
  self.sequence:AppendCallback(function()
      self:PlayAnim()
  end)
  self:Delay(0.8,self.OnEffect)

  if (self.initFlag) then
    return
  end

  self.initFlag = true
	self._rootCanvas.blocksRaycasts = false
  self.cacheData = data;
  self.stateBean = {}
  self.stateBean.brandList = {}
  self.brandItemList = {}
  self.effectFlag = false
  local brandRef = {}
  local brandData = CS.Torappu.SkinDB.data.brandList

  local currentTime =  CS.Torappu.DateTimeUtil.timeStampNow
  for k,v in pairs(brandData) do
    if (v.publishTime < currentTime) then
      local haveValidGroup = false
      for index, groupInfo in pairs(v.groupList) do
        if (groupInfo.publishTime < currentTime) then
          haveValidGroup = true
          brandRef[groupInfo.skinGroupId] = k
        end
      end
      if haveValidGroup then
        local brand = {}
        brand.brandId = k
        brand.data = v
        brand.skinList = {}
        table.insert(self.stateBean.brandList,brand)
      end
    end
  end
  for getTime, skinList in pairs(data) do
    for index, skin in pairs(skinList) do
      if (skin.data.displaySkin.getTime< currentTime) then
        local brandId = brandRef[skin.data.displaySkin.skinGroupId]
        for i,brandInfo in pairs(self.stateBean.brandList) do
          if (brandInfo.brandId == brandId) then
            table.insert(brandInfo.skinList,skin)
          end
        end
      end
    end
  end
  for i,brandInfo in pairs(self.stateBean.brandList) do
    brandInfo.onSaleFlag = WardrobeUtil.CheckSkinListOnSale(brandInfo.skinList)
  end
  table.sort(self.stateBean.brandList,function(a,b)
    if (a.onSaleFlag~=b.onSaleFlag)  then
      return a.onSaleFlag
    end
    return a.data.sortId < b.data.sortId
  end)
  self:Render()
end

function WardrobeSortBySkinGroupState:Render()
  local countTempObj = #self.brandItemList
  local countTempData = #self.stateBean.brandList
  if (countTempObj < countTempData) then
    for i = 1, countTempData - countTempObj do
      local brandItem = self:CreateWidgetByPrefab(WardrobeBrandItem, self._brandObj, self._container);
      brandItem.parent = self
      table.insert(self.brandItemList,brandItem)
    end
  end

  for k,v in pairs(self.brandItemList) do
    if (self.stateBean.brandList[k] ~= nil) then
      CS.Torappu.Lua.Util.SetActiveIfNecessary(v:RootGameObject(),true)
      v:Render(self.stateBean.brandList[k])
    else
      CS.Torappu.Lua.Util.SetActiveIfNecessary(v:RootGameObject(),false)
    end
  end
end

function WardrobeSortBySkinGroupState:OnEffect()
  self._rootCanvas.blocksRaycasts = true
  self.effectFlag = true
end

function WardrobeSortBySkinGroupState:OnClose()
  self.brandItemList = {}
  WardrobeSortBySkinGroupState.initFlag = false
end