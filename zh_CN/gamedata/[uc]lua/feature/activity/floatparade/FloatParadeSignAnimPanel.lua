










local FloatParadeSignAnimPanel = Class("FloatParadeSignAnimPanel", UIPanel);
FloatParadeSignAnimPanel.ANIM_DEFAULT_ENTRY = "sign_contract_normal_entry";
FloatParadeSignAnimPanel.ANIM_DEFAULT_LOOP = "sign_contract_normal_loop";
FloatParadeSignAnimPanel.ANIM_DEFAULT_END = "sign_contract_normal_end";
FloatParadeSignAnimPanel.ANIM_EXT = "sign_contract_sponser";

function FloatParadeSignAnimPanel:OnClose()
  self:_ClearAnim();
  if self.m_co and self.m_co:IsAlive() then
    CoroutineModel.me:StopCoroutine(self.m_co);
  end
end

function FloatParadeSignAnimPanel:PlaySignAnim()
  if self.m_co and self.m_co:IsAlive() then
    CoroutineModel.me:StopCoroutine(self.m_co);
  end
  self.m_co = CoroutineModel.me:StartCoroutine(self._PlaySignAnim, self);
end

function FloatParadeSignAnimPanel:FlushData(data, rewardCount, extRewardCount, evtComplete)
  self.m_data = {
    mainModel = data,
    rewardCnt = rewardCount,
    extRewardCnt = extRewardCount,
    evtEnd = evtComplete;
  };
end

function FloatParadeSignAnimPanel:_PlaySignAnim()
  self:_ClearAnim();

  self.m_data = nil;
  self:_PlayAnim(self.ANIM_DEFAULT_ENTRY);
  while self.m_data == nil do
    self:_PlayAnim(self.ANIM_DEFAULT_LOOP);
  end
  self:_UpdateUI();
  self:_PlayAnim(self.ANIM_DEFAULT_END);

  if self.m_data.extRewardCnt > 0 then
    self:_PlayAnim(self.ANIM_EXT);
  end

  if self.m_data.evtEnd then
    self.m_data.evtEnd:Call();
  end
end

function FloatParadeSignAnimPanel:_UpdateUI()
  local data = self.m_data.mainModel;
  local rewardCount = self.m_data.rewardCnt;
  local extRewardCount = self.m_data.extRewardCnt;
  
  if data.todayResult then
    local SIGN_TYPES = {
      normal = self._normalSign,
      rare = self._rareSign,
      epic = self._epicSign,
      legend = self._legendSign,
    };
    local curType = data.todayResult.reward.type;
    for type, signNode in pairs(SIGN_TYPES) do
      CS.Torappu.Lua.Util.SetActiveIfNecessary(signNode, type == curType);
    end
  end
  if data.todayData then
    self._placeName.text = data.todayData.placeEnName;
  end

  self._rewardCount.text = tostring(rewardCount);
  self._extCount.text = tostring(extRewardCount);
end

function FloatParadeSignAnimPanel:_ClearAnim()
  self._animWrap:Stop(self.ANIM_DEFAULT_ENTRY);
  self._animWrap:Stop(self.ANIM_DEFAULT_LOOP);
  self._animWrap:Stop(self.ANIM_DEFAULT_END);
  self._animWrap:Stop(self.ANIM_EXT);
end

function FloatParadeSignAnimPanel:_PlayAnim(animName)
  local complete = false;
  local option = {
    isFillAfter = true,
    isInverse = false,
    onAnimEnd = function()
      complete = true;
    end,
  }
  self._animWrap:Play(animName, option);
  while not complete do
    coroutine.yield();
  end
end

return FloatParadeSignAnimPanel;