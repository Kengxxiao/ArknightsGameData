


local Act4funLiveSidePanel = Class("Act4funLiveSidePanel", Act4funLivePanelBase);
Act4funLiveSidePanel.m_in = true;
Act4funLiveSidePanel.ANIM_DUR = 0.5;
Act4funLiveSidePanel.WIDTH = 370;

function Act4funLiveSidePanel:MoveInOut(toIn, fastMode)
  if self.m_in == toIn then
    return;
  end
  if self.m_tween and self.m_tween:IsAlive() then
    self.m_tween:Kill(false);
  end

  self.m_in = toIn;
  local rt = self:RootGameObject():GetComponent("RectTransform");

  if fastMode then
    self:SetVisible(toIn);
    local pos = rt.anchoredPosition;
    if toIn then
      pos.x = 0;
    else
      pos.x = self.WIDTH;
    end
    rt.anchoredPosition = pos;
    return;
  end
  self:_TweenTo(toIn, rt);
end

function Act4funLiveSidePanel:_TweenTo(toIn, rt)
  
  self:SetVisible(true);

  local from = rt.anchoredPosition.x;
  local to = self.WIDTH;
  if toIn then
    to = 0;
  end
  local this = self;

  self.m_tween = self:PlayTween({
    setFunc = function(lerpValue)
      local x = lerpValue * to + (1-lerpValue) * from;
      local pos = rt.anchoredPosition;
      pos.x = x;
      rt.anchoredPosition = pos;
    end,
    duration = self.ANIM_DUR,
    timeScaled = true,
    onComplete = function()
      this:SetVisible(toIn);
    end,
    easeFunc = TweenModel.EaseFunc.easeOutQuad,
  });
end

return Act4funLiveSidePanel;