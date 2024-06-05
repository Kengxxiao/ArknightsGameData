local Ease = CS.DG.Tweening.Ease
local TorappuAudio = CS.Torappu.TorappuAudio
local CheckinVsMainView = require("Feature/Activity/CheckinVs/View/CheckinVsMainView")
local CheckinVsRuleView = require("Feature/Activity/CheckinVs/View/CheckinVsRuleView")
local CheckinVsRewardPreview = require("Feature/Activity/CheckinVs/View/CheckinVsRewardPreview")
local CheckinVsMainViewModel = require("Feature/Activity/CheckinVs/CheckinVsMainViewModel")
local CheckinVsDefine = require("Feature/Activity/CheckinVs/CheckinVsDefine")













CheckinVsMainDlg = Class("CheckinVsMainDlg", DlgBase)

CheckinVsMainDlg.SHOW_GAINED_ITEMS_DELAY = 2
CheckinVsMainDlg.ENTER_ANIM_NAME = "act1signvs_entry"


function CheckinVsMainDlg:OnInit()
  self.m_isAnimPlay = false
  self._enterAnim:InitIfNot()
  self._enterAnim:SampleClipAtBegin(self.ENTER_ANIM_NAME)
  local tween = self._enterAnim:PlayWithTween(self.ENTER_ANIM_NAME)
  tween:SetEase(Ease.Linear)
  TorappuAudio.PlayUI(self._boatEnterAudioName)

  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnClose)
  self:AddButtonClickListener(self._btnClose, self._EventOnCloseClick)

  self.m_mainView = self:CreateWidgetByGO(CheckinVsMainView, self._mainView)
  self:CreateWidgetByGO(CheckinVsRuleView, self._ruleView)
  self:CreateWidgetByGO(CheckinVsRewardPreview, self._rewardPreview)

  self.m_viewModel = self:CreateViewModel(CheckinVsMainViewModel)
  local actId = self.m_parent:GetData("actId")
  self.m_viewModel:InitData(actId)

  self.m_viewModel:NotifyUpdate()
end


function CheckinVsMainDlg:_EventOnCloseClick()
  if self.m_isAnimPlay then
    return
  end
  self:Close()
end


function CheckinVsMainDlg:EventOnBtnSignClick()
  if self.m_viewModel == nil then
    return
  end

  if self.m_viewModel.availSignCnt <= 0 then
    return
  end

  if not self.m_viewModel:IsVoteFinish() and self.m_viewModel.canVote then
    return
  end

  self:_SendCheckinRequest(CheckinVsDefine.TasteChoice.NONE)
end


function CheckinVsMainDlg:EventOnRuleOpen()
  if self.m_isAnimPlay then
    return
  end

  if self.m_viewModel == nil then
    return
  end
  self.m_viewModel.displayStatus = CheckinVsMainViewModel.DisplayStatus.RULE_VIEW
  self.m_viewModel:NotifyUpdate()
end


function CheckinVsMainDlg:EventOnRewardPreviewOpen()
  if self.m_isAnimPlay then
    return
  end

  if self.m_viewModel == nil then
    return
  end
  self.m_viewModel.displayStatus = CheckinVsMainViewModel.DisplayStatus.REWARD_VIEW
  self.m_viewModel:NotifyUpdate()
end


function CheckinVsMainDlg:EventOnReturnMainView()
  if self.m_viewModel == nil then
    return
  end
  self.m_viewModel.displayStatus = CheckinVsMainViewModel.DisplayStatus.MAIN_VIEW
  self.m_viewModel:NotifyUpdate()
end


function CheckinVsMainDlg:EventOnBtnSweetClick()
  self:_HandleBtnVoteClick(CheckinVsDefine.TasteChoice.SWEET)
end


function CheckinVsMainDlg:EventOnBtnSaltyClick()
  self:_HandleBtnVoteClick(CheckinVsDefine.TasteChoice.SALTY)
end



function CheckinVsMainDlg:_HandleBtnVoteClick(choice)
  if self.m_viewModel == nil then
    return
  end

  if self.m_viewModel.availSignCnt <= 0 then
    return
  end

  if self.m_viewModel:IsVoteFinish() then
    if self.m_viewModel.voteRewardState == 1  then
      self:_SendCheckinRequest(CheckinVsDefine.TasteChoice.NONE)
    end
    return
  end

  if choice > CheckinVsDefine.TasteChoice.NONE and not self.m_viewModel.canVote then
    return
  end

  self:_SendCheckinRequest(choice)
end



function CheckinVsMainDlg:_SendCheckinRequest(choice)
  if self.m_isAnimPlay then
    return
  end

  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return
  end

  UISender.me:SendRequest(CheckinVsDefine.ServiceCode.CHECKIN_VS_SIGN,
      {
        actId = self.m_viewModel.activityId,
        tasteChoice = choice
      },
      {
        onProceed = Event.Create(self, self._HandleCheckinVsRsp, choice)})
end




function CheckinVsMainDlg:_HandleCheckinVsRsp(response, choice)
  self.m_viewModel:UpdatePlayerData()
  self.m_viewModel:NotifyUpdate()

  if choice == CheckinVsDefine.TasteChoice.NONE then
    if response.items ~= nil and #response.items > 0  then
      UIMiscHelper.ShowGainedItems(response.items)
    end
  else
    self.m_isAnimPlay = true
    self.m_mainView:PlayBoatAnim(choice)
    TorappuAudio.PlayUI(self._boatUrgeAudioName)
    self:Delay(self.SHOW_GAINED_ITEMS_DELAY, function()
      if response.items ~= nil and #response.items > 0  then
        UIMiscHelper.ShowGainedItems(response.items)
      end
      self.m_isAnimPlay = false
    end)
  end
end