
LuaActivityUtil = ModelMgr.DefineModel("LuaActivityUtil")

local eutils = CS.Torappu.Lua.Util

function LuaActivityUtil:OnInit()
  CS.Torappu.UI.LuaActivityUtil.BindInterface(self)
end

function LuaActivityUtil:OnDispose()
  CS.Torappu.UI.LuaActivityUtil.BindInterface(nil)
end

local HOME_WEIGHT_DAILY_PRAY = 500;
local HOME_WEIGHT_GRID_GACHA = 510;
local HOME_WEIGHT_GRID_GACHA_V2 = 520;
local HOME_WEIGHT_FLOAT_PARADE = 530;
local HOME_WEIGHT_DAILY_FLIP = 540;
local HOME_WEIGHT_CHECKIN_ALLPLAYER = 550;
local HOME_WEIGHT_SWITCH_ONLY = 560;
local HOME_WEIGHT_CHECKIN_VS = 570;
local HOME_WEIGHT_UNIQUE_ONLY = 580;
local HOME_WEIGHT_BLESS_ONLY = 590;
local HOME_WEIGHT_ACTACCESS = 595;

local HOME_WEIGHT_MAIN_BUFF = 600;
local HOME_WEIGHT_MAINLINE_BP = 610;





local function _FindValidPrayOnlyActs(validActs, uncompleteActs, unfinishedActs, finishedActs)
  local actList = CS.Torappu.UI.ActivityUtil.FindValidPrayOnlyActs()
  if actList == nil then
    return
  end
  for i = 0, actList.Count - 1 do 
    local actId = actList[i]
    local validAct = CS.Torappu.UI.ActivityUtil.SortableActivity(actId, HOME_WEIGHT_DAILY_PRAY)
    validActs:Add(validAct)
    if CS.Torappu.UI.ActivityUtil.CheckIfPrayOnlyActUncomplete(actId) then
      uncompleteActs:Add(validAct)
    end
    unfinishedActs:Add(validAct)
  end
end





function LuaActivityUtil:_FindValidFlipOnlyActs(validActs, uncompleteActs, unfinishedActs, finishedActs)
  local actList = CS.Torappu.UI.ActivityUtil.FindValidFlipOnlyActs()
  if actList == nil then
    return
  end
  for i = 0, actList.Count - 1 do 
    local actId = actList[i]
    local validAct = CS.Torappu.UI.ActivityUtil.SortableActivity(actId, HOME_WEIGHT_DAILY_FLIP)
    validActs:Add(validAct)
    if self:CheckIfActivityUncomplete(CS.Torappu.ActivityType.FLIP_ONLY, actId) then
      uncompleteActs:Add(validAct);
    end
    if self:_CheckIfActivityFinished(CS.Torappu.ActivityType.FLIP_ONLY, validAct) then
      finishedActs:Add(validAct)
    else
      unfinishedActs:Add(validAct)
    end
  end
end





local function _FindValidGridGachaActs(validActs, uncompleteActs, unfinishedActs, finishedActs)
  local actList = CS.Torappu.UI.ActivityUtil.FindValidGridGachaActs()
  if actList == nil then
    return
  end
  for i = 0, actList.Count - 1 do
    local actId = actList[i]
    local validAct = CS.Torappu.UI.ActivityUtil.SortableActivity(actId, HOME_WEIGHT_GRID_GACHA)
    validActs:Add(validAct)
    if CS.Torappu.UI.ActivityUtil.CheckIfGridGachaActUncomplete(actId) then
      uncompleteActs:Add(validAct)
    end
    unfinishedActs:Add(validAct)
  end
end





