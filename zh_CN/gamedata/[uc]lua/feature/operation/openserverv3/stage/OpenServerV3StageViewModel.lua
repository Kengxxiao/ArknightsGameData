local luaUtil = CS.Torappu.Lua.Util;
local dateUtil = CS.Torappu.DateTimeUtil;

















local OpenServerV3StageViewModel = Class("OpenServerV3StageViewModel");

function OpenServerV3StageViewModel:LoadData()
  self.storyCurrentReward, self.storyTotalReward = OpenServerV3Model.me:GetStageStoryAwardStatus();
  self.storyRewardItemModel = self:_CreateItemModel(CS.Torappu.ItemType.DIAMOND);
  self.campaignRewardItemModel = self:_CreateItemModel(CS.Torappu.ItemType.DIAMOND_SHD);
  self.campaignLockedTip = CS.Torappu.UI.UIGuideController.GetLockedToastContent(
      CS.Torappu.UI.UILockTarget.CAMPAIGN_ENTRY);
  self.resourceLockedTip = CS.Torappu.UI.UIGuideController.GetLockedToastContent(
      CS.Torappu.UI.UILockTarget.WEEKLY_MATERIAL);
  self.permModeLockedTip = CS.Torappu.UI.UIGuideController.GetLockedToastContent(
      CS.Torappu.UI.UILockTarget.PERM_MODE);
  self:RefreshPlayerData();
end

function OpenServerV3StageViewModel:RefreshPlayerData()
  local guideController = CS.Torappu.UI.UIGuideController;
  local lockTarget = CS.Torappu.UI.UILockTarget;
  self.isCampaignUnlock = guideController.CheckIfUnlocked(lockTarget.CAMPAIGN_ENTRY);
  self.isResourceUnlock = guideController.CheckIfUnlocked(lockTarget.WEEKLY_MATERIAL) or
      guideController.CheckIfUnlocked(lockTarget.WEEKLY_EVOLVE);
  self.isPermModeUnlock = guideController.CheckIfUnlocked(lockTarget.PERM_MODE);
  self:_RefreshCampaignData();
  self:_RefreshResourceFullOpenData();
end


function OpenServerV3StageViewModel:_RefreshCampaignData()
  local playerData = CS.Torappu.PlayerData.instance.data;
  local playerCampaign = playerData ~= nil and playerData.campaign or nil;
  if not self.isCampaignUnlock or playerCampaign == nil then
    self.campaignCurrentFee = 0;
    self.campaignTotalFee = 0;
    return;
  end
  self.campaignCurrentFee = playerCampaign.campaignCurrentFee;
  self.campaignTotalFee = playerCampaign.campaignTotalFee;
end


function OpenServerV3StageViewModel:_RefreshResourceFullOpenData()
  self.showResourceFullOpen = false;
  self.isResourceFullOpenPaused = false;
  self.resourceRemainTimeDesc = "";
  if not self.isResourceUnlock then
    return;
  end
  local playerData = OpenServerV3Model.me:GetPlayerData();
  local fullOpen = playerData ~= nil and playerData.fullOpen or nil;
  if fullOpen == nil then
    return;
  end
  local remain = fullOpen.remain or 0;
  if remain > 0 then
    if fullOpen.today then
      self.showResourceFullOpen = true;
    else
      self.isResourceFullOpenPaused = true;
    end
  end
  self.resourceRemainTimeDesc = self:_GetResourceRemainTimeDesc(remain, self.isResourceFullOpenPaused);
end





function OpenServerV3StageViewModel:_GetResourceRemainTimeDesc(remainDay, isPaused)
  local timeStr = "";
  if isPaused then
    timeStr = luaUtil.Format(StringRes.DAY_TEXT, remainDay);
  else
    local remainWholeDay = remainDay - 1;
    if remainWholeDay > 0 then
      timeStr = luaUtil.Format(StringRes.DAY_TEXT, remainWholeDay);
    else
      local currentTime = dateUtil.currentTime;
      local nextCrossDayTime = dateUtil.GetNextCrossDayTime(currentTime);
      timeStr = luaUtil.FormatTimeDelta(nextCrossDayTime - currentTime);
    end
  end
  return luaUtil.Format(StringRes.COMMON_LEFT_TIME, timeStr);
end




function OpenServerV3StageViewModel:_CreateItemModel(itemType)
  local itemModel = CS.Torappu.UI.UIItemViewModel();
  itemModel:LoadGameData("", itemType);
  return itemModel;
end

return OpenServerV3StageViewModel;