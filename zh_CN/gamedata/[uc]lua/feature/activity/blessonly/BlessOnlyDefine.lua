BlessOnlyServiceCode = {
  GET_CHECK_IN_REWARD = "/activity/actBlessOnly/getCheckInReward",
  CHANGE_FESTIVAL_CHAR = "/activity/actBlessOnly/changeFestivalChar",
}
Readonly(BlessOnlyServiceCode);

BlessOnlyPanelState = {
  HOME = 0,
  PACKET = 1,
  BLESS_COLLECTION = 2,
}
Readonly(BlessOnlyPanelState);

BlessOnlyRewardType = {
  NORMAL = 0,
  FESTIVAL = 1,
}
Readonly(BlessOnlyRewardType);

BlessOnlyCheckInState = {
  RECEIVED = 0,
  AVAIL = 1,
  DISABLE = 2,
}
Readonly(BlessOnlyCheckInState);

BlessOnlyBlessListState = {
  HORIZONTAL = 1,
  VERTICAL = 2,
}
Readonly(BlessOnlyBlessListState);