function LuaActivityUtil:_FindValidGridGachaV2Acts(validActs, uncompleteActs, unfinishedActs, finishedActs)
  local actList = {};

  local actList = CS.Torappu.UI.ActivityUtil.FindValidActs(CS.Torappu.ActivityType.GRID_GACHA_V2);
  if actList == nil then
    return;
  end
  for i = 0, actList.Count - 1 do
    local actId = actList[i];
    local validAct = CS.Torappu.UI.ActivityUtil.SortableActivity(actId, HOME_WEIGHT_GRID_GACHA_V2);
    validActs:Add(validAct);
    if self:CheckIfActivityUncomplete(CS.Torappu.ActivityType.GRID_GACHA_V2, actId) then
      uncompleteActs:Add(validAct);
    end
    if self:_CheckIfActivityFinished(CS.Torappu.ActivityType.GRID_GACHA_V2, validAct) then
      finishedActs:Add(validAct)
    else
      unfinishedActs:Add(validAct)
    end
  end
end





function LuaActivityUtil:_FindValidFloatParadeAct(validActs, uncompleteActs, unfinishedActs, finishedActs)
  local actList = CS.Torappu.UI.ActivityUtil.FindValidActs(CS.Torappu.ActivityType.FLOAT_PARADE);
  if actList == nil then
    return;
  end

  for i = 0, actList.Count - 1 do
    local actId = actList[i];
    local validAct = CS.Torappu.UI.ActivityUtil.SortableActivity(actId, HOME_WEIGHT_FLOAT_PARADE);
    validActs:Add(validAct);
    if self:_CheckIfFloatParadeUncomplete(actId) then
      uncompleteActs:Add(validAct);
    end
    if self:_CheckIfActivityFinished(CS.Torappu.ActivityType.FLOAT_PARADE, validAct) then
      finishedActs:Add(validAct)
    else
      unfinishedActs:Add(validAct)
    end
  end

end





function LuaActivityUtil:_FindValidMainlineBuffAct(validActs, uncompleteActs, unfinishedActs, finishedActs)
  local actList = CS.Torappu.UI.ActivityUtil.FindValidActs(CS.Torappu.ActivityType.MAIN_BUFF);
  if actList == nil then
    return;
  end

  for i = 0, actList.Count - 1 do
    local actId = actList[i];
    local validAct = CS.Torappu.UI.ActivityUtil.SortableActivity(actId, HOME_WEIGHT_MAIN_BUFF);
    validActs:Add(validAct);
    if self:CheckIfActivityUncomplete(CS.Torappu.ActivityType.MAIN_BUFF, actId) then
      uncompleteActs:Add(validAct);
    end
    if self:_CheckIfActivityFinished(CS.Torappu.ActivityType.MAIN_BUFF, validAct) then
      finishedActs:Add(validAct)
    else
      unfinishedActs:Add(validAct)
    end
  end
end





function LuaActivityUtil:_FindValidCheckinAllActs(validActs, uncompleteActs, unfinishedActs, finishedActs)
  local actList = CS.Torappu.UI.ActivityUtil.FindValidActs(CS.Torappu.ActivityType.CHECKIN_ALL_PLAYER);
  if actList == nil then
    return;
  end

  for i = 0, actList.Count - 1 do
    local actId = actList[i];
    local validAct = CS.Torappu.UI.ActivityUtil.SortableActivity(actId, HOME_WEIGHT_CHECKIN_ALLPLAYER);
    validActs:Add(validAct);
    if self:_CheckIfCheckinAllUncomplete(actId) then
      uncompleteActs:Add(validAct);
    end
    if self:_CheckIfActivityFinished(CS.Torappu.ActivityType.CHECKIN_ALL_PLAYER, validAct) then
      finishedActs:Add(validAct)
    else
      unfinishedActs:Add(validAct)
    end
  end
end





