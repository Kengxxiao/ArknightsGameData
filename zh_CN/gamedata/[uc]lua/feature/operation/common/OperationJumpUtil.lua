local luaUtils = CS.Torappu.Lua.Util;

OperationJumpType = {
  NONE = 0,
  ZONE_GROUP = 1,
  ROGUE = 2,
  CLIMB_TOWER = 3,
  CAMPAIGN = 4,
  BUILDING = 5,
  RECRUIT_BUILD = 6,
  DAILY_MISSION = 7,
  SANDBOX = 8,
  MAIN_STAGE = 9,
  CHAR_REPO = 10,
  WEEKLY = 11,
  SHOP = 12,
  CAMPAIGN_STAGE = 13,
  PERM_MODE = 14,
};
OperationJumpType = Readonly(OperationJumpType);


OperationJumpUtil = Class("OperationJumpUtil", nil);




local function _ToastIfLocked(lockTarget)
  local isUnlocked = CS.Torappu.UI.UIGuideController.CheckIfUnlocked(lockTarget);
  if not isUnlocked then
    CS.Torappu.UI.UIGuideController.ToastOnLockedItemClicked(lockTarget);
  end
  return isUnlocked;
end




local function _GetShopRouteTarget(param)
  if param == nil or param == "" then
    return CS.Torappu.ShopRouteTarget.NONE;
  end
  local ok, target = pcall(function()
    return CS.Torappu.EnumInfoCache(CS.Torappu.ShopRouteTarget).ConvertFromString(param);
  end);
  if ok then
    return target;
  end
  return CS.Torappu.ShopRouteTarget.NONE;
end

local function _RouteToZoneGroup()
  CS.Torappu.UI.UIRouteUtil.RouteToZoneViewType(CS.Torappu.UI.Stage.ZoneViewType.HOME);
end

local function _RouteToRoguelike(param)
  local lockTarget = CS.Torappu.UI.UILockTarget.PERM_MODE;
  if not _ToastIfLocked(lockTarget) or param == nil or param == "" then
    return;
  end
  CS.Torappu.UI.UIRouteUtil.RouteToRoguelikeTopic(param);
end

local function _RouteToSandbox(param)
  local lockTarget = CS.Torappu.UI.UILockTarget.PERM_MODE;
  if not _ToastIfLocked(lockTarget) or param == nil or param == "" then
    return;
  end
  CS.Torappu.UI.UIRouteUtil.RouteToSandboxPerm(param);
end

local function _RouteToClimbTower()
  local toast = CS.Torappu.UI.ClimbTower.ClimbTowerUtil.GetClimbTowerFuncLockedToast();
  if toast ~= nil and toast ~= "" then
    luaUtils.TextToast(toast);
    return;
  end
  CS.Torappu.UI.UIRouteUtil.RouteToClimbTower();
end

local function _RouteToCampaign()
  local lockTarget = CS.Torappu.UI.UILockTarget.CAMPAIGN_ENTRY;
  if not _ToastIfLocked(lockTarget) then
    return;
  end
  local playerCampaign = CS.Torappu.PlayerData.instance.data.campaign;
  local stageId = playerCampaign.open.rotate;
  local zoneId = CS.Torappu.CampaignDataUtil.GetStageZone(stageId);
  if stageId == nil or stageId == "" or zoneId == nil or zoneId == "" then
    return;
  end
  CS.Torappu.UI.UIRouteUtil.RouteToCampaign(zoneId, stageId);
end

local function _RouteToBuilding()
  local lockTarget = CS.Torappu.UI.UILockTarget.BUILDING_ENTRY;
  if not _ToastIfLocked(lockTarget) then
    return;
  end
  CS.Torappu.UI.UIRouteUtil.RouteToTarget(CS.Torappu.UI.UIRouteTarget.BUILDING);
end

