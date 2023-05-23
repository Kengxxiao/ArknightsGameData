



FloatParadeProbDetailPanel = Class("FloatParadeProbDetailPanel", UIPanel);

function FloatParadeProbDetailPanel:OnInit()
end



function FloatParadeProbDetailPanel:UpdateRewards(data, fastMode)
  if not self.m_probItems then
    local lowStandard = data.actData.constData.lowStandard;
    self.m_probItems = {};
    for idx, reward in ipairs(data.todayRewards) do
      local item = self:CreateWidgetByPrefab(FloatParadeProbItem, self._probItemPrefab, self._probItemRoot);
      item.lowStandard = lowStandard;
      item:UpdateReward(reward, fastMode, idx == #data.todayRewards);
      table.insert(self.m_probItems, item);
    end
  else
    local validCount = math.min(#self.m_probItems, #data.todayRewards);
    for idx = 1, validCount do
      local item = self.m_probItems[idx];
      local reward = data.todayRewards[idx];
      item:UpdateReward(reward, fastMode, idx == validCount);
    end
  end
end













FloatParadeProbItem = Class("FloatParadeProbItem", UIWidget)
FloatParadeProbItem.ANIM_DUR = 0.5;


function FloatParadeProbItem:UpdateReward(rewardInfo, fastMode, lastOne)
  local pool = rewardInfo.rewardPool;
  self._desc.text = pool.desc;
  self._itemCount.text = "×" ..pool.reward.count;
  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._line, not lastOne);

  local alphaFrom = self._canvasGrp.alpha;
  local alphaTo = 0.3;
  if rewardInfo.var > self.lowStandard or rewardInfo.var == 0 then
    alphaTo = 1
  end

  if self.m_tween then
    self.m_tween:Kill(false);
  end
  
  if rewardInfo.var == 0 or fastMode then
    self:_SetPrgValue(rewardInfo.var);
    self._canvasGrp.alpha = alphaTo;
  else
    local this = self;
    local from = self.m_prgValue or 0;
    local to = rewardInfo.var;
    self.m_tween = TweenModel:Play({
      setFunc = function(lerpValue)
        local v = lerpValue * to + (1-lerpValue) * from;
        this:_SetPrgValue(v);
        local alphaV = lerpValue * alphaTo + (1-lerpValue)*alphaFrom;
        this._canvasGrp.alpha = alphaV;
      end,
      duration = self.ANIM_DUR,
      onComplete = function()
        this:_SetPrgValue(rewardInfo.var);
        this._canvasGrp.alpha = alphaTo;
      end,
      easeFunc = TweenModel.EaseFunc.easeOutQuad,
    });
  end
end

function FloatParadeProbItem:_SetPrgValue(value)
  self.m_prgValue = value;
  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._grpZero, value == 0);
  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._grpUp.gameObject, value > 0);
  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._grpDown.gameObject, value < 0);

  if value >= 0 then
    self._grpUp.value = value;
  else
    self._grpDown.value = -value;
  end
end
