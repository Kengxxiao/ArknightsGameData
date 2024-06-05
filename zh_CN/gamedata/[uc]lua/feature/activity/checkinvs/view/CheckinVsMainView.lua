local luaUtils = CS.Torappu.Lua.Util
local Ease = CS.DG.Tweening.Ease
local CheckinVsDefine = require("Feature/Activity/CheckinVs/CheckinVsDefine")
local TasteType = CS.Torappu.VersusCheckInData.TasteType
local CheckinVsMainSignItemView = require("Feature/Activity/CheckinVs/View/CheckinVsMainSignItemView")
local CheckinVsMainViewModel = require("Feature/Activity/CheckinVs/CheckinVsMainViewModel")




























































local CheckinVsMainView = Class("CheckinVsMainView", UIPanel)

CheckinVsMainView.SWEET_BOAT_ANIM_NAME = "act1signvs_boat_sweet"
CheckinVsMainView.SALTY_BOAT_ANIM_NAME = "act1signvs_boat_salt"
CheckinVsMainView.TITLE_FREE_SPRITE_NAME = "title_free_party"
CheckinVsMainView.TITLE_SWEET_SPRITE_NAME = "title_sweet_party"
CheckinVsMainView.TITLE_SALTY_SPRITE_NAME = "title_salty_bg"
CheckinVsMainView.TITLE_TIMEOUT_SPRITE_NAME = "title_timeout"



function CheckinVsMainView:OnViewModelUpdate(data)
  if data == nil then
    self.m_viewModel = nil
    return
  end
  self.m_viewModel = data

  self:_InitIfNot(data)

  self:_UpdateBtnStatus()
  self:_UpdateVoteCaption()
  self:_UpdateTasteTitle()

  if not self.m_viewModel:IsVoteCntVisible() then
    SetGameObjectActive(self._textSweetVoteCnt.gameObject, false)
    SetGameObjectActive(self._textSaltyVoteCnt.gameObject, false)
  else
    SetGameObjectActive(self._textSweetVoteCnt.gameObject, true)
    SetGameObjectActive(self._textSaltyVoteCnt.gameObject, true)
    local voteCntFmtStr = StringRes.CHECKIN_VS_VOTE_CNT
    self._textSweetVoteCnt.text = luaUtils.Format(voteCntFmtStr, data.sweetVote)
    self._textSaltyVoteCnt.text = luaUtils.Format(voteCntFmtStr, data.saltyVote)
  end

  local displaySignIndex = data:GetDislapySignIndex()
  local rewardList = self.m_viewModel:GetRewardList(displaySignIndex)
  local rewardStatus = self.m_viewModel:GetDisplayRewardStatus()
  self.m_signItemView:Render(displaySignIndex, rewardList, rewardStatus)

  SetGameObjectActive(self._btnDetailGo, rewardStatus == CheckinVsMainViewModel.RewardStatus.FINISH)
end



function CheckinVsMainView:PlayBoatAnim(choice)
  if choice == CheckinVsDefine.TasteChoice.SWEET then
    local tween = self._sweetBoatAnim:PlayWithTween(self.SWEET_BOAT_ANIM_NAME)
    tween:SetEase(Ease.Linear)
    return
  end

  if choice == CheckinVsDefine.TasteChoice.SALTY then
    local tween = self._saltyBoatAnim:PlayWithTween(self.SALTY_BOAT_ANIM_NAME)
    tween:SetEase(Ease.Linear)
    return
  end
end


function CheckinVsMainView:_UpdateTasteTitle()
  local tasteInfo = self.m_viewModel:GetCurrentTasteInfo()
  local isVoteFinish = self.m_viewModel:IsVoteFinish()
  if tasteInfo == nil and isVoteFinish then
    SetGameObjectActive(self._tasteTitleTextGo, false)
    SetGameObjectActive(self._tasteFinishTextGo, true)
  else
    SetGameObjectActive(self._tasteTitleTextGo, true)
    SetGameObjectActive(self._tasteFinishTextGo, false)
    if tasteInfo == nil and not isVoteFinish then
      self._textTasteTitle.text = StringRes.CHECKIN_VS_UNKNOW_TITLE
    else  
      self._textTasteTitle.text = tasteInfo.tasteText
    end
  end

  local spriteName = nil
  if tasteInfo == nil and isVoteFinish then
    spriteName = self.TITLE_TIMEOUT_SPRITE_NAME
  elseif tasteInfo == nil and not isVoteFinish then
    spriteName = self.TITLE_FREE_SPRITE_NAME
  elseif tasteInfo.tasteType == TasteType.DRAW then
    spriteName = self.TITLE_FREE_SPRITE_NAME
  elseif tasteInfo.tasteType == TasteType.SWEET then
    spriteName = self.TITLE_SWEET_SPRITE_NAME
  elseif tasteInfo.tasteType == TasteType.SALT then
    spriteName = self.TITLE_SALTY_SPRITE_NAME
  end
  local sprite = self._atlasTasteTitle:GetSpriteByName(spriteName)
  self._imgTasteTitle:SetSprite(sprite)
