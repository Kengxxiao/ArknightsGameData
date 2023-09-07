local Act4funLivePhotoCardData = require "Feature/Operation/ActFun/Act4fun/Photo/Act4funLivePhotoCardData"







local Act4funLivePhotoCardDataSpecial = Class("Act4funLivePhotoCardDataSpecial", Act4funLivePhotoCardData)




function Act4funLivePhotoCardDataSpecial:Load(actData, data, playerData)
  self.spMatData = data;
  self.m_count = 1;
  self.m_playerData = playerData;
  self.valueThreshold = actData.constant.liveMatAttribIconDiffNum;

  local suc, vEffect = actData.valueEffectInfoDict:TryGetValue(data.valueEffectId);
  if not suc then
    LogError(data.spLiveMatId .. " can't find the effect info:"..data.valueEffectId);
  end
  self.valueEffect = vEffect;
end

function Act4funLivePhotoCardDataSpecial:IsSpecial()
  return true;
end

function Act4funLivePhotoCardDataSpecial:GetID()
  return self.spMatData.spLiveMatId;
end

function Act4funLivePhotoCardDataSpecial:GetName()
  return self.spMatData.name;
end

function Act4funLivePhotoCardDataSpecial:GetPic()
  return self.spMatData.picId;
end

function Act4funLivePhotoCardDataSpecial:GetTag()
  return self.spMatData.tagTxt;
end

function Act4funLivePhotoCardDataSpecial:GetEmoji()
  return self.spMatData.emojiIcon
end

function Act4funLivePhotoCardDataSpecial:GetSelectPerform()
  return self.spMatData.selectedPerformId;
end

function Act4funLivePhotoCardDataSpecial:GetCount()
  return self.m_count;
end

function Act4funLivePhotoCardDataSpecial:UseOne()
  if not self.m_count or self.m_count <= 0 then
    return false;
  end
  self.m_count = self.m_count - 1;
  return true;
end

function Act4funLivePhotoCardDataSpecial:GetUsingInstId()
  return self.m_playerData.instId;
end

function Act4funLivePhotoCardDataSpecial:GetPerformId()
  return self.spMatData.accordingPerformId;
end

function Act4funLivePhotoCardDataSpecial:GetValueChange(vid, forCard)
  if not vid then
    return 0;
  end
  if self.valueEffect == nil then
    return 0;
  end
  local suc, value  = self.valueEffect.effectParams:TryGetValue(vid);
  if suc then
    return value;
  end
  return 0;
end

return Act4funLivePhotoCardDataSpecial;