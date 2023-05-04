require "Feature/Activity/CheckinAllPlayer/CheckinAllPlayerViewModel"
local CheckinAllPlayerServiceCode = {
  SYNC_DATA = "/activity/checkinAllPlayer/syncBehaviorData";
  CHECKIN = "/activity/checkinAllPlayer/getActivityCheckInReward";
  GET_ALL_REWARD = "/activity/checkinAllPlayer/getAllBehaviorReward";
}
CheckinAllPlayerServiceCode = Readonly(CheckinAllPlayerServiceCode);







CheckinAllPlayerMainDlg = Class("CheckinAllPlayerMainDlg", DlgBase);
CheckinAllPlayerMainDlg.REQ_MIN_INTERVAL = 5;
CheckinAllPlayerMainDlg.REQ_MAX_CNT_ONE_MINUTE = 5;

CheckinAllPlayerMainDlg.sReqInfo = nil;

local CheckinAllPlayerMainView = require "Feature/Activity/CheckinAllPlayer/View/CheckinAllPlayerMainView"
local CheckinAllPlayerCheckinView = require "Feature/Activity/CheckinAllPlayer/View/CheckinAllPlayerCheckinView"
local CheckinAllPlayerBhvRewardView = require "Feature/Activity/CheckinAllPlayer/View/CheckinAllPlayerBhvRewardView"


function CheckinAllPlayerMainDlg:OnInit()
  local actId = self.m_parent:GetData("actId");
  self.m_viewModel = self:CreateViewModel(CheckinAllPlayerViewModel);
  self.m_viewModel:Init(actId);

  self:CreateWidgetByGO(CheckinAllPlayerMainView, self._mainView);
  local checkinView = self:CreateWidgetByGO(CheckinAllPlayerCheckinView, self._dailyCheckView);
  checkinView.checkEvent = Event.Create(self, self._EventCheckin);

  local leftRewardView = self:CreateWidgetByGO(CheckinAllPlayerBhvRewardView, self._leftRewardView);
  leftRewardView.index = 1;
  leftRewardView.eventGet = Event.Create(self, self._EventGetBehaviourReward);
  local rightRewardView = self:CreateWidgetByGO(CheckinAllPlayerBhvRewardView, self._rightRewardView);
  rightRewardView.index = 2;
  rightRewardView.eventGet = Event.Create(self, self._EventGetBehaviourReward);

  self.m_viewModel:UpdateState(false);
  self.m_viewModel:NotifyUpdate();

  self:_ReqFreshData();
end

function CheckinAllPlayerMainDlg:_ReqFreshData()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end

  local currTime = CS.Torappu.DateTimeUtil.currentTime;
  local reqInfo = CheckinAllPlayerMainDlg.sReqInfo;
  if reqInfo then
    
    local pass = currTime - reqInfo.lastReqTime;
    if pass.TotalSeconds < self.REQ_MIN_INTERVAL then
      self:_HandleRevFreshData();
      return;
    end
    
    local cntPass = currTime - reqInfo.cntBeginTime;
    if cntPass.TotalSeconds < 60 then
      if reqInfo.countOneMinute >= self.REQ_MAX_CNT_ONE_MINUTE  then
        self:_HandleRevFreshData();
        return;
      end
    else
      
      reqInfo.countOneMinute = 0;
      reqInfo.cntBeginTime = currTime;
    end
    
    reqInfo.countOneMinute = reqInfo.countOneMinute + 1;
    reqInfo.lastReqTime = currTime;
  else
    reqInfo = {
      lastReqTime = currTime,
      cntBeginTime = currTime,
      countOneMinute = 1,
    }
  end
  CheckinAllPlayerMainDlg.sReqInfo = reqInfo;
  
  UISender.me:SendRequest(CheckinAllPlayerServiceCode.SYNC_DATA,
  {
    activityId = self.m_viewModel.activityId,
  }, 
  {
    onProceed = Event.Create(self, self._HandleRevFreshData);
  });
end
function CheckinAllPlayerMainDlg:_HandleRevFreshData()
  self.m_viewModel:UpdateState(true);
  self.m_viewModel:NotifyUpdate();
end

function CheckinAllPlayerMainDlg:_EventCheckin(dayIdx)
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  UISender.me:SendRequest(CheckinAllPlayerServiceCode.CHECKIN,
  {
    activityId = self.m_viewModel.activityId,
    index = dayIdx,
  }, 
  {
    onProceed = Event.Create(self, self._HandleCheckinResponse);
  });
end

function CheckinAllPlayerMainDlg:_HandleCheckinResponse(response)
  if response.items and #response.items > 0 then
    UIMiscHelper.ShowGainedItems(response.items);
  end
  self.m_viewModel:UpdateState(true);
  self.m_viewModel:NotifyUpdate();
end

function CheckinAllPlayerMainDlg:_EventGetBehaviourReward(index)
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  local reward = self.m_viewModel.bhvRewards[index];
  if not reward then
    return;
  end

  UISender.me:SendRequest(CheckinAllPlayerServiceCode.GET_ALL_REWARD,
  {
    activityId = self.m_viewModel.activityId,
    allBehaviorId = reward.pubBhvData.allBehaviorId,
  }, 
  {
    onProceed = Event.Create(self, self._HandleGetResponse);
  });
end

function CheckinAllPlayerMainDlg:_HandleGetResponse(response)
  if response.items and #response.items > 0 then
    UIMiscHelper.ShowGainedItems(response.items);
  end
  self.m_viewModel:UpdateState(true);
  self.m_viewModel:NotifyUpdate();
end