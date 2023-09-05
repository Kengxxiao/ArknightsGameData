local luaUtils = CS.Torappu.Lua.Util;
local FadeSwitchTween = CS.Torappu.UI.FadeSwitchTween;
local UICommonItemCard = require("Feature/Supportor/UI/UICommonItemCard");





































































local MainlineBpBpView = Class("MainlineBpBpView", UIPanel);
local MainlineBpBpLimitAdapter = require("Feature/Activity/MainlineBp/MainlineBpBpLimitAdapter");

MainlineBpBpView.UNLIMIT_CIRCLE_GRAY_COLOR = {r=0.56, g=0.56, b=0.56, a=1}
MainlineBpBpView.UNLIMIT_CIRCLE_BLUE_COLOR = {r=0.02, g=0.64, b=0.85, a=1}

local function _SetActive(gameObj, isActive)
  luaUtils.SetActiveIfNecessary(gameObj, isActive);
end

local function _CreateSwitch(canvasGroup)
  local ret = CS.Torappu.UI.FadeSwitchTween(canvasGroup);
  ret:Reset(false);
  return ret;
end

function MainlineBpBpView:OnInit()
  self:AddButtonClickListener(self._btnClaimAll, self._OnClaimAllBtnClick);
  self:AddButtonClickListener(self._btnPreview, self._OnBigRewardPreviewBtnClick);
  self:AddButtonClickListener(self._btnDetailClose, self._OnUnlimitBpDetailCloseBtnClick);
  self:AddButtonClickListener(self._btnUnlimitDetail, self._OnUnlimitBpDetailBtnClick);
  
  self.m_isUnlimitRewardDetailInit = false;
  self.m_limitScrollFocused = false;

  self.m_limitRewardAdapter = self:CreateCustomComponent(MainlineBpBpLimitAdapter, self._objLimitRewardAdapter, self);
  self.m_limitRewardAdapter.rewardList = {};

  self.m_claimAllBtnSwitch = _CreateSwitch(self._canvasClaimAll);
  self.m_unlimitRewardDetailSwitch = _CreateSwitch(self._canvasUnlimitDetatil);
  self.m_viewSwitchTween = _CreateSwitch(self._canvasBpView);

  self._textCanClaimTips.text = StringRes.MAINLINE_BP_REWARD_OPEN_CLAIM_TIPS;
end

function MainlineBpBpView:InitEventFunc()
  self.m_limitRewardAdapter.onRewardClaimClicked = self.onLimitRewardClaimClicked;
end


function MainlineBpBpView:OnViewModelUpdate(data)
  self.m_cachedViewModel = nil;
  self.m_canClaimAll = false;
  self.m_canClaimUnlimit = false;
  self.m_unlimitCanClaimRound = 0;
  if data == nil then
    return;
  end

  local showBpView = data.tabState == MainlineBpTabState.BP and data.showBpUpDetailPanel == false;
  self.m_viewSwitchTween.isShow = showBpView;
  if showBpView == false then
    return;
  end
  self.m_cachedViewModel = data;
  self.m_canClaimAll = data.showBpAllCanClaimBtn;
  self.m_canClaimUnlimit = data.isBpUnlimitHasRewardCanClaim;
  self.m_unlimitCanClaimRound = data.unlimitBpRewardRoundCount;
  self.m_claimAllBtnSwitch.isShow = self.m_canClaimAll;

  if self.m_limitScrollFocused == false and self.m_cachedViewModel ~= nil then
    self.m_limitScrollFocused = true;
    self:_ClearFocusCoroutine();
    self.m_focusCoroutine = self:StartCoroutine(self._FocusOnCurLimitRewardCoroutine);
  end
  
  self:_RefreshTopPart(data);
  self:_RefreshUnlimitRewardPart(data);
  self:_RefreshLimitRewardPart(data);
  self:_ShowUnlimitRewardDetail(data.showBpUnlimitDetailPanel);
end


function MainlineBpBpView:_FocusOnCurLimitRewardCoroutine()
  coroutine.yield();

  local data = self.m_cachedViewModel;
  local curForcusIndex = data:TryGetCurLimitBpIndex();
  self:_FocusOnLimitRewardIndex(data,curForcusIndex);

  self.m_focusCoroutine = nil;
end


function MainlineBpBpView:_ClearFocusCoroutine()
  if self.m_focusCoroutine ~= nil then
    self:StopCoroutine(self.m_focusCoroutine);
    self.m_focusCoroutine = nil;
  end
end



function MainlineBpBpView:_RefreshTopPart(data)
  local isPeriodChange = self.m_cachedPeriodId == nil or self.m_cachedPeriodId == "" or self.m_cachedPeriodId ~= data.currPeriodId;
  if isPeriodChange then
    self:_RefreshBannerPic(data.actId, data.bpBannerId);
    _SetActive(self._objPreview, data.showBpPreviewBtn);
  end
  _SetActive(self._objBigRewardClaimedTips, data.showBpClaimedBigRewardTips);
