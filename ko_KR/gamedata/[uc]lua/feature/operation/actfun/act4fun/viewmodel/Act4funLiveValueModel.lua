









local Act4funLiveValueModel = Class("Act4funLiveValueModel");

function Act4funLiveValueModel:Init(actData)
  self.valueLimit = actData.constant.liveValueAbsLimit;

  local valueThreshold = actData.constant.liveMatAttribIconDiffNum;

  self.currValueInfo = {}
  self.valueChangeInfo = {}
  for _, vid in ipairs(Act4funLiveData.VALUE_ID_LIST) do
    self.currValueInfo[vid] = 0;
    
    local suc, vdata = actData.liveValueInfoDict:TryGetValue(vid);
    if not suc then
      vdata = nil;
    end
    
    
    local changeModel = {
      valueId = vid,
      valueChange = 0,
      threshold = valueThreshold,
      valueData = vdata,
    }
    self.valueChangeInfo[vid] = changeModel;
  end
end


function Act4funLiveValueModel:SettlePhoto(photoData)
  
  for vid, vc in pairs(self.valueChangeInfo) do
    local valueChange = photoData:GetValueChange(vid);
    if valueChange == nil then
      valueChange = 0;
    end
    vc.valueChange = valueChange;
    self:_ApplyValueChange(vid, valueChange);
  end
end



function Act4funLiveValueModel:SettleSC(scItemModel, actData)

  local valueEffectId = scItemModel.effectId;
  local suc, vEffect = actData.valueEffectInfoDict:TryGetValue(valueEffectId);
  if not suc then
    LogError(scItemModel.id .. " can't find the effect info:"..valueEffectId);
  end

  
  for vid, vc in pairs(self.valueChangeInfo) do
    local suc, valueChange = vEffect.effectParams:TryGetValue(vid);
    if not suc then
      valueChange = 0;
    end
    vc.valueChange = valueChange;
    self:_ApplyValueChange(vid, valueChange);
  end
end

function Act4funLiveValueModel:_ApplyValueChange(vid, valueChange)
  if valueChange == nil or valueChange == 0 then
    return;
  end

  local curValue = self.currValueInfo[vid];
  curValue = curValue + valueChange;
  self.currValueInfo[vid] = curValue;
end


function Act4funLiveValueModel:GetValueStatus(vid)
  local value = self.currValueInfo[vid];
  return self:_CheckBreak(value);
end

function Act4funLiveValueModel:HasValueBreak()
  for vid, value in pairs(self.currValueInfo) do
    if self:_CheckBreak(value) ~= 0 then
      return true;
    end
  end
  return false;
end

function Act4funLiveValueModel:NormalizeValue(value)
  local range = self.valueLimit + self.valueLimit;
  local relative = value + self.valueLimit;
  local nor = relative / range;
  nor = math.max(nor, 0);
  nor = math.min(nor, 1);
  return nor;
end


function Act4funLiveValueModel:_CheckBreak(value)
  if value >= self.valueLimit then
    return 1;
  end
  if value <= -self.valueLimit then
    return -1;
  end
  return 0;
end



function Act4funLiveValueModel:BuildToastItemModel(vid)
  local valueChange = self.valueChangeInfo[vid];
  if valueChange == nil or valueChange == 0 then
    return nil;
  end
  local vData = self.m_valueDataDict[vid];
  if not vData then
    return nil;
  end
  
  local ret = {
    threshold = self.valueThreshold;
    valueChange = valueChange;
    valueData = vData;
  };
  return ret;
end

return Act4funLiveValueModel;