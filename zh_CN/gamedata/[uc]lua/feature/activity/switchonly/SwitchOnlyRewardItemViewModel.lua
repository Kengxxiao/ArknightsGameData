


local SwitchOnlyRewardItemViewModel = Class("SwitchOnlyRewardItemViewModel");


function SwitchOnlyRewardItemViewModel:ctor(rewardItemShowData)
  self.reward = rewardItemShowData.itemBundle
  self.isMainReward = rewardItemShowData.isMainReward
end

return SwitchOnlyRewardItemViewModel;