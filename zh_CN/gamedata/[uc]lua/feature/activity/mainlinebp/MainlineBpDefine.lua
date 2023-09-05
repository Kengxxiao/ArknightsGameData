MainlineBpServiceCode = {
  CONFIRM_MISSION = "/activity/confirmActivityMission",
  CONFIRM_ALL_MISSION = "/activity/confirmActivityMissionList",
  CONFIRM_BP_LIMIT_REWARD = "/activity/actMainlineBP/rewardMilestone",
  CONFIRM_BP_ALL_REWAED = "/activity/actMainlineBP/rewardAll",
  CONFIRM_BP_UNLIMIT_REWAED = "/activity/actMainlineBP/rewardInf",
}

MainlineBpMissionItemType = {
  MISSION_GROUP = 0,
  MISSION = 1,
  BANNER = 2,
}

MainlineBpMissionState = {
  COMPLETE = 0,
  UNCOMPLETE = 1,
  CONFIRMED = 2,
}

MainlineBpTabState = {
  MISSION = 0,
  BP = 1,
}

MainlineBpLimitBpItemType = {
  REWARD = 0,
  FURTURE_TIPS = 1,
}

MainlineBpLimitBpItemState = {
  NOT_IN_CLAIM_AND_NOT_PASS = 0,
  NOT_IN_CLAIM_AND_LACK_COUNT = 1,
  NOT_IN_CLAIM_AND_ENOUGH_COUNT = 2,
  IN_CLAIM_AND_NOT_PASS = 3,
  IN_CLAIM_AND_LACK_COUNT_PASS = 4,
  IN_CLAIM_AND_CAN_CLAIM = 5,
  IN_CLAIM_AND_CLAIMED = 6,
}

MainlineBpLimitBpItemRewardState = {
  LOCK = 0,
  UNLOCK = 1,
  OPEN = 2,
  CONFIRMED = 3,
}

MainlineBpLimitBpItemTipsState = {
  NOT_IN_CLAIM_AND_LACK_COUNT = 0,
  NOT_IN_CLAIM_AND_ENOUGH_COUNT = 1,
  IN_CLAIM_AND_LACK_COUNT = 2,
  IN_CLAIM_AND_ENOUGH_COUNT_NOT_PASS = 3,
  IN_CLAIM_AND_CAN_CLAIM = 4,
  IN_CLAIM_AND_CLAIMED = 5,
}

MainlineBpLimitBpItemProgressLineState = {
  NOT_ENOUGH = 0,
  CUR_ENOUGH_BUT_NEXT_NOT = 1,
  CUR_AND_NEXT_ENOUGH = 2,
}

MainlineBpUnlimitBpState = {
  NOT_IN_CLAIM = 0,
  IN_CLAIM_AND_CANT_CLAIM = 1,
  IN_CLAIM_AND_CAN_CLAIM = 2,
}