end




function MainlineBpBpView:_RefreshBannerPic(actId,bpBannerId)
  if bpBannerId == nil or bpBannerId == "" or self.loadDynImage == nil then
    return;
  end
  self._imgBanner.sprite = self.loadDynImage(actId, bpBannerId);
end



function MainlineBpBpView:_RefreshUnlimitRewardPart(data)
  if data == nil or data.unlimitBpRewardItemFirst == nil then
    return;
  end
  
  local notInPeriod = data.unlimitBpRewardState == MainlineBpUnlimitBpState.NOT_IN_CLAIM;
  local canClaimReward = data.unlimitBpRewardState == MainlineBpUnlimitBpState.IN_CLAIM_AND_CAN_CLAIM;
  local cantClaimReward = data.unlimitBpRewardState == MainlineBpUnlimitBpState.IN_CLAIM_AND_CANT_CLAIM;
  local inPeriod = notInPeriod == false;
  local showRoundCount = data.showUnlimitBpRewardRound;
  if showRoundCount then
    self._textUnlimitRoundCount.text = tostring(data.unlimitBpRewardRoundCount);
  end
  
  if self.m_unlimitRewardItemCard == nil then
    self.m_unlimitRewardItemCard = self:CreateWidgetByGO(UICommonItemCard, self._panelUnlimitRewardHolder);
  end
  if self.m_unlimitRewardItemCard ~= nil then
    local scale = tonumber(self._unlimitRewardItemScale);
    self.m_unlimitRewardItemCard:Render(data.unlimitBpRewardItemFirst, {
      itemScale = scale,
      isCardClickable = false,
      showItemName = false,
      showItemNum = true,
      showBackground = true,
    });
  end

  _SetActive(self._objUnlimitRound, showRoundCount);
  local showRoundBgGray = showRoundCount and notInPeriod;
  local showRoungBgBlue = showRoundCount and inPeriod;
  _SetActive(self._objUnlimitRoundCountBgGray, showRoundBgGray);
  _SetActive(self._objUnlimitRoundCountBgBlue, showRoungBgBlue);
  _SetActive(self._objCanClaimUnlimit, canClaimReward);
  self._textUnlimitProgress.text = string.format("%d/%d", data.unlimitBpCurRoundPoints, data.unlimitBpCurRoundNeedPoints);
  self._imgUnlimitCircle.fillAmount = data.unlimitBpCurRoundProgress;
  local unlimitCircleColor;
  if inPeriod then
    unlimitCircleColor = self.UNLIMIT_CIRCLE_BLUE_COLOR;
  else
    unlimitCircleColor = self.UNLIMIT_CIRCLE_GRAY_COLOR;
  end
  self._imgUnlimitCircle.color = unlimitCircleColor;
end



function MainlineBpBpView:_RefreshLimitRewardPart(data)
  self.m_limitRewardAdapter.rewardList = data.limitBpItemModelList;
  self.m_limitRewardAdapter:NotifyDataSourceChanged();
  local paddingRight = 0;
  if data.showFurtureTips then
    paddingRight = tonumber(self._limitRewardRightPaddingHasFurture);
  else
    paddingRight = tonumber(self._limitRewardRightPaddingNoFurture);
  end
  self._limitBpGridLayout.padding.right = paddingRight;
end




function MainlineBpBpView:_FocusOnLimitRewardIndex(data,focusIndex)
  local rewardListCount = #data.limitBpItemModelList;
  if rewardListCount <= 0 then
    return;
  end
  if focusIndex < 1 then
    focusIndex = 1;
  end
  if self.m_tweenFocusToCurLimitReward ~= nil then
    self.m_tweenFocusToCurLimitReward:Kill(false);
  end
  local itemWidth = self._limitBpGridLayout.cellSize.x;
  local itemSpacing = self._limitBpGridLayout.spacing.x;
  local leftPadding = self._limitBpGridLayout.padding.left;
  local rightPadding = self._limitBpGridLayout.padding.right;
  local contentWidth = leftPadding + rightPadding + (rewardListCount - 1) * itemSpacing + rewardListCount * itemWidth;
  local viewPortWidth = self._limitBpScrollRect.viewport.rect.width;
  local scrollWidth = contentWidth - viewPortWidth;
  if scrollWidth <= 0 or itemWidth <= 0 then
    return;
  end
  local offset = leftPadding;
  for i = 1, focusIndex do
    offset = offset + itemWidth + itemSpacing;
  end
  if focusIndex > 1 then
    offset = offset - itemSpacing;
  end
  
  offset = offset - itemWidth * tonumber(self._limitFocusOffset);
  if offset < 0 then
    offset = 0;
  end
  if offset > scrollWidth then
    offset = scrollWidth;
  end
  local normalizedPos = 0;
  if focusIndex > 1 then
    normalizedPos = offset / scrollWidth;
  end

  local realIndex = focusIndex - 1;
  local target = math.min(1, realIndex / (rewardListCount - viewPortWidth / itemWidth));
  local current = self._limitBpScrollRect.horizontalNormalizedPosition;
  local distance = math.abs(target - current) * rewardListCount + 0.5;
  local curIndexDistance = math.floor(distance);
  local limitBpRewardSlideMaxLength = tonumber(self._limitBpRewardSlideMaxLength);

  if curIndexDistance > limitBpRewardSlideMaxLength then
    local direction = 1;
    if target > current then
      direction = -1;
    end
    local nearIndex = math.max(realIndex + direction * limitBpRewardSlideMaxLength, 0);
    nearIndex = math.min(nearIndex, rewardListCount - 1);
    self.m_limitRewardAdapter:NotifyRebuildWithIndex(nearIndex);
  end

  local focusDur = tonumber(self._limitBpRewardFocusDur);
  local focusDelay = tonumber(self._limitBpRewardFocusDelay);
  local this = self;
  self.m_tweenFocusToCurLimitReward = TweenModel:Play({
    setFunc = function(lerpValue)
      local pos = lerpValue * normalizedPos + (1-lerpValue) * current;
      this._limitBpScrollRect.horizontalNormalizedPosition = pos; 
    end,
    duration = focusDur,
    delay = focusDelay,
    easeFunc = TweenModel.EaseFunc.easeOutQuad,
  });
