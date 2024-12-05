local luaUtils = CS.Torappu.Lua.Util;
local UICommonItemCard = require("Feature/Supportor/UI/UICommonItemCard");




































local CheckinVideoInfoView = Class("CheckinVideoInfoView", UIPanel);

local ALPHA_CAN_RECEIVE = 1.0;
local ALPHA_CANNOT_RECEIVE = 0.5;

local ANIM_PREV_OUT_NAME = "anim_checkin_video_prev_out";
local ANIM_PREV_IN_NAME = "anim_checkin_video_prev_in";
local ANIM_NEXT_OUT_NAME = "anim_checkin_video_next_out";
local ANIM_NEXT_IN_NAME = "anim_checkin_video_next_in";
local ANIM_LOOP_NAME = "anim_checkin_video_loop";

local CheckinVideoRewardItemView = require("Feature/Activity/CheckinVideo/CheckinVideoRewardItemView");

function CheckinVideoInfoView:OnInit()
  self:AddButtonClickListener(self._btnNext, self._EventOnNextBtnClicked);
  self:AddButtonClickListener(self._btnPrev, self._EventOnPrevBtnClicked);
  self:AddButtonClickListener(self._btnReceive, self._EventOnReceiveBtnClicked);
  self:AddButtonClickListener(self._btnReplay, self._EventOnReplayBtnClicked);
  self:AddButtonClickListener(self._btnShare, self._EventOnShareBtnClicked);

  self.m_rewardAdapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._rewardContent,
      self._CreateRewardView, self._GetRewardCount, self._UpdateRewardView);
  self.m_receivedAdapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._receivedContent,
      self._CreateReceivedView, self._GetRewardCount, self._UpdateReceivedView);
end


function CheckinVideoInfoView:OnViewModelUpdate(data)
  if data == nil then
    return;
  end

  local currFocusId = data.currFocusItem;
  if data.isEnter or self.m_cachedIndex == data.currFocusItem then
    self.m_cachedIndex = currFocusId;
    self:_Render(data.itemList[data.currFocusItem], data.actId);
    return;
  end

  self:_Render(data.itemList[self.m_cachedIndex], data.actId);
  self.m_cachedIndex = currFocusId;

  if self.m_switchAnim ~= nil and self.m_switchAnim:IsPlaying() then
    self.m_switchAnim:Kill();
    self.m_switchAnim = nil;
  end
  
  local switchAnim = CS.DG.Tweening.DOTween.Sequence();
  local outAnimName = ANIM_PREV_OUT_NAME;
  local inAnimName = ANIM_PREV_IN_NAME;
  if data.isNext then
    outAnimName = ANIM_NEXT_OUT_NAME;
    inAnimName = ANIM_NEXT_IN_NAME;
  end
  switchAnim:Append(self._animWrapper:PlayWithTween(outAnimName));
  switchAnim:AppendCallback(function()
      self:_Render(data.itemList[currFocusId], data.actId);
    end);
  switchAnim:Append(self._animWrapper:PlayWithTween(inAnimName));
  switchAnim:SetEase(CS.DG.Tweening.Ease.Linear);
  self.m_switchAnim = switchAnim;
end



