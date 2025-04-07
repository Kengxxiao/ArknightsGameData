local luaUtils = CS.Torappu.Lua.Util;



















local CheckinAccessViewModel = Class("CheckinAccessViewModel", UIViewModel);


function CheckinAccessViewModel:LoadData(actId)
  self.actId = "";
  self.status = CheckinAccessStatus.ALL_CONFIRMED;
  self.itemList = {};
  self.m_totalCheckinDays = 0;
  self.rewardItemTip = "";
  self.actTimeTip = "";
  self.apSupplyTip = "";
  self.confirmedTimesTip = "";
  self.totalTimesTip = "";
  self.showUrlBtn = false;
  self.urlBtnDesc = "";
  self.jumpUrl = "";

  if string.isNullOrEmpty(actId) then
    return;
  end
  local activityData = CS.Torappu.ActivityDB.data;
  if activityData == nil then
    return;
  end

  local dynData = activityData.dynActs;
  if dynData == nil then
    return;
  end
  local ok, jObject = dynData:TryGetValue(actId);
  if not ok then
    luaUtils.LogError("[ActAccess] Cannot load act data of [" .. actId .. "].");
    return;
  end
  local actData = luaUtils.ConvertJObjectToLuaTable(jObject);
  self.actId = actId;
  self.m_totalCheckinDays = actData.constData.dayCount;
  local rewardStr = "";
  for idx = 1, #actData.rewardItemPerDay do 
    local itemData = actData.rewardItemPerDay[idx];
    local itemModel = CS.Torappu.UI.UIItemViewModel();
    itemModel:LoadGameData(itemData.id, itemData.type);
    itemModel.itemCount = itemData.count;
    table.insert(self.itemList, itemModel);
    if idx > 1 then
      rewardStr = rewardStr .. StringRes.SP_CHAR_NAME_SEPARATOR;
    end
    rewardStr = rewardStr .. itemModel.name .. "*" .. tostring(itemModel.itemCount);
  end
  self.rewardItemTip = luaUtils.Format(StringRes.ACT_ACCESS_REWARD_ITEM_FORMAT, rewardStr);

  if actData.apSupplyOutOfDateDict then
    for apid, endtime in pairs(actData.apSupplyOutOfDateDict) do
      local apItemData = CS.Torappu.UI.UIItemViewModel();
      apItemData:LoadGameData(apid, CS.Torappu.ItemType.NONE);
      local dateTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(endtime);
      local timedesc = CS.Torappu.Lua.Util.Format(CS.Torappu.StringRes.DATE_FORMAT_YYYY_MM_DD_HH_MM,dateTime.Year, dateTime.Month, dateTime.Day,dateTime.Hour,dateTime.Minute);
      local str = StringRes.STAGE_ACTIVITY_AP_ITEM;
      self.apSupplyTip = CS.Torappu.Lua.Util.Format(str, apItemData.name, timedesc);
      break;
    end
  end

  self.totalTimesTip = luaUtils.Format(StringRes.ACT_ACCESS_TOTAL_TIMES_FORMAT, actData.constData.dayCount);

  self.showUrlBtn = actData.constData.showUrlBtn;
  if self.showUrlBtn then
    self.jumpUrl = actData.constData.actUrl;
    self.btnColor = luaUtils.FormatColorFromData(actData.constData.colorBtn);
    self.urlBtnDesc = actData.constData.btnDescText;
  end
  self.totalTimesBkgColor = luaUtils.FormatColorFromData(actData.constData.colorTotalTimes);

  local basicInfo = activityData.basicInfo;
  if basicInfo == nil then
    return;
  end
  local suc, basicData = basicInfo:TryGetValue(self.actId);
  if not suc then
    return;
  end
  local endTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(basicData.endTime)
  self.actTimeTip = CS.Torappu.Lua.Util.Format(
      StringRes.ACT_ACCESS_TIME,
      endTime.Year, 
      endTime.Month, 
      endTime.Day, 
      endTime.Hour, 
      endTime.Minute
    );

  self:RefreshPlayerData();
end

function CheckinAccessViewModel:RefreshPlayerData()
  self.showTrackPoint = luaUtils.CheckTrack(CS.Torappu.LocalTrackTypes.ACT_TIME_TRACK, self.actId);
  local playerMap = CS.Torappu.PlayerData.instance.data.activity.checkinAccessList;
  if playerMap == nil then
    luaUtils.LogError("[ActAccess] Cannot load player data of [" .. self.actId .. "].");
    return;
  end
  local suc, jObject = playerMap:TryGetValue(self.actId);
  if not suc then
    luaUtils.LogError("[ActAccess] Cannot load player data of [" .. self.actId .. "].");
    return;
  end
  local playerData = luaUtils.ConvertJObjectToLuaTable(jObject);
  if playerData == nil then
    return;
  end
  local canReach = playerData.currentStatus == 1;
  local isAllConfirmed = playerData.rewardsCount >= self.m_totalCheckinDays;
  if canReach then
    self.status = CheckinAccessStatus.CAN_CONFIRM;
  elseif not canReach and not isAllConfirmed then
    self.status = CheckinAccessStatus.CONFIRMED;
  else
    self.status = CheckinAccessStatus.ALL_CONFIRMED;
  end
  self.confirmedTimesTip = luaUtils.Format(StringRes.ACT_ACCESS_CURR_TIMES_FORMAT, tostring(playerData.rewardsCount));
end

return CheckinAccessViewModel;