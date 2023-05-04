
WardrobeTimeItem = Class("WardrobeTimeItem", UIPanel);

WardrobeTimeItem.ANIM_PARAM = "sortByTimeEntry"

function WardrobeTimeItem:InitIfNot()
  if (self.initFlag) then
    return
  end

  self.initFlag = true
  self.skinItemList = {}

  for i = 1, 5 do
    local skinItem = self:CreateWidgetByPrefab(WardrobeSkinItem, self._skinObj, self._container);
    table.insert(self.skinItemList,skinItem)
  end
  self.effectFlag = false
end

function WardrobeTimeItem:Render(time,skinList, showTime)
  self:InitIfNot()
  self.m_cacheTime = time
  for i = 1, 5 do
    CS.Torappu.Lua.Util.SetActiveIfNecessary(self.skinItemList[i].m_root,false)
  end
  if (not showTime) then
    CS.Torappu.Lua.Util.SetActiveIfNecessary(self._timePart,false)
  else
    CS.Torappu.Lua.Util.SetActiveIfNecessary(self._timePart,true)
    self._yearText.text =  string.format("Y-%s",time.year)
    self._monthText.text = string.format("%02d",time.period)
  end
  for index,skin in pairs(skinList)do
    local skinItem = self.skinItemList[index]
    if (skinItem~=nil) then
      CS.Torappu.Lua.Util.SetActiveIfNecessary(skinItem.m_root,true)
      skinItem:Render(skin)
    end
  end
end

function WardrobeTimeItem:SetUnGetFlag(flag)
  for index,skin in pairs(self.skinItemList)do
    skin:SetUnGetFlag(flag)
  end
end

function WardrobeTimeItem:ReleaseUI()
  if (self.effectFlag == true) then
    return
  end
  self.effectFlag = true
  self._animWrapper:PlayWithTween(WardrobeTimeItem.ANIM_PARAM )
end

function WardrobeTimeItem:ReturnUI()
  self.effectFlag = false
  self._animWrapper:SampleClipAtBegin(WardrobeTimeItem.ANIM_PARAM )
end

function WardrobeTimeItem:ReleaseEndUI()
  if (self.effectFlag == true) then
    return
  end
  self.effectFlag = true
  self._animWrapper:SampleClipAtEnd(WardrobeTimeItem.ANIM_PARAM )
end

function WardrobeTimeItem:OnClick(skinId)
  if(self.m_parent~=nil and self.m_parent.OnClick~=nil)then
    self.m_parent:OnClick(self.m_cacheTime,skinId)
  end
end