function LuaActivityUtil:_FindValidCheckinVsActs(validActs, uncompleteActs, unfinishedActs, finishedActs)
  local actList = CS.Torappu.UI.ActivityUtil.FindValidActs(CS.Torappu.ActivityType.CHECKIN_VS)
  if actList == nil then
    return
  end

  for i = 0, actList.Count - 1 do
    local actId = actList[i]
    local validAct = CS.Torappu.UI.ActivityUtil.SortableActivity(actId, HOME_WEIGHT_CHECKIN_VS)
    validActs:Add(validAct)
    if self:CheckIfActivityUncomplete(CS.Torappu.ActivityType.CHECKIN_VS, actId) then
      uncompleteActs:Add(validAct)
    end
    if self:_CheckIfActivityFinished(CS.Torappu.ActivityType.CHECKIN_VS, validAct) then
      finishedActs:Add(validAct)
    else
      unfinishedActs:Add(validAct)
    end
  end
end





function LuaActivityUtil:_FindValidSwitchOnly(validActs, uncompleteActs, unfinishedActs, finishedActs)
  local actList = CS.Torappu.UI.ActivityUtil.FindValidActs(CS.Torappu.ActivityType.SWITCH_ONLY);
  if actList == nil then
    return;
  end
  for i = 0, actList.Count - 1 do
    local actId = actList[i];
    local validAct = CS.Torappu.UI.ActivityUtil.SortableActivity(actId, HOME_WEIGHT_SWITCH_ONLY);
    validActs:Add(validAct);
    if self:_CheckIfSwitchOnlyUncomplete(actId) then
      uncompleteActs:Add(validAct);
    end
    if self:_CheckIfActivityFinished(CS.Torappu.ActivityType.SWITCH_ONLY, validAct) then
      finishedActs:Add(validAct)
    else
      unfinishedActs:Add(validAct)
    end
  end
end





function LuaActivityUtil:_FindValidUniqueOnly(validActs, uncompleteActs, unfinishedActs, finishedActs)
  local actList = CS.Torappu.UI.ActivityUtil.FindValidActs(CS.Torappu.ActivityType.UNIQUE_ONLY);
  if actList == nil then
    return;
  end

  for i = 0, actList.Count - 1 do
    local actId = actList[i];
    local validAct = CS.Torappu.UI.ActivityUtil.SortableActivity(actId, HOME_WEIGHT_UNIQUE_ONLY);
    validActs:Add(validAct);
    if self:_CheckIfUniqueOnlyUncomplete(actId) then
      uncompleteActs:Add(validAct);
    end
    if self:_CheckIfActivityFinished(CS.Torappu.ActivityType.UNIQUE_ONLY, validAct) then
      finishedActs:Add(validAct)
    else
      unfinishedActs:Add(validAct)
    end
  end
end






function LuaActivityUtil:_FindValidBlessOnly(validActs, uncompleteActs, unfinishedActs, finishedActs)
  local actList = CS.Torappu.UI.ActivityUtil.FindValidActs(CS.Torappu.ActivityType.BLESS_ONLY);
  if actList == nil then
    return;
  end

  for i = 0, actList.Count - 1 do
      local actId = actList[i];
      local validAct = CS.Torappu.UI.ActivityUtil.SortableActivity(actId, HOME_WEIGHT_BLESS_ONLY);
      validActs:Add(validAct);
      if self:_CheckIfBlessOnlyUncomplete(actId) then
        uncompleteActs:Add(validAct);
      end
      if self:_CheckIfActivityFinished(CS.Torappu.ActivityType.BLESS_ONLY, validAct) then
        finishedActs:Add(validAct)
      else
        unfinishedActs:Add(validAct)
      end
  end
end





function LuaActivityUtil:_FindValidCheckInAccess(validActs, uncompleteActs, unfinishedActs, finishedActs)
  local actList = CS.Torappu.UI.ActivityUtil.FindValidActs(CS.Torappu.ActivityType.CHECKIN_ACCESS);
  if actList == nil then
    return;
  end

  for i = 0, actList.Count - 1 do
      local actId = actList[i];
      local validAct = CS.Torappu.UI.ActivityUtil.SortableActivity(actId, HOME_WEIGHT_ACTACCESS);
      validActs:Add(validAct);
      if self:_CheckIfActAccessUncomplete(actId) then
        uncompleteActs:Add(validAct);
      end
      if self:_CheckIfActivityFinished(CS.Torappu.ActivityType.CHECKIN_ACCESS, validAct) then
        finishedActs:Add(validAct)
      else
        unfinishedActs:Add(validAct)
      end
  end
