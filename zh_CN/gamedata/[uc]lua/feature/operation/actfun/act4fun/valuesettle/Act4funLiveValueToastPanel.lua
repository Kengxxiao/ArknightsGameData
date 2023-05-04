local Act4funLiveValueToastItem = require "Feature/Operation/ActFun/Act4fun/ValueSettle/Act4funLiveValueToastItem";








local Act4funLiveValueToastPanel = Class("Act4funLiveValueToastPanel", UIPanel);
Act4funLiveValueToastPanel.ADD_INTERVAL = 0.2; 
Act4funLiveValueToastPanel.REMOVE_INTERVAL = 2;

function Act4funLiveValueToastPanel:OnInit()
  self.m_usingItems = {};
  self.m_idleItems = {};
end

function Act4funLiveValueToastPanel:IsPlaying()
  if self.m_addCoroutine and self.m_addCoroutine:IsAlive() then
    return true;
  end
  if self.m_removeCoroutine and self.m_removeCoroutine:IsAlive() then
    return true;
  end
  return false;
end

function Act4funLiveValueToastPanel:PlayValueChange(valueModel)
  if self:IsPlaying() then
    return;
  end
  self:SetVisible(true);
  self.m_addCoroutine = self:StartCoroutine(self._DoAddCoroutine, valueModel);
  self.m_removeCoroutine = self:StartCoroutine(self._DoRemoveCoroutine);
end


function Act4funLiveValueToastPanel:_DoAddCoroutine(valueModel)
  for _, vid in ipairs(Act4funLiveData.VALUE_ID_LIST) do
    local vc = valueModel.valueChangeInfo[vid];
    if vc and vc.valueChange ~= 0 then
      local item = self:_FetchItem();
      item:Render(vc);
      CS.Torappu.TorappuAudio.PlayUI(AudioConsts.ACT4FUN_VALUE_TOAST);
      item:SetVisibleCoroutine(true);
      table.insert(self.m_usingItems, item);
      YieldWaitForSeconds(self.ADD_INTERVAL);
    end
  end
  self.m_addCoroutine = self:StopCoroutine(self.m_addCoroutine);
end

function Act4funLiveValueToastPanel:_DoRemoveCoroutine()
  local lastRemoveTime = CS.UnityEngine.Time.time;
  while self.m_addCoroutine ~= nil or #self.m_usingItems > 0 do
    while #self.m_usingItems > 0 do
      local currTime = CS.UnityEngine.Time.time;
      local passTime = currTime - lastRemoveTime;
      local needWaite = self.REMOVE_INTERVAL - passTime;
      if needWaite > 0 then
        YieldWaitForSeconds(needWaite);
      end
      lastRemoveTime = CS.UnityEngine.Time.time;
      local item = table.remove(self.m_usingItems, 1);
      item:SetVisibleCoroutine(false);
      table.insert(self.m_idleItems, item);
    end
    coroutine.yield();
  end

  self:SetVisible(false);
  self.m_removeCoroutine = self:StopCoroutine(self.m_removeCoroutine);
end

function Act4funLiveValueToastPanel:_FetchItem()
  local idleCnt = 0;
  if self.m_idleItems ~= nil then
    idleCnt = #self.m_idleItems;
  end

  
  local item = nil;
  if idleCnt > 0 then
    item = table.remove(self.m_idleItems, 1);
  else
    item = self:CreateWidgetByPrefab(Act4funLiveValueToastItem, self._itemPrefab, self._itemContainer);
  end
  item:Reset(#self.m_usingItems);
  return item;
end


return Act4funLiveValueToastPanel;