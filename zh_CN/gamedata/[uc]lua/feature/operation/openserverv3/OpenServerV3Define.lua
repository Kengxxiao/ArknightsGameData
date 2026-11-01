OpenServerV3ServiceCode = {
  GET_CHECK_IN_REWARD = "/openServerV3/getCheckInReward";
  GET_MILESTONE_REWARD = "/openServerV3/getMilestoneReward";
};
OpenServerV3ServiceCode = Readonly(OpenServerV3ServiceCode);

OpenServerV3TabState = {
  STATE_TAB_CHECK_IN     = 0,
  STATE_TAB_MISSION      = 1,
  STATE_TAB_STAGE        = 2,
  STATE_TAB_GIFT_PACKAGE = 3,
};
OpenServerV3TabState = Readonly(OpenServerV3TabState);

OpenServerV3CheckInItemState = {
  UNCOMPLETE = 0,
  COMPLETE   = 1,
  CONFIRMED  = 2,
};
OpenServerV3CheckInItemState = Readonly(OpenServerV3CheckInItemState);

OpenServerV3CheckInSpecialRewardState = {
  UNOWNED    = 0,
  OWNED      = 1,
  USED       = 2,
}
OpenServerV3CheckInSpecialRewardState = Readonly(OpenServerV3CheckInSpecialRewardState);

OpenServerV3MissionPageState = {
  TASK      = 0,
  MILESTONE = 1,
};
OpenServerV3MissionPageState = Readonly(OpenServerV3MissionPageState);

OpenServerV3MissionItemState = {
  UNCOMPLETE = 0,
  COMPLETE   = 1,
  CONFIRMED  = 2,
};
OpenServerV3MissionItemState = Readonly(OpenServerV3MissionItemState);

OpenServerV3MilestoneItemState = {
  UNCOMPLETE = 0,
  COMPLETE   = 1,
  CONFIRMED  = 2,
};
OpenServerV3MilestoneItemState = Readonly(OpenServerV3MilestoneItemState);