end






function LuaActivityUtil:_FindValidMainlineBpAct(validActs, uncompleteActs, unfinishedActs, finishedActs)
  local actList = CS.Torappu.UI.ActivityUtil.FindValidActs(CS.Torappu.ActivityType.MAINLINE_BP);
  if actList == nil then
    return;
  end
  for i = 0, actList.Count - 1 do
    local actId = actList[i];
    local validAct = CS.Torappu.UI.ActivityUtil.SortableActivity(actId, HOME_WEIGHT_MAINLINE_BP);
    validActs:Add(validAct);
    if self:CheckIfActivityUncomplete(CS.Torappu.ActivityType.MAINLINE_BP, actId) then
      uncompleteActs:Add(validAct);
    end
    if self:_CheckIfActivityFinished(CS.Torappu.ActivityType.MAINLINE_BP, validAct) then
      finishedActs:Add(validAct)
    else
      unfinishedActs:Add(validAct)
    end
  end
end





function LuaActivityUtil:_FindValidCheckinVideoActs(validActs, uncompleteActs, unfinishedActs, finishedActs)
  local actList = CS.Torappu.UI.ActivityUtil.FindValidActs(CS.Torappu.ActivityType.CHECKIN_VIDEO);
  if actList == nil then
    return;
  end
  for i = 0, actList.Count - 1 do
    local actId = actList[i];
    local validAct = CS.Torappu.UI.ActivityUtil.SortableActivity(actId, HOME_WEIGHT_MAINLINE_BP);
    validActs:Add(validAct);
    if self:CheckIfActivityUncomplete(CS.Torappu.ActivityType.CHECKIN_VIDEO, actId) then
      uncompleteActs:Add(validAct);
    end
    if self:_CheckIfActivityFinished(CS.Torappu.ActivityType.CHECKIN_VIDEO, validAct) then
      finishedActs:Add(validAct)
    else
      unfinishedActs:Add(validAct)
    end
  end
end




function LuaActivityUtil:FindValidHomeActs(validActs, uncompleteActs, unfinishedActs, finishedActs)
  
  _FindValidPrayOnlyActs(validActs, uncompleteActs, unfinishedActs, finishedActs)
  _FindValidGridGachaActs(validActs, uncompleteActs, unfinishedActs, finishedActs)
  self:_FindValidFlipOnlyActs(validActs, uncompleteActs, unfinishedActs, finishedActs)
  self:_FindValidGridGachaV2Acts(validActs, uncompleteActs, unfinishedActs, finishedActs);
  self:_FindValidFloatParadeAct(validActs, uncompleteActs, unfinishedActs, finishedActs);
  self:_FindValidMainlineBuffAct(validActs, uncompleteActs, unfinishedActs, finishedActs);
  self:_FindValidCheckinAllActs(validActs, uncompleteActs, unfinishedActs, finishedActs);
  self:_FindValidCheckinVsActs(validActs, uncompleteActs, unfinishedActs, finishedActs);
  self:_FindValidSwitchOnly(validActs,uncompleteActs, unfinishedActs, finishedActs);
  self:_FindValidUniqueOnly(validActs,uncompleteActs, unfinishedActs, finishedActs);
  self:_FindValidBlessOnly(validActs,uncompleteActs, unfinishedActs, finishedActs);
  self:_FindValidMainlineBpAct(validActs, uncompleteActs, unfinishedActs, finishedActs);
  self:_FindValidCheckInAccess(validActs,uncompleteActs, unfinishedActs, finishedActs);
  self:_FindValidCheckinVideoActs(validActs, uncompleteActs, unfinishedActs, finishedActs);
