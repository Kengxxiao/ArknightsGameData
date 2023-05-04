local Act4funLivePhotoSimpleCard = require "Feature/Operation/ActFun/Act4fun/Photo/Act4funLivePhotoSimpleCard";














local Act4funLivePhotoCard = Class("Act4funLivePhotoCard", Act4funLivePhotoSimpleCard);

function Act4funLivePhotoCard:OnSubInit()
  self.m_rt = self:RootGameObject():GetComponent("RectTransform");
  self.m_size = self.m_rt.sizeDelta;

  self:AddButtonClickListener(self._btnSelect, self._HandleSelect);
  self:AddButtonClickListener(self._btnConfirm, self._HandleConfirm);
end



function Act4funLivePhotoCard:OnUpdate(idx, photoData, selectIdx);
  self.m_idx = idx;

  
  local photoCount = photoData:GetCount();
  local showCnt = idx >= 0 and photoCount > 1;
  SetGameObjectActive(self._countNode, showCnt);
  if showCnt then
    self._count.text = "X".. photoCount;
  end
  
  self:UpdateSelect(selectIdx);
end

function Act4funLivePhotoCard:UpdateSelect(selectIdx)
  SetGameObjectActive(self._selectMask, self.m_idx == selectIdx);
end


function Act4funLivePhotoCard:GetVertRange()
  local posY = -self.m_rt.anchoredPosition.y;
  local halfH = self.m_size.y /2;
  return {from = posY - halfH, to = posY + halfH};
end

function Act4funLivePhotoCard:_HandleSelect()
  if self.evtClick then
    self.evtClick:Call(self, self.m_idx);
  end
end

function Act4funLivePhotoCard:_HandleConfirm()
  if self.evtConfirm then
    self.evtConfirm:Call(self, self.m_idx);
  end
end

function Act4funLivePhotoCard:GetUIScaler()
  return self._uiscaler;
end

return Act4funLivePhotoCard;