local luaUtils = CS.Torappu.Lua.Util;




















local Act4funLiveCommentScView = Class("Act4funLiveCommentScView", UIPanel);

local ANIM_NAME = "act4fun_sc_entry_anim";
local State = {
  NONE = 0,
  COUNT_DOWN = 1,
  COMPLETE = 2,
  OVERTIME = 3,
};
Readonly(State);

local COUNT_DOWN_MAX_SIZE = {x = 344, y = 31};
local COUNT_DOWN_MIN_SIZE = {x = 0, y = 31};
local OVERTIME_ALPHA = 0.4;
local NORMAL_ALPHA = 1;


local function _CheckIfValueDirty(cache, target)
  if cache == nil or cache ~= target then
    return true;
  end
  return false;
end

local function _SetActive(gameObj, isActive)
  luaUtils.SetActiveIfNecessary(gameObj, isActive);
end


function Act4funLiveCommentScView:Render(model)
  if model == nil then
    self:_Reset();
    return;
  end
  if self.m_cachedModel ~= nil and self.m_cachedModel.id == model.id then
    return;
  end
  self:_Reset();
  
  CS.Torappu.TorappuAudio.PlayUI(AudioConsts.ACT4FUN_SCHINT);
  self.m_cachedModel = model;
  self.m_state = State.COUNT_DOWN;
  self.m_timer = self:Delay(self.m_cachedModel.countDownTime,function()
    self.m_state = State.OVERTIME;
    self:_RefreshContent();
    CS.Torappu.TorappuAudio.PlayUI(AudioConsts.ACT4FUN_SCINTERACT);
  end);
  self:SetScaled(self.m_timer);
  self:_RefreshContent();
end


function Act4funLiveCommentScView:OnInit()
  self.m_timer = 0;
  self.m_viewCache = {};
  self.m_state = State.NONE;
  local location = CS.Torappu.UI.UIAnimationLocation();
  location.animationWrapper = self._animationWrapper;
  location.animationName = ANIM_NAME;
  local builder = CS.Torappu.UI.AnimationSwitchTween.Builder(location);
  builder.ease = CS.DG.Tweening.Ease.Linear;
  builder.inactivateTargetIfHide = true;
  builder.tweenFromStart = false;
  self.m_switchTween = builder:Build();

  self:AddButtonClickListener(self._btnConfirm, self._OnClick);
end

function Act4funLiveCommentScView:_Reset()
  TimerModel.me:Destroy(self.m_timer);
  self.m_switchTween:Reset(false);
  self.m_cachedModel = nil;
  self.m_state = State.NONE;
  self:_ResetCountDownIfNeed();
end

function Act4funLiveCommentScView:_ResetCountDownIfNeed()
  if self.m_countDownTween ~= nil and self.m_countDownTween:IsPlaying() then
    self.m_countDownTween:Kill();
  end
end


function Act4funLiveCommentScView:_GenerateCountDownTween(time)
  self:_ResetCountDownIfNeed();
  if time == nil then
    return;
  end
  self._rectCountDown.sizeDelta = COUNT_DOWN_MAX_SIZE;
  self.m_countDownTween = self._rectCountDown:DOSizeDelta(COUNT_DOWN_MIN_SIZE, time)
                                             :SetEase(CS.DG.Tweening.Ease.Linear);
end

function Act4funLiveCommentScView:_RefreshContent()
  if self.m_cachedModel == nil or self.m_state == State.NONE then
    self.m_switchTween:Reset(false);
    return;
  end
  self.m_switchTween.isShow = true;
  if self.m_state == State.COUNT_DOWN then
    self:_GenerateCountDownTween(self.m_cachedModel.countDownTime);
  else
    self:_ResetCountDownIfNeed();
  end

  _SetActive(self._panelComplete, self.m_state == State.COMPLETE);
  _SetActive(self._panelCountDown, self.m_state == State.COUNT_DOWN);
  _SetActive(self._panelOvertime, self.m_state == State.OVERTIME);
  
  if self.m_state == State.OVERTIME then
    self._textCanvasGroup.alpha = OVERTIME_ALPHA;
  else
    self._textCanvasGroup.alpha = NORMAL_ALPHA;
  end

  if _CheckIfValueDirty(self.m_viewCache.desc, self.m_cachedModel.desc) or
      _CheckIfValueDirty(self.m_viewCache.userName, self.m_cachedModel.userName) then
    local content = luaUtils.Format(StringRes.ACTFUN_SUPER_COMMENT_FORMAT, 
        self.m_cachedModel.userName, self.m_cachedModel.desc);
    self._textContent.text = content;
    self.m_viewCache.desc = self.m_cachedModel.desc;
    self.m_viewCache.userName = self.m_cachedModel.userName;
  end

  if _CheckIfValueDirty(self.m_viewCache.userIcon, self.m_cachedModel.userIcon) then
    local icon = self:LoadSpriteFromAutoPackHub(
        CS.Torappu.ResourceUrls.GetAct4funCommentIconHubPath(), self.m_cachedModel.userIcon);
    self._imgAvatar.sprite = icon;
    self.m_viewCache.userIcon = self.m_cachedModel.userIcon;
  end
end

function Act4funLiveCommentScView:_OnClick()
  if self.m_state ~= State.COUNT_DOWN then
    return;
  end
  self.m_state = State.COMPLETE;
  TimerModel.me:Destroy(self.m_timer);
  if self.m_countDownTween ~= nil and self.m_countDownTween:IsPlaying() then
    self.m_countDownTween:Kill();
  end
  if self.onScClicked ~= nil then
    self.onScClicked:Call();
  end
  CS.Torappu.TorappuAudio.PlayUI(AudioConsts.ACT4FUN_SCINTERACT);
  self:_RefreshContent();
end

return Act4funLiveCommentScView;