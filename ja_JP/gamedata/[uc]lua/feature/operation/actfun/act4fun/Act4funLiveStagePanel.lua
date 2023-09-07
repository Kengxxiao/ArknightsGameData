local Act4funLivePhotoCard = require "Feature/Operation/ActFun/Act4fun/Photo/Act4funLivePhotoCard";











local Act4funLiveStagePanel = Class("Act4funLiveStagePanel", Act4funLivePanelBase);
Act4funLiveStagePanel.WORD_BG_DEFAULT = "talk_background";


function Act4funLiveStagePanel:OnInit()
  self.m_photoCard = self:CreateWidgetByPrefab(Act4funLivePhotoCard, self._photoCardPrefab, self._photoCardContainer);

  self.m_wordBgs = 
  {
    { name = "talk_background", node = self._popTalk },
    { name = "think_background", node = self._popThink },
  }
end


function Act4funLiveStagePanel:OnViewModelUpdate(data)

  if data.currStep == Act4funLiveStep.ONLINE then
    self:_SetChar();
  end

  
  local showPhoto = data.currStep == Act4funLiveStep.PHOTO_PERFORM;
  self.m_photoCard:SetVisible(showPhoto);
  if showPhoto and data.usingPhoto then
    self.m_photoCard:Update(-1, data.usingPhoto, nil);
  end

  
  self.m_currPerform = data.currPerform;
  local inPerform = data:InPerform();
  if not inPerform then
    self:_SetChar();
    return;
  end
  if self.m_playing then
    return;
  end

  self:_TryPlay();
end

function Act4funLiveStagePanel:_TryPlay()
  local perform = self.m_currPerform;

  self.m_playing = false;
  if perform == nil then
    return;
  end
  local wordData = perform:NextWord();
  if not wordData then
    
    local finishAvg = perform.data.performFinishedPicId;
    if finishAvg ~= nil and finishAvg ~= "" then
      self:_SetChar(finishAvg);
    end
    
    self.m_cachedData:CompletePerform();
    return;
  end
  
  
  self:_SetChar(wordData.picId);
  
  local bgId = wordData.backgroundId;
  if bgId == nil or bgId == "" then
    bgId = self.WORD_BG_DEFAULT;
  end
  for _, bg in ipairs(self.m_wordBgs) do
    SetGameObjectActive(bg.node, bg.name == bgId);
  end
  
  self.m_playing = true;
  local this = self;
  self._wordsOut:BeginText(wordData.text, function()
    local interval = self.m_cachedData.actData.constant.subtitleIntervalTime;
    local timerID = this:Delay(interval, this._TryPlay);
    this:SetScaled(timerID);
  end);

end

function Act4funLiveStagePanel:OnClose()
  self.m_playing = false;
  self._wordsOut:OnReset();
end

function Act4funLiveStagePanel:_SetChar(charKey)
  if charKey == nil or charKey == "" then
    charKey = self.m_cachedData.actData.constant.defaultPerformPicId;
  end
  self._avgChar:SetCharacter({avgCharKey = charKey});
end

return Act4funLiveStagePanel;