local function _RouteToRecruitBuild()
  CS.Torappu.UI.UIRouteUtil.RouteToTarget(CS.Torappu.UI.UIRouteTarget.RECRUIT_BUILD);
end

local function _RouteToDailyMission()
  local lockTarget = CS.Torappu.UI.UILockTarget.MISSION_DAILY;
  if not _ToastIfLocked(lockTarget) then
    return;
  end
  CS.Torappu.UI.UIRouteUtil.RouteToMission(CS.Torappu.Mission.MissionPageType.DAILYMISSION);
end

local function _RouteToMainStage(param)
  if param == nil or param == "" then
    return;
  end
  local ok, available, alert = pcall(function()
    return CS.Torappu.StageDataUtil.CheckIfStageAvailable(param);
  end);
  if not ok then
    luaUtils.LogError("[OperationJumpUtil] Fail to get stage available.\n" .. available);
    return;
  end
  if ok and not available then
    if alert ~= nil and alert ~= "" then
      luaUtils.TextToast(alert);
    end
    return;
  end
  if not CS.Torappu.StageDataUtil.CheckIfStageUnlocked(param) then
    CS.Torappu.UI.UIRouteUtil.RouteToMixStory(true);
    return;
  end
  CS.Torappu.UI.UIRouteUtil.RouteToStage(nil, param);
end

local function _RouteToCharRepo()
  CS.Torappu.UI.UIRouteUtil.RouteToTarget(CS.Torappu.UI.UIRouteTarget.CHAR_REPO);
end

local function _RouteToWeekly()
  local unlocked = CS.Torappu.UI.UIGuideController.CheckIfUnlocked(CS.Torappu.UI.UILockTarget.WEEKLY_MATERIAL) or
      CS.Torappu.UI.UIGuideController.CheckIfUnlocked(CS.Torappu.UI.UILockTarget.WEEKLY_EVOLVE);
  if not unlocked then
    CS.Torappu.UI.UIGuideController.ToastOnLockedItemClicked(CS.Torappu.UI.UILockTarget.WEEKLY_MATERIAL);
    return;
  end
  CS.Torappu.UI.UIRouteUtil.RouteToZoneViewType(CS.Torappu.UI.Stage.ZoneViewType.WEEKLY);
end

local function _RouteToPermMode()
  local lockTarget = CS.Torappu.UI.UILockTarget.PERM_MODE;
  if not _ToastIfLocked(lockTarget) then
    return;
  end
  CS.Torappu.UI.UIRouteUtil.RouteToZoneViewType(CS.Torappu.UI.Stage.ZoneViewType.PERM_MODE);
end

local function _RouteToShop(param)
  local shopTarget = _GetShopRouteTarget(param);
  if shopTarget == CS.Torappu.ShopRouteTarget.NONE then
    return;
  end
  if not CS.Torappu.UI.Shop.ShopStateItemContainer.CheckIfShopRouteTargetUnlocked(shopTarget) then
    luaUtils.TextToast(CS.Torappu.StringRes.ALERT_ANNOUNE_SHOP_NOT_OPEN);
    return;
  end
  local shopParam = CS.Torappu.UI.Shop.ShopPage.Params();
  shopParam.targetShop = shopTarget;
  CS.Torappu.UI.UIRouteUtil.RouteToShopAndResetStack(shopParam);
end

local function _RouteToCampaignStage(param)
  if param == nil or param == "" then
    return;
  end
  local lockTarget = CS.Torappu.UI.UILockTarget.CAMPAIGN_ENTRY;
  if not _ToastIfLocked(lockTarget) then
    return;
  end
  if CS.Torappu.CampaignDataUtil.IsStageClosed(param) then
    luaUtils.TextToast(CS.Torappu.StringRes.ALERT_ZONE_LOCKED);
    return;
  end
  if not CS.Torappu.CampaignDataUtil.IsStageUnlocked(param) then
    luaUtils.TextToast(CS.Torappu.CampaignDataUtil.GetStageUnlockText(param));
    return;
  end
  local zoneId = CS.Torappu.CampaignDataUtil.GetStageZone(param);
  if zoneId == nil or zoneId == "" then
    return;
  end
  CS.Torappu.UI.UIRouteUtil.RouteToCampaign(zoneId, param);
