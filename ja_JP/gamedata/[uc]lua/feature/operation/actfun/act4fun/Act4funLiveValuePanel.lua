local Act4funLiveValueToastPanel = require "Feature/Operation/ActFun/Act4fun/ValueSettle/Act4funLiveValueToastPanel";














local Act4funLiveValuePanel = Class("Act4funLiveValuePanel", Act4funLivePanelBase);
Act4funLiveValuePanel.TWEEN_BAR_DUR = 1;
Act4funLiveValuePanel.BOOM_ANIM = "act4fun_live_value_boom";

function Act4funLiveValuePanel:OnInit()
  self.m_valueImgDict = {};
  self.m_valueImgDict[Act4funLiveData.VALUE1_ID] = self._value1Prg;
  self.m_valueImgDict[Act4funLiveData.VALUE2_ID] = self._value2Prg;
  self.m_valueImgDict[Act4funLiveData.VALUE3_ID] = self._value3Prg;
  self.m_boomAnimDict = {};
  self.m_boomAnimDict[Act4funLiveData.VALUE1_ID] = self._value1Boom;
  self.m_boomAnimDict[Act4funLiveData.VALUE2_ID] = self._value2Boom;
  self.m_boomAnimDict[Act4funLiveData.VALUE3_ID] = self._value3Boom;

  self.m_toastPanel = self:CreateWidgetByGO(Act4funLiveValueToastPanel, self._toastNode);
end



function Act4funLiveValuePanel:OnViewModelUpdate(data)
  local inValueSettle = data.currStep == Act4funLiveStep.VALUE_SETTLE;

  if not inValueSettle then
    
    local info = data.valueModel;
    for vid, value in pairs(info.currValueInfo) do
      local prg = self.m_valueImgDict[vid];
      if prg then
        prg.fillAmount = info:NormalizeValue(value);
      end
    end

    SetGameObjectActive(self._toastNode, false);
    SetGameObjectActive(self._breakNode, false);
    self:_ClearUpdateCoroutine();
    return;
  end

  self:_ClearUpdateCoroutine();
  self.m_updateCoroutine = self:StartCoroutine(self._UpdateCoroutine);
end

function Act4funLiveValuePanel:_ClearUpdateCoroutine()
  if self.m_updateCoroutine then
    self:StopCoroutine(self.m_updateCoroutine);
    self.m_updateCoroutine = nil;
  end
end

function Act4funLiveValuePanel:_UpdateCoroutine()
  
  local barInfos = {};
  local valueInfo = self.m_cachedData.valueModel;
  for vid, value in pairs(valueInfo.currValueInfo) do
    local prg = self.m_valueImgDict[vid];
    if prg then
      local info = {from = prg.fillAmount, to = valueInfo:NormalizeValue(value), vPrg = prg };
      table.insert(barInfos, info);
    end
  end

  local barTween = self:PlayTween({
    setFunc = function(lerpValue)
      for _, info in ipairs(barInfos) do
        local v = lerpValue * info.to + (1-lerpValue) * info.from;
        info.vPrg.fillAmount = v;
      end
    end,
    duration = self.TWEEN_BAR_DUR,
    timeScaled = true,
    
  });
  
  self.m_toastPanel:PlayValueChange(valueInfo);
  
  
  while barTween and barTween:IsAlive() do
    coroutine.yield();
  end
  while self.m_toastPanel:IsPlaying() do
    coroutine.yield();
  end

  
  if self.m_cachedData.valueModel:HasValueBreak() then
    SetGameObjectActive(self._breakNode, true);
    
    for vid, anim in pairs(self.m_boomAnimDict) do
      local valueState = self.m_cachedData.valueModel:GetValueStatus(vid);
      local valueBoom = valueState ~= 0;
      SetGameObjectActive(anim.gameObject, valueBoom);
      anim:InitIfNot();
      anim:Stop(self.BOOM_ANIM, false);
      if valueBoom then
        anim:Play(self.BOOM_ANIM,{
          isInverse = valueState < 0,
        });
        if valueState > 0 then
          CS.Torappu.TorappuAudio.PlayUI(AudioConsts.ACT4FUN_VALUE_BOOM_UP);
        else
          CS.Torappu.TorappuAudio.PlayUI(AudioConsts.ACT4FUN_VALUE_BOOM_LOW);
        end
      end
    end
    
    for _, anim in pairs(self.m_boomAnimDict) do
      while anim:IsPlaying(self.BOOM_ANIM) do
        coroutine.yield();
      end
    end
    SetGameObjectActive(self._breakNode, false);
  end

  self.m_updateCoroutine = nil;

  
  self.m_cachedData:CompleteValueSettle();
end

return Act4funLiveValuePanel;