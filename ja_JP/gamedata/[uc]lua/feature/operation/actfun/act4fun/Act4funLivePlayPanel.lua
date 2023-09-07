





local Act4funLivePlayPanel = Class("Act4funLivePlayPanel", Act4funLivePanelBase)
Act4funLivePlayPanel.ANIM_DUR = 2;


function Act4funLivePlayPanel:OnViewModelUpdate(data)

  local waiting = data.currStep == Act4funLiveStep.WAIT_PHOTO or data.currStep == Act4funLiveStep.PHOTO_USE_ANIM;
  SetGameObjectActive(self._playingNode, not waiting);
  SetGameObjectActive(self._suspendNode, waiting);


  local newValue = data.currTurn / data.maxTurn;
  if data.currStep == Act4funLiveStep.TURN_UPDATE then
    self:_TweenBarTo(newValue);
  else
    self:_SetBar(newValue);
    self._turnInfo.text = data.currTurn .. "/" .. data.maxTurn;
  end
end

function Act4funLivePlayPanel:_TweenBarTo(value)
  if self.m_tween then
    self.m_tween:Kill(false);
  end

  local from = self._turnBar.value;
  local to = value;

  local this = self;
  self.m_tween = self:PlayTween({
    setFunc = function(lerpValue)
      local v = lerpValue * to + (1-lerpValue) * from;
      this:_SetBar(v);
    end,
    duration = self.ANIM_DUR,
    timeScaled = true,
    onComplete = function()
      this._turnInfo.text = this.m_cachedData.currTurn .. "/" .. this.m_cachedData.maxTurn;
      this:_SetBar(to);
      this.m_cachedData:CompleteTurnUpdate()
    end
    
  });
end

function Act4funLivePlayPanel:_SetBar(value)
  self._turnBar.value = value;
end

return Act4funLivePlayPanel;
