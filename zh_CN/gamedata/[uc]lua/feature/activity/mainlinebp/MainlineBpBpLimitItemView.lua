local luaUtils = CS.Torappu.Lua.Util;
local FadeSwitchTween = CS.Torappu.UI.FadeSwitchTween;
local UICommonItemCard = require("Feature/Supportor/UI/UICommonItemCard");



































local MainlineBpBpLimitItemView = Class("MainlineBpBpLimitItemView", UIPanel);

local function _SetActive(gameObj, isActive)
  luaUtils.SetActiveIfNecessary(gameObj, isActive);
end

local function _CreateSwitch(canvasGroup)
  local ret = CS.Torappu.UI.FadeSwitchTween(canvasGroup);
  ret:Reset(false);
  return ret;
end

function MainlineBpBpLimitItemView:OnInit()
  self:AddButtonClickListener(self._btnClaimClickHolder, self._OnClaimItemClick);

  self.m_canClaimItemDownSwitch = _CreateSwitch(self._canvasCanClaimDown);
  self.m_canClaimItemTipsSwitch = _CreateSwitch(self._canvasCanClaim);
  self.m_claimedItemTipsSwitch = _CreateSwitch(self._canvasAlreadGot);
  self.m_dotCanClaimSwitch = _CreateSwitch(self._canvasDotCanClaim);
  self.m_dotClaimedSwitch = _CreateSwitch(self._canvasDotClaimed);
end


function MainlineBpBpLimitItemView:Render(viewModel)
  self.m_cachedBpId = ""; 

  if viewModel == nil then
    return;
  end

  self.m_cachedBpId = viewModel.bpId;
  self:_RenderItemPart(viewModel);
  self:_RenderFurtureTipsPart(viewModel);
end



function MainlineBpBpLimitItemView:_RenderItemPart(viewModel)
  local itemType = viewModel.itemType;
  local isRewardItem = itemType == MainlineBpLimitBpItemType.REWARD;

  _SetActive(self._objItem, isRewardItem);
  if isRewardItem == false then
    return;
  end

  if self.m_rewardItemCard == nil then
    self.m_rewardItemCard = self:CreateWidgetByGO(UICommonItemCard, self._panelItemHolder);
  end
  if self.m_rewardItemCard ~= nil then
    self.m_rewardItemCard:Render(viewModel.reward, {
      itemScale = tonumber(self._rewardItemScale),
      isCardClickable = true,
      showItemName = false,
      showItemNum = true,
      showBackground = true,
      fastClickBlock = true,
    });
  end

  self:_RenderItemRewardPart(viewModel);
  self:_RenderItemTipsPart(viewModel);
  self:_RenderItemProgressPart(viewModel);
end



function MainlineBpBpLimitItemView:_RenderItemRewardPart(viewModel)
  local itemState = viewModel.itemState;
  local showCanClaim = itemState == MainlineBpLimitBpItemState.IN_CLAIM_AND_CAN_CLAIM;
  local showClaimed = itemState == MainlineBpLimitBpItemState.IN_CLAIM_AND_CLAIMED;
  local showLockTips = itemState == MainlineBpLimitBpItemState.NOT_IN_CLAIM_AND_NOT_PASS or itemState == MainlineBpLimitBpItemState.IN_CLAIM_AND_NOT_PASS;
  self.m_canClaimItemDownSwitch.isShow = showCanClaim;
  self.m_canClaimItemTipsSwitch.isShow = showCanClaim;
  self.m_claimedItemTipsSwitch.isShow = showClaimed;
  _SetActive(self._objLockTips, showLockTips);
  if showLockTips then
    self._textLockTips.text = viewModel.unlockStageTips;
  end
  local itemRewardAlpha = 1;
  local isLockByCount = itemState == MainlineBpLimitBpItemState.NOT_IN_CLAIM_AND_LACK_COUNT or itemState == MainlineBpLimitBpItemState.IN_CLAIM_AND_LACK_COUNT_PASS;
  local isLockByPass = itemState == MainlineBpLimitBpItemState.NOT_IN_CLAIM_AND_NOT_PASS or itemState == MainlineBpLimitBpItemState.IN_CLAIM_AND_NOT_PASS;
  if showClaimed then
    itemRewardAlpha = tonumber(self._rewardItemClaimedAlpha);
  else
    itemRewardAlpha = tonumber(self._rewardItemNormalAlpha);
  end
  self._canvasRewardItem.alpha = itemRewardAlpha;
end



function MainlineBpBpLimitItemView:_RenderItemTipsPart(viewModel)
  local itemTipsState = viewModel.itemTipsState;
  local showDotCanClaim = itemTipsState == MainlineBpLimitBpItemTipsState.IN_CLAIM_AND_CAN_CLAIM;
  local showDotClaimed = itemTipsState == MainlineBpLimitBpItemTipsState.IN_CLAIM_AND_CLAIMED;
  local showGrayLock = itemTipsState == MainlineBpLimitBpItemTipsState.NOT_IN_CLAIM_AND_LACK_COUNT or itemTipsState == MainlineBpLimitBpItemTipsState.IN_CLAIM_AND_LACK_COUNT;
  local showBlueLock = itemTipsState == MainlineBpLimitBpItemTipsState.NOT_IN_CLAIM_AND_ENOUGH_COUNT or itemTipsState == MainlineBpLimitBpItemTipsState.IN_CLAIM_AND_ENOUGH_COUNT_NOT_PASS;
  
  self.m_dotCanClaimSwitch.isShow = showDotCanClaim;
  self.m_dotClaimedSwitch.isShow = showDotClaimed;
  _SetActive(self._objLockGray, showGrayLock);
  _SetActive(self._objLockLight, showBlueLock);
end



function MainlineBpBpLimitItemView:_RenderItemProgressPart(viewModel)
  local progressState = viewModel.itemProgressLineState;
  local showBlueLine = progressState == MainlineBpLimitBpItemProgressLineState.CUR_AND_NEXT_ENOUGH;
  local showBlackLine = progressState == MainlineBpLimitBpItemProgressLineState.NOT_ENOUGH;
  local showGradientLine = progressState == MainlineBpLimitBpItemProgressLineState.CUR_ENOUGH_BUT_NEXT_NOT;

  _SetActive(self._objLineBlue, showBlueLine);
  _SetActive(self._objLineBlack, showBlackLine);
  _SetActive(self._objLineGradient, showGradientLine);
  self._textProgressCount.text = tostring(viewModel.tokenNum);
end



function MainlineBpBpLimitItemView:_RenderFurtureTipsPart(viewModel)
  local itemType = viewModel.itemType;
  local isFurtureTips = itemType == MainlineBpLimitBpItemType.FURTURE_TIPS;

  _SetActive(self._objFurture, isFurtureTips);
  if isFurtureTips == false then
    return;
  end

  self._textMoreTips.text = viewModel.bpNoticeDesc;
end


function MainlineBpBpLimitItemView:_OnClaimItemClick()
  if self.m_cachedBpId == nil or self.m_cachedBpId == "" or self.onRewardClaimClicked == nil then
    return;
  end
  Event.Call(self.onRewardClaimClicked, self.m_cachedBpId);
end

return MainlineBpBpLimitItemView;