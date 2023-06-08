SwitchOnlyConst = {
  ITEM_CARD_SCALE = 0.6,
  REWARD_GOT_ALPHA = 0.2,
  COLOR_UNLOCKED = "#ffffffff",
  COLOR_LOCKED = "#4a4a4aff",
}
SwitchOnlyConst = Readonly(SwitchOnlyConst);

SwitchOnlyServiceCode = {
  GET_REWARD = "/activity/getSwitchOnlyReward";
}
SwitchOnlyServiceCode = Readonly(SwitchOnlyServiceCode);

SwitchOnlyPlayerRewardStatus = {
  GOT = 2, 
  AVAILABLE = 1,
  LOCKED = 0,
}
SwitchOnlyPlayerRewardStatus = Readonly(SwitchOnlyPlayerRewardStatus);