function CheckinVideoInfoView:_Render(itemModel, actId)
  if itemModel == nil then
    return;
  end

  if itemModel.status == CheckinVideoItemStatus.CAN_RECEIVE then
    self._canvasGroupReward.alpha = ALPHA_CAN_RECEIVE;
    self._canvasGroupReward.blocksRaycasts = false;
  else
    self._canvasGroupReward.alpha = ALPHA_CANNOT_RECEIVE;
    self._canvasGroupReward.blocksRaycasts = true;
  end

  if itemModel.status == CheckinVideoItemStatus.CAN_RECEIVE then
    if self.m_loopAnim == nil or not self.m_loopAnim:IsPlaying() then
      self.m_loopAnim = self._animWrapper:PlayWithTween(ANIM_LOOP_NAME);
      self.m_loopAnim:SetEase(CS.DG.Tweening.Ease.Linear);
      self.m_loopAnim:SetLoops(-1);
    end
  elseif self.m_loopAnim ~= nil and self.m_loopAnim:IsPlaying() then
    self.m_loopAnim:Kill();
    self.m_loopAnim = nil;
  end

  self.m_hasReceived = itemModel.status == CheckinVideoItemStatus.RECEIVED;
  luaUtils.SetActiveIfNecessary(self._panelCanReceive, itemModel.status == CheckinVideoItemStatus.CAN_RECEIVE);
  luaUtils.SetActiveIfNecessary(self._panelLocked, itemModel.status == CheckinVideoItemStatus.LOCKED);
  luaUtils.SetActiveIfNecessary(self._panelReceived, self.m_hasReceived);
  luaUtils.SetActiveIfNecessary(self._panelReplay, not string.isNullOrEmpty(itemModel.videoId));

  self.m_cachedRewardList = itemModel.rewardList;
  if self.m_rewardAdapter ~= nil then
    self.m_rewardAdapter:NotifyDataSetChanged();
  end
  if self.m_receivedAdapter ~= nil then
    self.m_receivedAdapter:NotifyDataSetChanged();
  end

  if itemModel.status == CheckinVideoItemStatus.LOCKED then
    self._textLocked.text = itemModel.lockedTip;
  end

  local hubPath = CS.Torappu.ResourceUrls.GetCheckinVideoImageHubPath(actId);
  local imgPath = itemModel.introImgList[1];
  if not string.isNullOrEmpty(imgPath) and self._imgIcon1 ~= nil then
    self._imgIcon1.sprite = self:LoadSpriteFromAutoPackHub(hubPath, imgPath);
  end
  local imgPath = itemModel.introImgList[2];
  if not string.isNullOrEmpty(imgPath) and self._imgIcon2 ~= nil then
    self._imgIcon2.sprite = self:LoadSpriteFromAutoPackHub(hubPath, imgPath);
  end
  local imgPath = itemModel.introImgList[3];
  if not string.isNullOrEmpty(imgPath) and self._imgIcon3 ~= nil then
    self._imgIcon3.sprite = self:LoadSpriteFromAutoPackHub(hubPath, imgPath);
  end
  local imgPath = itemModel.introImgList[4];
  if not string.isNullOrEmpty(imgPath) and self._imgIcon4 ~= nil then
    self._imgIcon4.sprite = self:LoadSpriteFromAutoPackHub(hubPath, imgPath);
  end
end



function CheckinVideoInfoView:_CreateRewardView(gameObj)
  local rewardItem = self:CreateWidgetByGO(UICommonItemCard, gameObj);
  return rewardItem;
end


function CheckinVideoInfoView:_GetRewardCount()
  if self.m_cachedRewardList == nil then
    return 0;
  end
  return #self.m_cachedRewardList;
end



function CheckinVideoInfoView:_UpdateRewardView(index, itemCard)
  local idx = index + 1;
  if itemCard == nil then
    return;
  end
  itemCard:Render(self.m_cachedRewardList[idx], {
    itemScale = tonumber(self._rewardItemScale),
    isCardClickable = true,
    showItemName = false,
    showItemNum = true,
    showBackground = true,
    fastClickBlock = true,
  });
end



function CheckinVideoInfoView:_CreateReceivedView(gameObj)
  local receivedItem = self:CreateWidgetByGO(CheckinVideoRewardItemView, gameObj);
  return receivedItem;
end



function CheckinVideoRewardItemView:_UpdateReceivedView(index, view)
  if view == nil then
    return;
  end
  view:Render(self.m_hasReceived);
end

function CheckinVideoInfoView:_EventOnNextBtnClicked()
  if self.onNextBtnClicked == nil then
    return;
  end
  self.onNextBtnClicked:Call();
end

function CheckinVideoInfoView:_EventOnPrevBtnClicked()
  if self.onPrevBtnClicked == nil then
    return;
  end
  self.onPrevBtnClicked:Call();
end

function CheckinVideoInfoView:_EventOnReceiveBtnClicked()
  if self.onReceiveBtnClicked == nil then
    return;
  end
  self.onReceiveBtnClicked:Call();
end

function CheckinVideoInfoView:_EventOnReplayBtnClicked()
  if self.onReplayBtnClicked == nil then
    return;
  end
  self.onReplayBtnClicked:Call();
end

function CheckinVideoInfoView:_EventOnShareBtnClicked()
  if self.onShareBtnClicked == nil then
    return;
  end
  self.onShareBtnClicked:Call();
end

return CheckinVideoInfoView;