end


function MainlineBpBpView:_ClaimUnlimitReward()
  if self.onUnlimitRewardClaimClicked == nil then
    return;
  end
  Event.Call(self.onUnlimitRewardClaimClicked, self.m_unlimitCanClaimRound);
  CS.Torappu.TorappuAudio.PlayUI(CS.Torappu.Audio.Consts.InternalSounds[CS.Torappu.Audio.UiInternalSoundType.ConfirmBtn]);
end


function MainlineBpBpView:_OpenUnlimitDetailView()
  if self.onBpUnlimitDetailClick == nil then
    return;
  end
  Event.Call(self.onBpUnlimitDetailClick);
  CS.Torappu.TorappuAudio.PlayUI(CS.Torappu.Audio.Consts.DETAIL_PANEL_POPUP);
end



function MainlineBpBpView:_ShowUnlimitRewardDetail(show)
  if show == false then
    self.m_unlimitRewardDetailSwitch.isShow = false;
    return;
  end

  local data = self.m_cachedViewModel;
  if data == nil then
    return;
  end
  if self.m_isUnlimitRewardDetailInit == false then
    self:_RefreshUnlimitDetailRewardItem(self.m_unlimitDetailItemCard1,self._panelUnlimitDetailItemHolder1,data.unlimitBpRewardData1);
    self:_RefreshUnlimitDetailRewardItem(self.m_unlimitDetailItemCard2,self._panelUnlimitDetailItemHolder2,data.unlimitBpRewardData2);
    self._textUnlimitDetailItemName1.text = data.unlimitBpRewardName1;
    self._textUnlimitDetailItemName2.text = data.unlimitBpRewardName2;
    self.m_isUnlimitRewardDetailInit = true;
  end
  self._textUnlimitDetailTips1.text = data.unlimitBpRewardTips1;
  self._textUnlimitDetailTips2.text = data.unlimitBpRewardTips2;

  self.m_unlimitRewardDetailSwitch.isShow = true;
end


function MainlineBpBpView:_RefreshUnlimitDetailRewardItem(unlimitDetailItemCard,itemHolder,itemBundle)
  if unlimitDetailItemCard == nil then
    unlimitDetailItemCard = self:CreateWidgetByGO(UICommonItemCard, itemHolder);
  end
  if unlimitDetailItemCard ~= nil then
    local scale = tonumber(self._unlimitDetialRewardItemScale);
    unlimitDetailItemCard:Render(itemBundle, {
      itemScale = scale,
      isCardClickable = true,
      showItemName = false,
      showItemNum = true,
      showBackground = true,
    });
  end
end


function MainlineBpBpView:_OnClaimAllBtnClick()
  if self.m_canClaimAll == false or self.onAllBpRewardClaimClicked == nil then
    return;
  end
  Event.Call(self.onAllBpRewardClaimClicked, self.m_unlimitCanClaimRound);
end


function MainlineBpBpView:_OnBigRewardPreviewBtnClick()
  if CS.Torappu.FastActionDetector.IsFastAction() then
    return;
  end
  if self.onBigRewardPreviewBtnClick == nil then
    return;
  end
  Event.Call(self.onBigRewardPreviewBtnClick);
end


function MainlineBpBpView:_OnUnlimitBpDetailCloseBtnClick()
  if self.onBpUnlimitDetailCloseClick == nil then
    return;
  end
  Event.Call(self.onBpUnlimitDetailCloseClick);
end


function MainlineBpBpView:_OnUnlimitBpDetailBtnClick()
  if self.m_canClaimUnlimit == true then
    self:_ClaimUnlimitReward();
  else
    self:_OpenUnlimitDetailView();
  end
end

return MainlineBpBpView;