end


local DEFINE_CLS_FUNCS = {
  COLLECTION = function(clsName, config)
    DlgMgr.DefineDialog(clsName, config.dlgPath, CollectionMainDlg)
  end,
  LOGIN_ONLY = function(clsName, config)
    DlgMgr.DefineDialog(clsName, config.dlgPath, LoginOnlyDlg)
  end,
  PRAY_ONLY = function(clsName, config)
    DlgMgr.DefineDialog(clsName, config.dlgPath, PrayOnlyMainDlg)
  end,
  GRID_GACHA = function(clsName, config)
    DlgMgr.DefineDialog(clsName, config.dlgPath, GridGachaMainDlg)
  end,
  GRID_GACHA_V2 = function(clsName, config)
    DlgMgr.DefineDialog(clsName, config.dlgPath, GridGachaV2MainDlg)
  end,
  FLOAT_PARADE = function(clsName, config)
    DlgMgr.DefineDialog(clsName, config.dlgPath, FloatParadeMainDlg)
  end,
  MAIN_BUFF = function(clsName, config)
    DlgMgr.DefineDialog(clsName, config.dlgPath, MainlineBuffMainDlg)
  end,
  FLIP_ONLY = function(clsName, config)
    DlgMgr.DefineDialog(clsName, config.dlgPath, ActFlipMainDlg)
  end,
  CHECKIN_ALL_PLAYER = function(clsName, config)
    DlgMgr.DefineDialog(clsName, config.dlgPath, CheckinAllPlayerMainDlg)
  end,
  CHECKIN_VS = function(clsName, config)
    DlgMgr.DefineDialog(clsName, config.dlgPath, CheckinVsMainDlg)
  end,
  SWITCH_ONLY = function (clsName, config)
    DlgMgr.DefineDialog(clsName, config.dlgPath, SwitchOnlyDlg)
  end,
  UNIQUE_ONLY = function (clsName, config)
    DlgMgr.DefineDialog(clsName, config.dlgPath, UniqueOnlyDlg)
  end,
  MAINLINE_BP = function(clsName, config)
    DlgMgr.DefineDialog(clsName, config.dlgPath, MainlineBpMainDlg)
  end,
  BLESS_ONLY = function(clsName, config)
    DlgMgr.DefineDialog(clsName, config.dlgPath, BlessOnlyMainDlg)
  end,
  CHECKIN_ACCESS = function(clsName, config)
    DlgMgr.DefineDialog(clsName, config.dlgPath, CheckinAccessMainDlg)
  end,
  CHECKIN_VIDEO = function(clsName, config)
    DlgMgr.DefineDialog(clsName, config.dlgPath, CheckinVideoDlg);
  end
}






local function _DefineActDialogCls(clsName, config)
  local overrideBaseCls = config.overrideBaseCls
  if overrideBaseCls ~= nil and overrideBaseCls ~= "" then
    
    local baseCls = DlgMgr.GetDialogCls(overrideBaseCls)
    if baseCls == nil then
      eutils.LogError("Couldn't find lua cls " .. overrideBaseCls)
      return false
    end
    DlgMgr.DefineDialog(clsName, config.dlgPath, baseCls)
    return true
  end
  
  local createFunc = DEFINE_CLS_FUNCS[config.actType]
  if createFunc == nil then
    return false
  end
  createFunc(clsName, config)
  return true
end



function LuaActivityUtil:EnsureActivityDialogClass(config)
  local targetClsName = eutils.Format("{0}Dlg", string.upper(config.actId))
  local existCls = DlgMgr.GetDialogCls(targetClsName)
  if existCls ~= nil then
    return targetClsName
  end
  
  if _DefineActDialogCls(targetClsName, config) then
    return targetClsName
  end

  return nil
end




