ReturnV2StateTabStatus = {
  STATE_TAB_CHECKIN = 0,
  STATE_TAB_TASK = 1,
  STATE_TAB_ALL_OPEN = 2,
}
ReturnV2StateTabStatus = Readonly(ReturnV2StateTabStatus);

ReturnV2TaskState = {
  TASK_DOING = 0,
  TASK_CAN_CLAIM = 1,
  TASK_CLAIMED = 2,
}
ReturnV2TaskState = Readonly(ReturnV2TaskState);

ReturnV2TaskSortState = {
  COMPLETE = 0,
  UNCOMPLETE = 1,
  CONFIRMED = 2,
}
ReturnV2TaskSortState = Readonly(ReturnV2TaskSortState);

ReturnV2TaskGroupState = {
  UNCOMPLETE = 0,
  HAVE_REWARD = 1,
  ALL_COMPLETED = 2,
}
ReturnV2TaskGroupState = Readonly(ReturnV2TaskGroupState);

ReturnV2OnceRewardStatus = {
  READY = 0,
  GOT = 1,
  TIME_OUT = 2,
  ERROR = 3,
}
ReturnV2OnceRewardStatus = Readonly(ReturnV2OnceRewardStatus);

ReturnV2ServiceCode = {
  GET_DISPOSABLE_REWARD = "/backflowv2/getDisposableReward";
  GET_SIGNIN_REWARD = "/backflowv2/getSignInReward";
  GET_MISSION_REWARD = "/backflowv2/getMissionReward";
  AUTO_GET_REWARD = "/backflowv2/autoGetReward";
  GET_POINT_REWARD = "/backflowv2/getPointReward";
}
ReturnV2ServiceCode = Readonly(ReturnV2ServiceCode);

ReturnV2PriceRewardState = {
  UNCOMPLETE = 0,
  CAN_CLAIM = 1,
  CLAIMED = 2,
}
ReturnV2PriceRewardState = Readonly(ReturnV2PriceRewardState);

ReturnV2DailySupplyState = {
  UNCOMPLETE = 0,
  CAN_CLAIM = 1,
  CLAIMED = 2,
}
ReturnV2DailySupplyState = Readonly(ReturnV2DailySupplyState);

ReturnV2CheckInState = {
  STATE_CHECKIN_RECEIVED   = 0,
  STATE_CHECKIN_AVAILABLE  = 1,
}
ReturnV2CheckInState = Readonly(ReturnV2CheckInState);