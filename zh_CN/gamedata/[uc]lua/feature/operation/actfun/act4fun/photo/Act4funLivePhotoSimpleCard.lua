local Act4funLiveValueChangeFlag = require "Feature/Operation/ActFun/Act4fun/ValueSettle/Act4funLiveValueChangeFlag";










local Act4funLivePhotoSimpleCard = Class("Act4funLivePhotoSimpleCard", UIPanel)
Act4funLivePhotoSimpleCard.emojiHubPath = nil;
Act4funLivePhotoSimpleCard.photoHubPath = nil;

function Act4funLivePhotoSimpleCard:OnInit()
  local valuePrefabs = {self._value1, self._value2, self._value3};
  self.m_valueItems = {};
  for _, prefab in ipairs(valuePrefabs) do
    local item = self:CreateWidgetByGO(Act4funLiveValueChangeFlag, prefab);
    table.insert(self.m_valueItems, item);
  end

  self:OnSubInit();
end



function Act4funLivePhotoSimpleCard:Update(idx, photoData, selectIdx);
  if not Act4funLivePhotoSimpleCard.emojiHubPath then
    Act4funLivePhotoSimpleCard.emojiHubPath = CS.Torappu.ResourceUrls.GetAct4funEmojiHubPath();
  end
  if not Act4funLivePhotoSimpleCard.photoHubPath then
    Act4funLivePhotoSimpleCard.photoHubPath = CS.Torappu.ResourceUrls.GetAct4funPhotoHubPath();
  end

  self.m_idx = idx;

  self._name.text = photoData:GetName();
  self._tag.text = photoData:GetTag();
  self._cover.sprite = self:LoadSpriteFromAutoPackHub(Act4funLivePhotoSimpleCard.photoHubPath, photoData:GetPic());

  self._emoji.sprite = self:LoadSpriteFromAutoPackHub(Act4funLivePhotoSimpleCard.emojiHubPath, photoData:GetEmoji());

  for idx, item in ipairs(self.m_valueItems) do
    local vid = Act4funLiveData.VALUE_ID_LIST[idx];
    local valueChange = photoData:GetValueChange(vid, true);
    item:Render(valueChange, photoData.valueThreshold);
  end
  
  self:OnUpdate(idx, photoData, selectIdx);
end


function Act4funLivePhotoSimpleCard:OnSubInit()
end


function Act4funLivePhotoSimpleCard:OnUpdate(idx, photoData, selectIdx)
end


return Act4funLivePhotoSimpleCard;