function LuaActivityUtil:CheckIfActivityUncomplete(type, actId)
  if type == nil or actId == nil then
    return false;
  end
  
  if type == CS.Torappu.ActivityType.GRID_GACHA_V2 then
    return self:_CheckIfGridGachaV2Uncomplete(actId);
  elseif type == CS.Torappu.ActivityType.FLOAT_PARADE then
    return self:_CheckIfFloatParadeUncomplete(actId);
  elseif type == CS.Torappu.ActivityType.MAIN_BUFF then
    return self:_CheckIfMainlineBuffUncomplete(actId);
  elseif type == CS.Torappu.ActivityType.FLIP_ONLY then
    return self:_CheckIfFlipUncomplete(actId);
  elseif type == CS.Torappu.ActivityType.CHECKIN_ALL_PLAYER then
    return self:_CheckIfCheckinAllUncomplete(actId);
  elseif type == CS.Torappu.ActivityType.CHECKIN_VS then
    return self:_CheckIfCheckinVsUncomplete(actId);
  elseif type == CS.Torappu.ActivityType.SWITCH_ONLY then
    return self:_CheckIfSwitchOnlyUncomplete(actId);
  elseif type == CS.Torappu.ActivityType.UNIQUE_ONLY then
    return self:_CheckIfUniqueOnlyUncomplete(actId);
  elseif type == CS.Torappu.ActivityType.BLESS_ONLY then
    return self:_CheckIfBlessOnlyUncomplete(actId);
  elseif type == CS.Torappu.ActivityType.MAINLINE_BP then
    return self:_CheckIfMainlineBpUncomplete(actId);
  elseif type == CS.Torappu.ActivityType.CHECKIN_ACCESS then
    return self:_CheckIfActAccessUncomplete(actId);
  elseif type == CS.Torappu.ActivityType.CHECKIN_VIDEO then
    return self:_CheckIfCheckinVideoUncomplete(actId);
  else
    return false;
  end
end

function LuaActivityUtil:_CheckIfGridGachaV2Uncomplete(actId)
  local actList = CS.Torappu.PlayerData.instance.data.activity.gridGachaV2ActivityList;
  if actList == nil then
    return false;
  end
  local success, actData = actList:TryGetValue(actId);
  if not success then
    return false;
  end
  local data = eutils.ConvertJObjectToLuaTable(actData);
  return data.today.done == 0;
end

function LuaActivityUtil:_CheckIfFloatParadeUncomplete(actId)
  local floatParades = CS.Torappu.PlayerData.instance.data.activity.floatParadeActivityList;
  if floatParades == nil then
    return false;
  end
  local suc, playerActData = floatParades:TryGetValue(actId);
  if not suc then
    return false;
  end
  return playerActData.canRaffle;
end

function LuaActivityUtil:_CheckIfMainlineBuffUncomplete(actId)
  if actId == nil or actId == "" then
    return false;
  end

  local actList = CS.Torappu.PlayerData.instance.data.activity.mainlineBuffActivityList;
  if actList == nil then
    return false;
  end
  local success, actData = actList:TryGetValue(actId);
  if not success then
    return false;
  end

  if MainlineBuffUtil.CheckIfMissionGroupNeedComplete(actId) then
    return true;
  end

  local periodId = MainlineBuffUtil.GetCurrMainlineBuffActPeriodId(actId);
  return MainlineBuffUtil.IsPeriodChecked(actId, periodId);
end



function LuaActivityUtil:_CheckIfCheckinVsUncomplete(actId)
  local checkinVsPlayers = CS.Torappu.PlayerData.instance.data.activity.checkinVsActivityList
  if checkinVsPlayers == nil then
    return false
  end
  local suc, playerActData = checkinVsPlayers:TryGetValue(actId)
  if not suc then
    return false
  end

  return playerActData.availSignCnt > 0
end

