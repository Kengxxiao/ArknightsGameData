local Act4funLiveSidePanel = require "Feature/Operation/ActFun/Act4fun/Act4funLiveSidePanel";
local Act4funLivePhotoCard = require "Feature/Operation/ActFun/Act4fun/Photo/Act4funLivePhotoCard";










local Act4funLivePhotoPanel = Class("Act4funLivePhotoPanel", Act4funLiveSidePanel)
Act4funLivePhotoPanel.SCROLL_DUR = 0.3;

function Act4funLivePhotoPanel:OnInit()
  self:MoveInOut(false, true);

  self.m_cardListAdapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._cardListLayout, 
      self._CreateCard, self._GetCardCount, self._UpdateCard);
end


function Act4funLivePhotoPanel:OnViewModelUpdate(data)
  local inPhotoSelect = data:NeedShowPhotoPanel();
  self:MoveInOut(inPhotoSelect);
  if not inPhotoSelect then
    return;
  end

  local validCardCount = self:_GetCardCount();
  self.m_cardListAdapter:NotifyDataSetChanged();

  SetGameObjectActive(self._emptyNode, validCardCount <= 0);
  SetGameObjectActive(self._listNode, validCardCount > 0);
end

function Act4funLivePhotoPanel:_SelectPhoto(card, idx)
  if not self.m_cachedData:CanSelectPhoto() then
    return;
  end

  if self.m_slectIdx == idx then
    idx = 0;
  end

  self.m_slectIdx = idx;
  
  self.m_cardListAdapter:NotifyDataSetChanged();

  if idx == nil or idx == 0 then
    return;
  end
  
  
  local pos = self:_CalculatePos(card);
  if pos >= 0 then
    self:_ScrollTo(pos);
  end

  
  self.m_cachedData:SelectPhoto(idx);
end

function Act4funLivePhotoPanel:_ConfirmPhoto(card, idx)
  if not self.m_cachedData:CanSelectPhoto() then
    return;
  end

  self.m_cachedData:UsePhoto(idx);
  self.m_slectIdx = 0;
end

function Act4funLivePhotoPanel:_CalculatePos(selectCard)
  if not selectCard then
    return -1;
  end
  local cardRange = selectCard:GetVertRange();
  local contentH = self._scrollView.content.rect.height;
  local viewH = self._scrollView.viewport.rect.height;
  local norPos = 1- self._scrollView.verticalNormalizedPosition;
  local viewFrom = math.max(0,  (contentH - viewH) * norPos);
  local viewTo = viewFrom + viewH;

  if viewFrom > cardRange.from and viewFrom < cardRange.to then
    local vertNorPos = cardRange.from / (contentH - viewH);
    return 1 - vertNorPos;
  end
  if viewTo > cardRange.from and viewTo < cardRange.to then
    local vertNorPos = (viewFrom + cardRange.to - viewTo) / (contentH - viewH);
    return 1 - vertNorPos;
  end
  return -1;
end

function Act4funLivePhotoPanel:_ScrollTo(vertNorPos)
  if self.m_scrollTween and self.m_scrollTween:IsAlive() then
    self.m_scrollTween:Kill(false);
  end

  local from = self._scrollView.verticalNormalizedPosition;
  
  local this = self;
  self:PlayTween({
    setFunc = function(lerpValue)
      local pos = lerpValue * vertNorPos + (1-lerpValue) * from;
      this._scrollView.verticalNormalizedPosition = pos;
    end,
    duration = self.SCROLL_DUR,
    timeScaled = true,
    
  });
end



function Act4funLivePhotoPanel:_CreateCard(gameObj)
  local card = self:CreateWidgetByGO(Act4funLivePhotoCard, gameObj)
  card.evtClick = Event.Create(self, self._SelectPhoto);
  card.evtConfirm = Event.Create(self, self._ConfirmPhoto);
  return card;
end

function Act4funLivePhotoPanel:_GetCardCount()
  if self.m_cachedData == nil or self.m_cachedData.photos == nil then
    return 0;
  end
  return #self.m_cachedData.photos;
end


function Act4funLivePhotoPanel:_UpdateCard(index, card)
  local idx = index + 1;
  card:Update(idx, self.m_cachedData.photos[idx], self.m_slectIdx)
end


return Act4funLivePhotoPanel