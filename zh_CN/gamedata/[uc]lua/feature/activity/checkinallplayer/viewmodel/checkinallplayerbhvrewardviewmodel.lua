


local CheckinAllPlayerPersonalModel = Class("CheckinAllPlayerPersonalModel");







local CheckinAllPlayerBhvRewardViewModel = Class("CheckinAllPlayerBhvRewardViewModel");
function CheckinAllPlayerBhvRewardViewModel:ctor()
  self.num = 0;
  self.status = CheckinAllPlayerRewardStatus.NONE;
  self.perBhvModels = {};
end

return CheckinAllPlayerBhvRewardViewModel;