function LuaActivityUtil:_CheckIfCheckinAllUncomplete(actId)
  local checkinAllPlayers = CS.Torappu.PlayerData.instance.data.activity.checkinAllActivityList;
  if checkinAllPlayers == nil then
    return false;
  end
  local suc, playerActData = checkinAllPlayers:TryGetValue(actId);
  if not suc then
    return false;
  end
  for pubBhvId, bhvStatus in pairs(playerActData.allRewardStatus) do
    if bhvStatus == CheckinAllPlayerRewardStatus.AVAILABLE then
      return true;
    end
  end

  for idx = 0, playerActData.history.Count -1 do
    local status = playerActData.history[idx];
    if status == CheckinAllPlayerRewardStatus.AVAILABLE then
      return true;
    end
  end
  return false;
end

function LuaActivityUtil:_CheckIfSwitchOnlyUncomplete(actId)
  local swichOnlyPlayer = CS.Torappu.PlayerData.instance.data.activity.switchOnlyList;
  if swichOnlyPlayer == nil then
    return false;
  end
  local suc, playerActData = swichOnlyPlayer:TryGetValue(actId);
  if not suc then
    return false;
  end

  local cacheKey = actId;
  local firstPop = CS.Torappu.Activity.ActLocalCacheHandler.GetParamFromCache(cacheKey) <= 0;
  if firstPop then
    return true;
  end

  for k, vStatus in pairs(playerActData.rewards) do
    if vStatus == SwitchOnlyPlayerRewardStatus.AVAILABLE then
      return true;
    end
  end
  return false;
end

function LuaActivityUtil:_CheckIfFlipUncomplete(actId)
  local actList = CS.Torappu.PlayerData.instance.data.activity.flipOnlyActivityList;
  if actList == nil then
    return false;
  end
  local success, actData = actList:TryGetValue(actId);
  if not success then
    return false;
  end
  return (actData.remainingRaffleCount > 0) or (actData.grandStatus == 1);
end

function LuaActivityUtil:_CheckIfUniqueOnlyUncomplete(actId)
  if not UniqueOnlyUtil.GetUniqueOnlyActClicked(actId) then
    return true;
  end

  if UniqueOnlyUtil.CheckIfHaveRewardCanClaimByActId(actId) then
    return true;
  end

  return false;
end

function LuaActivityUtil:_CheckIfBlessOnlyUncomplete(actId)
  return BlessOnlyUtil.CheckBlessActIsUncomplete(actId);
end

function LuaActivityUtil:_CheckIfBlessOnlyFinished(actId)
  return BlessOnlyUtil.CheckBlessActIsFinished(actId);
end

function LuaActivityUtil:_CheckIfActAccessFinished(actId)
  local playerData = CS.Torappu.PlayerData.instance.data.activity;
  if string.isNullOrEmpty(actId) or playerData.checkinAccessList == nil then
    return false;
  end
  local suc, jObject = playerData.checkinAccessList:TryGetValue(actId);
  if not suc or jObject == nil then
    return false;
  end
  local playerAccess = eutils.ConvertJObjectToLuaTable(jObject);
  if playerAccess == nil or playerAccess.rewardsCount == nil then
    return false;
  end
  local activityData = CS.Torappu.ActivityDB.data;
  if activityData == nil then
    return false;
  end

  local dynData = activityData.dynActs;
  if dynData == nil then
    return false;
  end
  local ok, jObject = dynData:TryGetValue(actId);
  if not ok then
    return false;
  end
  local actData = eutils.ConvertJObjectToLuaTable(jObject);
  if actData == nil or actData.constData == nil or actData.constData.dayCount == nil then
    return false;
  end
  return actData.constData.dayCount <= playerAccess.rewardsCount;
end