end


function CheckinVsMainView:_UpdateVoteCaption()
  local isVoteFinish = self.m_viewModel:IsVoteFinish()
  SetGameObjectActive(self._voteProgressCaptionGo, not isVoteFinish)
  SetGameObjectActive(self._voteFinishCaptionGo, isVoteFinish)
  if isVoteFinish then
    local tasteInfo = self.m_viewModel:GetCurrentTasteInfo()
    if tasteInfo == nil then
      self._textVoteRewardCaption.text = ""
    else
      local fmtStr = StringRes.CHECKIN_VS_VOTE_REWARD_CAPTION
      local nickName = CS.Torappu.PlayerData.instance.data.status.nickName
      self._textVoteRewardCaption.text = luaUtils.Format(fmtStr, nickName, tasteInfo.tasteText)
    end
  else
    local voteDayFmtStr = StringRes.CHECKIN_VS_DAY_DISPLAY
    local totalVoteDay = self.m_viewModel:GetTotalVoteDay()
    local today = self.m_viewModel.actDay
    local isLastVoteDay = today >= totalVoteDay
    SetGameObjectActive(self._nextDayTextGo, not isLastVoteDay)
    SetGameObjectActive(self._finalDayTextGo, isLastVoteDay)
    self._textCurrentDay.text = luaUtils.Format(voteDayFmtStr, today, totalVoteDay)
    self._textNextDay.text = luaUtils.Format(voteDayFmtStr, today+1, totalVoteDay)
    if self.m_viewModel.canVote then
      self._textVoteTasteCaption.text = StringRes.CHECKIN_VS_VOTE_TASTE_CAPTION
    else
      self._textVoteTasteCaption.text = StringRes.CHECKIN_VS_HAS_VOTED_TODAY_CAPTION
    end
  end
end


function CheckinVsMainView:_UpdateBtnStatus()
  local btnSweetStatus = self.m_viewModel:CalcBtnVoteStatus(CheckinVsDefine.TasteChoice.SWEET)
  local btnSaltyStatus = self.m_viewModel:CalcBtnVoteStatus(CheckinVsDefine.TasteChoice.SALTY)
  SetGameObjectActive(self._btnVoteSweetGo, btnSweetStatus > CheckinVsMainViewModel.BtnVoteStatus.INVISIBLE)
  SetGameObjectActive(self._btnVoteSaltyGo, btnSaltyStatus > CheckinVsMainViewModel.BtnVoteStatus.INVISIBLE)
  SetGameObjectActive(self._sweetRewardGo, btnSweetStatus == CheckinVsMainViewModel.BtnVoteStatus.GAIN_REWARD)
  SetGameObjectActive(self._saltyRewardGo, btnSaltyStatus == CheckinVsMainViewModel.BtnVoteStatus.GAIN_REWARD)
  self._btnVoteSweet.interactable = btnSweetStatus ~= CheckinVsMainViewModel.BtnVoteStatus.INACTIVE
  self._btnVoteSalty.interactable = btnSaltyStatus ~= CheckinVsMainViewModel.BtnVoteStatus.INACTIVE
  self._textBtnSweetCaption.text = self:_GetBtnCaption(btnSweetStatus)
  self._textBtnSaltyCaption.text = self:_GetBtnCaption(btnSaltyStatus)
end



function CheckinVsMainView:_GetBtnCaption(btnStatus)
  if btnStatus == CheckinVsMainViewModel.BtnVoteStatus.INACTIVE then
    return StringRes.CHECKIN_VS_HAS_VOTED_CAPTION
  end
  if btnStatus == CheckinVsMainViewModel.BtnVoteStatus.ACTIVE then
    return StringRes.CHECKIN_VS_VOTE_TODO_CAPTION
  end
  if btnStatus == CheckinVsMainViewModel.BtnVoteStatus.GAIN_REWARD then
    return StringRes.CHECKIN_VS_GAIN_SPECIAL_REWARD_CAPTION
  end
  return nil
end



