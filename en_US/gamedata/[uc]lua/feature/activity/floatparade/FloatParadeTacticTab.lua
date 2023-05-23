










FloatParadeTacticTab = Class("FloatParadeTacticTab", UIWidget);

FloatParadeTacticTab.SWTICH_ANIM = "float_parade_tab_switch_anim";
FloatParadeTacticTab.DEFAULT_TO_SEL_ANIM = "float_parade_tab_default_to_selected";
FloatParadeTacticTab.DEFAULT_TO_UN_ANIM = "float_parade_tab_default_to_unselected";
local TabState = {
  DEFAULT = 0,
  UNSELECTED = 1,
  SELECTED = 2,

  DEFAULT_UNSELECTED = 0|1,
  DEFAULT_SELECTED = 0|2,
  SELECT_SWITCH = 1|2,
}
Readonly(TabState);

function FloatParadeTacticTab:OnInitialize()
  self:AddButtonClickListener(self._btnTab, self._HandleSelectClick);
  self:AddButtonClickListener(self._btnConfirm, self._HandleConfirmClick);

  self.m_state = TabState.SELECTED;
end



function FloatParadeTacticTab:Render(idx, tacticData)
  self.m_tacticIdx = idx;
  self._labelName.text = tacticData.name;
  self._labelPackName.text = tacticData.packName;
  self._briefName.text = tacticData.briefName;
end

function FloatParadeTacticTab:UpdateSelected(selectedIdx, fastMode)

  local state = TabState.DEFAULT;
  if self.m_tacticIdx == selectedIdx then
    state = TabState.SELECTED;
  elseif selectedIdx == -1 then
    state = TabState.DEFAULT;
  else
    state = TabState.UNSELECTED;
  end
  if self.m_state == state then
    return;
  end
  local fromState = self.m_state;
  local toState = state;
  self.m_state = state;
  self:_Swtich(fromState, toState, fastMode);
end

function FloatParadeTacticTab:_Swtich(fromState, toState, fastMode)
  self._switchAnim:InitIfNot();
  self._switchAnim:Stop(self.SWTICH_ANIM, false);
  self._switchAnim:Stop(self.DEFAULT_TO_SEL_ANIM, false);
  self._switchAnim:Stop(self.DEFAULT_TO_UN_ANIM, false);

  if toState == TabState.DEFAULT then
    self._switchAnim:SampleClipAtBegin(self.DEFAULT_TO_SEL_ANIM);
    return;
  end

  if fastMode then
    if toState == TabState.DEFAULT then
      self._switchAnim:SampleClipAtBegin(self.DEFAULT_TO_SEL_ANIM);
    elseif toState == TabState.SELECTED then
      self._switchAnim:SampleClipAtEnd(self.SWTICH_ANIM);
    else
      self._switchAnim:SampleClipAtBegin(self.SWTICH_ANIM);
    end
    return;
  end
  
  local animName = self.SWTICH_ANIM;
  local inverse = false;
  local proc = fromState | toState;
  if proc == TabState.DEFAULT_SELECTED then
    animName = self.DEFAULT_TO_SEL_ANIM;
    inverse = toState ~= TabState.SELECTED;
  elseif proc == TabState.DEFAULT_UNSELECTED then
    animName = self.DEFAULT_TO_UN_ANIM;
    inverse = toState ~= TabState.UNSELECTED;
  else
    animName = self.SWTICH_ANIM;
    inverse = toState ~= TabState.SELECTED;
  end

  self._switchAnim:Play(animName, {
    isFillAfter = true,
    isInverse = inverse,
  });
end

function FloatParadeTacticTab:_HandleSelectClick()
  if self.selectTacticEvent then
    self.selectTacticEvent:Call(self.m_tacticIdx);
  end
end

function FloatParadeTacticTab:_HandleConfirmClick()
  if self.confirmTacticEvent then
    self.confirmTacticEvent:Call(self.m_tacticIdx);
  end
end