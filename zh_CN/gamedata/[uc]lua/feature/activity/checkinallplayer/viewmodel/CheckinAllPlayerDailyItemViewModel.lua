



local CheckinAllPlayerDailyItemViewModel = Class("CheckinAllPlayerDailyItemViewModel");
function CheckinAllPlayerDailyItemViewModel:ctor()
  self.state = CheckinAllPlayerRewardStatus.NONE;
end

return CheckinAllPlayerDailyItemViewModel;