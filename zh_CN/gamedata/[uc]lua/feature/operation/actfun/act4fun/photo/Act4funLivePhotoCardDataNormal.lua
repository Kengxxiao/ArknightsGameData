local Act4funLivePhotoCardData = require "Feature/Operation/ActFun/Act4fun/Photo/Act4funLivePhotoCardData"











local Act4funLivePhotoCardDataNormal = Class("Act4funLivePhotoCardDataNormal", Act4funLivePhotoCardData)



function Act4funLivePhotoCardDataNormal:Load(actData, data)
  self.matData = data
  self.playerDataList = {};
  self.valueThreshold = actData.constant.liveMatAttribIconDiffNum;
end
         

function Act4funLivePhotoCardDataNormal:SetMat(normalCardList)
  self.playerDataList = normalCardList;
  for _,v in pairs(normalCardList) do
    local suc, effect = self.matData.effectInfos:TryGetValue(v.normalEffect.sign);
    if suc then
      self.m_valueId = effect.valueId;
      break;
    end
  end
end


function Act4funLivePhotoCardDataNormal:CollectMaterial(playerData)
  table.insert(self.playerDataList, playerData);

  if #self.playerDataList == 1 then
    local suc, effect = self.matData.effectInfos:TryGetValue(playerData.normalEffect.sign);
    if suc then
      self.m_valueId = effect.valueId;
    end
  end
end

function Act4funLivePhotoCardDataNormal:IsSpecial()
  return false;
end

function Act4funLivePhotoCardDataNormal:GetID()
  return self.matData.liveMatId;
end

function Act4funLivePhotoCardDataNormal:GetName()
  return self.matData.name;
end

function Act4funLivePhotoCardDataNormal:GetPic()
  return self.matData.picId;
end

function Act4funLivePhotoCardDataNormal:GetTag()
  return self.matData.tagTxt;
end

function Act4funLivePhotoCardDataNormal:GetEmoji()
  return self.matData.emojiIcon
end

function Act4funLivePhotoCardDataNormal:GetSelectPerform()
  return self.matData.selectedPerformId;
end

function Act4funLivePhotoCardDataNormal:GetCount()
  return #self.playerDataList;
end

function Act4funLivePhotoCardDataNormal:UseOne()
  local cnt = self:GetCount();
  if cnt <= 0 then
    return false;
  end
  local useIdx = RandomUtil.Range(1, cnt);
  self.usingPlayerData = table.remove(self.playerDataList, useIdx);

  local suc, effect = self.matData.effectInfos:TryGetValue(self.usingPlayerData.normalEffect.sign);
  if not suc then
    LogError(self.matData.liveMatId .. "Can't find the effect info:"..self.usingPlayerData.type);
    return false;
  end
  self.usingEffectData = effect;
  return true;
end

function Act4funLivePhotoCardDataNormal:GetUsingInstId()
  if not self.usingPlayerData then
    return 0;
  end
  return self.usingPlayerData.instId;
end

function Act4funLivePhotoCardDataNormal:GetPerformGrpId()
  return self.usingEffectData.performGroup;
end

function Act4funLivePhotoCardDataNormal:GetValueChange(vid, forCard)
  if not vid then
    return 0;
  end

  if self.m_valueId ~= vid then
    return 0;
  end

  if forCard then
    return nil;
  end

  return self.usingPlayerData.normalEffect.addon;
end

return Act4funLivePhotoCardDataNormal