end

local JUMP_HANDLERS = {
  [OperationJumpType.ZONE_GROUP] = _RouteToZoneGroup,
  [OperationJumpType.ROGUE] = _RouteToRoguelike,
  [OperationJumpType.CLIMB_TOWER] = _RouteToClimbTower,
  [OperationJumpType.CAMPAIGN] = _RouteToCampaign,
  [OperationJumpType.BUILDING] = _RouteToBuilding,
  [OperationJumpType.RECRUIT_BUILD] = _RouteToRecruitBuild,
  [OperationJumpType.DAILY_MISSION] = _RouteToDailyMission,
  [OperationJumpType.SANDBOX] = _RouteToSandbox,
  [OperationJumpType.MAIN_STAGE] = _RouteToMainStage,
  [OperationJumpType.CHAR_REPO] = _RouteToCharRepo,
  [OperationJumpType.WEEKLY] = _RouteToWeekly,
  [OperationJumpType.SHOP] = _RouteToShop,
  [OperationJumpType.CAMPAIGN_STAGE] = _RouteToCampaignStage,
  [OperationJumpType.PERM_MODE] = _RouteToPermMode,
};

local RETURN_JUMP_TYPE_MAP = {
  [CS.Torappu.ReturnJumpType.ZONE_GROUP] = OperationJumpType.ZONE_GROUP,
  [CS.Torappu.ReturnJumpType.ROGUE] = OperationJumpType.ROGUE,
  [CS.Torappu.ReturnJumpType.CLIMB_TOWER] = OperationJumpType.CLIMB_TOWER,
  [CS.Torappu.ReturnJumpType.CAMPAIGN] = OperationJumpType.CAMPAIGN,
  [CS.Torappu.ReturnJumpType.BUILDING] = OperationJumpType.BUILDING,
  [CS.Torappu.ReturnJumpType.RECRUIT_BUILD] = OperationJumpType.RECRUIT_BUILD,
  [CS.Torappu.ReturnJumpType.DAILY_MISSION] = OperationJumpType.DAILY_MISSION,
  [CS.Torappu.ReturnJumpType.SANDBOX] = OperationJumpType.SANDBOX,
};

local OPEN_SERVER_V3_JUMP_TYPE_MAP = {
  [CS.Torappu.OpenServerV3JumpType.MAIN_STAGE] = OperationJumpType.MAIN_STAGE,
  [CS.Torappu.OpenServerV3JumpType.CHAR_REPO] = OperationJumpType.CHAR_REPO,
  [CS.Torappu.OpenServerV3JumpType.WEEKLY] = OperationJumpType.WEEKLY,
  [CS.Torappu.OpenServerV3JumpType.SHOP] = OperationJumpType.SHOP,
  [CS.Torappu.OpenServerV3JumpType.BUILDING] = OperationJumpType.BUILDING,
  [CS.Torappu.OpenServerV3JumpType.CAMPAIGN_STAGE] = OperationJumpType.CAMPAIGN_STAGE,
};



function OperationJumpUtil.JumpToTarget(jumpType, param)
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  local handler = JUMP_HANDLERS[jumpType];
  if handler ~= nil then
    handler(param);
  end
end



function OperationJumpUtil.GetReturnOperationJumpType(jumpType)
  return RETURN_JUMP_TYPE_MAP[jumpType] or OperationJumpType.NONE;
end



function OperationJumpUtil.GetOpenServerV3OperationJumpType(jumpType)
  return OPEN_SERVER_V3_JUMP_TYPE_MAP[jumpType] or OperationJumpType.NONE;
end