function CheckinVsMainView:_InitIfNot(data)
  if self.m_hasInited then
    return
  end
  self.m_hasInited = true

  local endTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(data:GetEndTime())
  local timeStr = luaUtils.Format(StringRes.DATE_FORMAT_YYYY_MM_DD_HH_MM,
      endTime.Year, endTime.Month, endTime.Day, endTime.Hour, endTime.Minute)
  self._textFinishTime.text = luaUtils.Format(StringRes.CHECKIN_VS_FINISH_TIME, timeStr)

  self:AddButtonClickListener(self._btnVoteSweet, self._HandleBtnVoteSweetClick)
  self:AddButtonClickListener(self._btnVoteSalty, self._HandleBtnVoteSaltyClick)
  self:AddButtonClickListener(self._btnRule, self._HandleBtnRuleClick)
  self:AddButtonClickListener(self._btnDetail, self._HandleBtnRewardDetailClick)
  self.m_signItemView = self:CreateWidgetByPrefab(CheckinVsMainSignItemView, self._signItemView, self._signItemParent)
  self.m_signItemView:SetSignFunc(function()
    self.m_parent:EventOnBtnSignClick()
  end)

  self:_InitBoatView()
end


function CheckinVsMainView:_InitBoatView()
  self._sweetBoatAnim:InitIfNot()
  self._sweetBoatAnim:SampleClipAtBegin(self.SWEET_BOAT_ANIM_NAME)
  self._saltyBoatAnim:InitIfNot()
  self._saltyBoatAnim:SampleClipAtBegin(self.SALTY_BOAT_ANIM_NAME)

  local sweetBoatPos = self._sweetBoatContainerRt.anchoredPosition
  local saltyBoatPos = self._saltyBoatContainerRt.anchoredPosition
  local socialState = self.m_viewModel.socialState
  local actDay = self.m_viewModel.actDay
  local canVote = self.m_viewModel.canVote
  local isSweetAhead = false
  local isSaltyAhead = false
  local needShowBaseLine = true
  if actDay == 1 and canVote then
    sweetBoatPos.y = tonumber(self._lowBoatPosVal)
    saltyBoatPos.y = tonumber(self._lowBoatPosVal)
    needShowBaseLine = false
  elseif socialState == CheckinVsDefine.TasteChoice.SWEET then
    sweetBoatPos.y = tonumber(self._highBoatPosVal)
    saltyBoatPos.y = tonumber(self._lowBoatPosVal)
    isSweetAhead = true
  elseif socialState == CheckinVsDefine.TasteChoice.SALTY then
    sweetBoatPos.y = tonumber(self._lowBoatPosVal)
    saltyBoatPos.y = tonumber(self._highBoatPosVal)
    isSaltyAhead = true
  else
    sweetBoatPos.y = tonumber(self._lowBoatPosVal)
    saltyBoatPos.y = tonumber(self._lowBoatPosVal)
  end
  self._sweetBoatContainerRt.anchoredPosition = sweetBoatPos
  self._saltyBoatContainerRt.anchoredPosition = saltyBoatPos

  local isVoteFinish = self.m_viewModel:IsVoteFinish()
  local isSaltyWin = socialState == CheckinVsDefine.TasteChoice.SALTY
  SetGameObjectActive(self._sweetBoatBaseLineGo, needShowBaseLine and not isVoteFinish)
  SetGameObjectActive(self._saltyBoatBaseLineGo, needShowBaseLine and not isVoteFinish)
  SetGameObjectActive(self._dotLineLeftGo, not isVoteFinish)
  SetGameObjectActive(self._dotLineRightGo, not isVoteFinish)
  SetGameObjectActive(self._sweetAheadGo, isSweetAhead and not isVoteFinish)
  SetGameObjectActive(self._saltyAheadGo, isSaltyAhead and not isVoteFinish)
  SetGameObjectActive(self._sweetWinnerBgGo, isVoteFinish and not isSaltyWin)
  SetGameObjectActive(self._sweetWinnerBannerGo, isVoteFinish and not isSaltyWin)
  SetGameObjectActive(self._saltyWinnerBgGo, isVoteFinish and isSaltyWin)
  SetGameObjectActive(self._saltyWinnerBannerGo, isVoteFinish and isSaltyWin)
  local isSweetVoted = self.m_viewModel.todayVoteState == CheckinVsDefine.TasteChoice.SWEET
  local isSaltyVoted = self.m_viewModel.todayVoteState == CheckinVsDefine.TasteChoice.SALTY
  SetGameObjectActive(self._sweetVotedBgGo, isSweetVoted)
  SetGameObjectActive(self._sweetVotedBannerGo, isSweetVoted)
  SetGameObjectActive(self._saltyVotedBgGo, isSaltyVoted)
  SetGameObjectActive(self._saltyVotedBannerGo, isSaltyVoted)
end


function CheckinVsMainView:_HandleBtnVoteSweetClick()
  self.m_parent:EventOnBtnSweetClick()
end


function CheckinVsMainView:_HandleBtnVoteSaltyClick()
  self.m_parent:EventOnBtnSaltyClick()
end


function CheckinVsMainView:_HandleBtnRuleClick()
  self.m_parent:EventOnRuleOpen()
end


function CheckinVsMainView:_HandleBtnRewardDetailClick()
  self.m_parent:EventOnRewardPreviewOpen()
end

return CheckinVsMainView