function LuaActivityUtil:_CheckIfActAccessUncomplete(actId)
  local playerData = CS.Torappu.PlayerData.instance.data.activity;
  if string.isNullOrEmpty(actId) or playerData.checkinAccessList == nil then
    return false;
  end
  local suc, jObject = playerData.checkinAccessList:TryGetValue(actId);
  if not suc then
    return false;
  end
  local playerAccess = eutils.ConvertJObjectToLuaTable(jObject);
  if playerAccess == nil or playerAccess.currentStatus == nil then
    return false;
  end
  return playerAccess.currentStatus == 1;
end



function LuaActivityUtil:_CheckIfMainlineBpUncomplete(actId)
  return MainlineBpUtil.CheckIfUncomplete(actId);
end



function LuaActivityUtil:_CheckIfCheckinVideoUncomplete(actId)
  local playerData = CheckinVideoUtil.LoadPlayerData(actId);
  if playerData == nil or playerData.history == nil then
    return false;
  end
  for index, historyInfo in pairs(playerData.history) do
    if historyInfo == 1 then
      return true;
    end
  end
  return false;
end





function LuaActivityUtil:_CheckIfActivityFinished(type, validAct)
  actId = validAct.actId.str
  if type == nil or actId == nil then
    return false
  end

  if validAct.completeType ~= CS.Torappu.ActivityCompleteType.CAN_COMPLETE then
    return false
  end

  if type == CS.Torappu.ActivityType.MAIN_BUFF then
  
  elseif type == CS.Torappu.ActivityType.FLIP_ONLY then

  elseif type == CS.Torappu.ActivityType.CHECKIN_ALL_PLAYER then
  
  elseif type == CS.Torappu.ActivityType.CHECKIN_VS then

  elseif type == CS.Torappu.ActivityType.SWITCH_ONLY then
    return self:_CheckIfSwitchOnlyFinished(actId)
  elseif type == CS.Torappu.ActivityType.UNIQUE_ONLY then
    return self:_CheckIfUniqueOnlyFinished(actId)
  elseif type == CS.Torappu.ActivityType.BLESS_ONLY then
    return self:_CheckIfBlessOnlyFinished(actId)
  elseif type == CS.Torappu.ActivityType.CHECKIN_ACCESS then
    return self:_CheckIfActAccessFinished(actId);
  elseif type == CS.Torappu.ActivityType.CHECKIN_VIDEO then
    return self:_CheckIfCheckinVideoFinished(actId);
  end
  return false
end



function LuaActivityUtil:_CheckIfSwitchOnlyFinished(actId)
  local swichOnlyPlayer = CS.Torappu.PlayerData.instance.data.activity.switchOnlyList
  if swichOnlyPlayer == nil then
    return false
  end
  local suc, playerActData = swichOnlyPlayer:TryGetValue(actId)
  if not suc then
    return false
  end

  local cacheKey = actId
  local firstPop = CS.Torappu.Activity.ActLocalCacheHandler.GetParamFromCache(cacheKey) <= 0
  if firstPop then
    return false
  end

  for k, vStatus in pairs(playerActData.rewards) do
    if vStatus ~= SwitchOnlyPlayerRewardStatus.GOT then
      return false
    end
  end
  return true
end



function LuaActivityUtil:_CheckIfCheckinVideoFinished(actId)
  local gameData = CheckinVideoUtil.LoadGameData(actId);
  local playerData = CheckinVideoUtil.LoadPlayerData(actId);
  if gameData == nil or gameData.checkInList == nil or playerData == nil then
    return true;
  end
  local rewardCount = 0;
  for index, data in pairs(gameData.checkInList) do
    rewardCount = rewardCount + 1;
  end
  if playerData.history == nil or #playerData.history < rewardCount then
    return false;
  end
  for index, historyInfo in pairs(playerData.history) do
    if historyInfo == 1 then
      return false;
    end
  end
  return true;
end



function LuaActivityUtil:_CheckIfUniqueOnlyFinished(actId)
  return UniqueOnlyUtil.CheckIfHaveRewardClaimedByActId(actId)
end