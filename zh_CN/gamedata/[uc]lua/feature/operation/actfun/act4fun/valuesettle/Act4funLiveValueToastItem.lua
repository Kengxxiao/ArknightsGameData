local Act4funLiveValueChangeFlag = require "Feature/Operation/ActFun/Act4fun/ValueSettle/Act4funLiveValueChangeFlag";














local Act4funLiveValueToastItem = Class ("Act4funLiveValueToastItem", UIPanel);
Act4funLiveValueToastItem.FADE_DUR = 0.5;
Act4funLiveValueToastItem.LAYOUT_DUR = 0.5;

function Act4funLiveValueToastItem:OnInit()
  self.m_fadeTween = CS.Torappu.UI.FadeSwitchTween(self._contentCanvas);
  self.m_fadeTween.duration = self.FADE_DUR;
  self.m_fadeTween:Reset(false);

  self.m_changeFlag = self:CreateWidgetByGO(Act4funLiveValueChangeFlag, self._changeFlag);
  self.m_valueIconDict = {};
  self.m_valueIconDict[Act4funLiveData.VALUE1_ID] = self._value1Icon;
  self.m_valueIconDict[Act4funLiveData.VALUE2_ID] = self._value2Icon;
  self.m_valueIconDict[Act4funLiveData.VALUE3_ID] = self._value3Icon;
end


function Act4funLiveValueToastItem:Render(model)
  for vid, icon in pairs(self.m_valueIconDict) do
    SetGameObjectActive(icon, vid == model.valueId);
  end
  self.m_changeFlag:Render(model.valueChange, model.threshold);
  if model.valueData then
    if model.valueChange > 0 then
      self._desc.text = CS.Torappu.Lua.Util.FormatRichTextFromData(model.valueData.increaseToastTxt);
    else
      self._desc.text = CS.Torappu.Lua.Util.FormatRichTextFromData(model.valueData.decreaseToastTxt);
    end
  else
    self._desc.text = "";
  end
end

function Act4funLiveValueToastItem:SetVisibleCoroutine(visible)
  
  self.m_fadeTween.isShow = visible;
  
  
  if not visible then
    local this = self;
    self.m_layoutTween = self:PlayTween({
      setFunc = function(lerpValue)
        local height = lerpValue * 0 + (1-lerpValue) * this._preferredHeight;
        self._layout.preferredHeight = height;
      end,
      duration = self.LAYOUT_DUR,
      timeScaled = true,
    });
    
    
    
  end

  YieldWaitForSeconds(self.FADE_DUR);
  while self.m_layoutTween and self.m_layoutTween:IsAlive() do
    coroutine.yield();
  end

end

function Act4funLiveValueToastItem:Reset(idx)
  self._layout.preferredHeight = self._preferredHeight;
  if self.m_layoutTween then
    self:KillTween(self.m_layoutTween);
    self.m_layoutTween = nil;
  end
  self:RootGameObject().transform:SetSiblingIndex(idx);
end


return Act4funLiveValueToastItem;