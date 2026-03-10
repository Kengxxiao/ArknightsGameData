ReturnServiceCode = {
  GET_DISPOSABLE_REWARD = "/backflowv2/getDisposableReward";
  GET_SIGNIN_REWARD = "/backflowv2/getSignInReward";
  GET_MISSION_REWARD = "/backflowv2/getMissionReward";
  AUTO_GET_REWARD = "/backflowv2/autoGetReward";
  GET_POINT_REWARD = "/backflowv2/getPointReward";
  GET_NEWS_REWARD_SHOW = "/backflowv2/getShowDetail"
};
ReturnServiceCode = Readonly(ReturnServiceCode);

ReturnOnceRewardStatus = {
  READY = 0,
  GOT = 1,
  TIME_OUT = 2,
  ERROR = 3,
};
ReturnOnceRewardStatus = Readonly(ReturnOnceRewardStatus);

ReturnTabState = {
  STATE_TAB_CHECKIN      = 0,
  STATE_TAB_MISSION      = 1,
  STATE_TAB_NEWS         = 2,
  STATE_TAB_SPECIAL_OPEN = 3,
  STATE_TAB_PACKAGE      = 4,
};
ReturnTabState = Readonly(ReturnTabState);

ReturnMissionGroupType = {
  CLAIM_ALL = 0,
  TITLE     = 1,
  MISSION   = 2,
};
ReturnMissionGroupType = Readonly(ReturnMissionGroupType);

ReturnMissionItemState = {
  UNCOMPLETE = 0,
  COMPLETE   = 1,
  CONFIRMED  = 2,
};
ReturnMissionItemState = Readonly(ReturnMissionItemState);

ReturnMissionSortState = {
  COMPLETE   = 0,
  UNCOMPLETE = 1,
  CONFIRMED  = 2,
};
ReturnMissionSortState = Readonly(ReturnMissionSortState);

ReturnMissionTitleType = {
  DAILY  = 0,
  NORMAL = 1,
};
ReturnMissionTitleType = Readonly(ReturnMissionTitleType);

ReturnMissionGroupState = {
  UNCOMPLETE    = 0,
  HAS_REWARD    = 1,
  ALL_CONFIRMED = 2,
};
ReturnMissionGroupState = Readonly(ReturnMissionGroupState);

ReturnCheckinItemState = {
  UNCOMPLETE = 0,
  COMPLETE = 1,
  CONFIRMED   = 2,
};
ReturnCheckinItemState = Readonly(ReturnCheckinItemState);

ReturnSpecialOpenState = {
  OPEN = 0,
  PAUSE = 1,
  END = 2,
}
ReturnSpecialOpenState = Readonly(ReturnSpecialOpenState);

ReturnNewsJumpType = {
  NONE = 0,
  ACTIVITY = 1,
  ZONE = 2,
  ROGUE = 3,
  SANDBOX = 4,
}
ReturnNewsJumpType = Readonly(ReturnNewsJumpType);