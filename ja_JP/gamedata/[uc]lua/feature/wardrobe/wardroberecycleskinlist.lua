WardrobeRecycleSkinList = Class("WardrobeRecycleSkinList", UIRecycleAdapterBase);

function WardrobeRecycleSkinList:GetTotalCount()
  if (self.viewModelList == nil) then
    return 0
  end
  return #self.viewModelList
end

function WardrobeRecycleSkinList:ViewConstructor(objPool)
  local timeItem = self:CreateWidgetByPrefab(WardrobeTimeItem, self._timeObj, self._container);
  self:AddObj(timeItem,timeItem.m_root)
  return timeItem.m_root
end

function WardrobeRecycleSkinList:ResetToTop()
  self._loopScroll.verticalNormalizedPosition = 0
end

function WardrobeRecycleSkinList:OnRender(transform, index)
  local timeItem = self:GetWidget(transform.gameObject)
  timeItem:Render(self.viewModelList[index + 1].time, self.viewModelList[index + 1].skinList, self.viewModelList[index + 1].showTime)
  timeItem:SetUnGetFlag(self.overwriteFlag and self.showUnGetFlag)
  if (self.effectState >= 0) then
    if (index < self.effectState) then
      timeItem:ReleaseUI()      
    else
      timeItem:ReturnUI()
    end
  else
    timeItem:ReleaseEndUI()
  end
end

function WardrobeRecycleSkinList:OnClick(time, skinId)
  if(self.m_parent~=nil and self.m_parent.OnClick~=nil)then
    self.m_parent:OnClick(time, skinId)
  end
end