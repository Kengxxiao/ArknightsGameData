local luaUtils = CS.Torappu.Lua.Util;


















local MainlineBpMissionItemModel = Class("MainlineBpMissionItemModel");

function MainlineBpMissionItemModel:ctor()
  self.itemType = MainlineBpMissionItemType.MISSION;
  self.bannerId = "";
  self.zoneId = "";
  self.missionId = "";
  self.missionDesc = "";
  self.missionState = MainlineBpMissionState.UNCOMPLETE;
  self.rewardList = {};
  self.progressCurr = 0;
  self.progressTarget = 1;
  self.progressPercent = 0;
  self.groupSortId = -1;
  self.innerSortId = -1;
  self.groupId = "";
end



function MainlineBpMissionItemModel:LoadMissionGroupData(groupData, endDesc)
  if groupData == nil then
    return;
  end
  self.itemType = MainlineBpMissionItemType.MISSION_GROUP;
  self.bannerId = groupData.bindBanner;
  self.zoneId = groupData.zoneId;
  self.groupId = groupData.groupId;
  self.apEndDesc = endDesc;
end



function MainlineBpMissionItemModel:LoadMissionData(missionData, groupId)
  if missionData == nil then
    return;
  end
  self.itemType = MainlineBpMissionItemType.MISSION;
  self.missionId = missionData.id;
  self.missionDesc = missionData.description;
  self.groupId = groupId;
  self.missionState = MainlineBpMissionState.UNCOMPLETE;
  self.rewardList = missionData.rewards;
  self.progressCurr = 0;
  self.progressTarget = 1;
  self.progressPercent = 0;
end


function MainlineBpMissionItemModel:LoadBannerData(bannerId)
  self.itemType = MainlineBpMissionItemType.BANNER;
  self.bannerId = bannerId;
end

















local MainlineBpLimitBpItemModel = Class("MainlineBpLimitBpItemModel");

function MainlineBpLimitBpItemModel:ctor()
  self.groupSortId = -1;
  self.unlockStageId = "";
  self.unlockStageTips = "";
  self.isStagePass = false;
  self.inCanClaimPeriod = false;
  self.bpId = "";
  self.innerSortId = -1;
  self.itemType = MainlineBpLimitBpItemType.REWARD;
  self.itemState = MainlineBpLimitBpItemState.NOT_IN_CLAIM_AND_NOT_PASS;
  self.itemTipsState = MainlineBpLimitBpItemTipsState.NOT_IN_CLAIM_AND_LACK_COUNT;
  self.itemProgressLineState = MainlineBpLimitBpItemProgressLineState.NOT_ENOUGH;
  self.reward = nil;
  self.tokenNum = 0;
  self.nextTokenNum = 0;
  self.bpNoticeDesc = "";
end


function MainlineBpLimitBpItemModel:LoadLimitBpRewardItemData(limitBpData)
  if limitBpData == nil then 
    return;
  end
  self.bpId = limitBpData.id;
  self.innerSortId = limitBpData.level;
  self.itemType = MainlineBpLimitBpItemType.REWARD;

  local reward = limitBpData.reward;
  local viewModel = CS.Torappu.UI.UIItemViewModel();
  viewModel:LoadGameData(reward.id, reward.type);
  viewModel.itemCount = reward.count;
  self.reward = viewModel;

  self.tokenNum = limitBpData.tokenNum;
end





function MainlineBpLimitBpItemModel:RefreshBpItemData(totalLimitPoints,rewardState,nextIsPointEnough,nextTokenNum)
  local isStagePass = false;
  local stageId = self.unlockStageId;
  if stageId == nil or stageId == "" then
    isStagePass = true;
  else
    isStagePass = self:_CheckStagePassed(stageId);
  end
  self.isStagePass = isStagePass;
  self.nextTokenNum = nextTokenNum;
  self:_RefreshItemState(totalLimitPoints,rewardState);
  self:_RefreshItemTipsState(totalLimitPoints,rewardState);
  self:_RefreshItemProgressState(totalLimitPoints,nextIsPointEnough);
end




function MainlineBpLimitBpItemModel:_CheckStagePassed(stageId)
  local success, stageData = CS.Torappu.PlayerData.instance.data.dungeon.stages:TryGetValue(stageId)
  if success and stageData ~= nil then
    return stageData.state.value__ >= 2;
  end
  return false;
end




function MainlineBpLimitBpItemModel:_RefreshItemState(totalLimitPoints,rewardState)
  local isPointsEnough = totalLimitPoints >= self.tokenNum;
  local result = MainlineBpLimitBpItemState.NOT_IN_CLAIM_AND_NOT_PASS;
  if rewardState == MainlineBpLimitBpItemRewardState.LOCK then
    if self.isStagePass == false then
      result = MainlineBpLimitBpItemState.NOT_IN_CLAIM_AND_NOT_PASS;
    elseif self.isStagePass == true and isPointsEnough then
      result = MainlineBpLimitBpItemState.NOT_IN_CLAIM_AND_ENOUGH_COUNT;
    else
      result = MainlineBpLimitBpItemState.NOT_IN_CLAIM_AND_LACK_COUNT;
    end
  else
    if rewardState == MainlineBpLimitBpItemRewardState.OPEN then
      result = MainlineBpLimitBpItemState.IN_CLAIM_AND_CAN_CLAIM;
    elseif rewardState == MainlineBpLimitBpItemRewardState.CONFIRMED then
      result = MainlineBpLimitBpItemState.IN_CLAIM_AND_CLAIMED;
    elseif rewardState == MainlineBpLimitBpItemRewardState.UNLOCK and self.isStagePass == false then
      result = MainlineBpLimitBpItemState.IN_CLAIM_AND_NOT_PASS;
    elseif rewardState == MainlineBpLimitBpItemRewardState.UNLOCK and self.isStagePass == true and isPointsEnough == false then
      result = MainlineBpLimitBpItemState.IN_CLAIM_AND_LACK_COUNT_PASS;
    end
  end
  self.itemState = result;
end




function MainlineBpLimitBpItemModel:_RefreshItemTipsState(totalLimitPoints, rewardState)
  local isPointsEnough = totalLimitPoints >= self.tokenNum;
  local result = MainlineBpLimitBpItemTipsState.NOT_IN_CLAIM_AND_LACK_COUNT;
  if rewardState == MainlineBpLimitBpItemRewardState.LOCK then
    if isPointsEnough == true then
      result = MainlineBpLimitBpItemTipsState.NOT_IN_CLAIM_AND_ENOUGH_COUNT;
    else
      result = MainlineBpLimitBpItemTipsState.NOT_IN_CLAIM_AND_LACK_COUNT;
    end
  else
    if isPointsEnough == false then
      result = MainlineBpLimitBpItemTipsState.IN_CLAIM_AND_LACK_COUNT;
    elseif isPointsEnough == true and rewardState == MainlineBpLimitBpItemRewardState.CONFIRMED then
      result = MainlineBpLimitBpItemTipsState.IN_CLAIM_AND_CLAIMED;
    elseif isPointsEnough == true and rewardState == MainlineBpLimitBpItemRewardState.OPEN then
      result = MainlineBpLimitBpItemTipsState.IN_CLAIM_AND_CAN_CLAIM;
    elseif isPointsEnough == true and rewardState == MainlineBpLimitBpItemRewardState.UNLOCK and self.isStagePass == false then
      result = MainlineBpLimitBpItemTipsState.IN_CLAIM_AND_ENOUGH_COUNT_NOT_PASS;
    end
  end
  self.itemTipsState = result;
end




function MainlineBpLimitBpItemModel:_RefreshItemProgressState(totalLimitPoints, nextIsPointEnough)
  local isPointsEnough = totalLimitPoints >= self.tokenNum;
  local result = MainlineBpLimitBpItemProgressLineState.NOT_ENOUGH;
  if isPointsEnough == false then
    result = MainlineBpLimitBpItemProgressLineState.NOT_ENOUGH;
  elseif isPointsEnough == true and nextIsPointEnough then
    result = MainlineBpLimitBpItemProgressLineState.CUR_AND_NEXT_ENOUGH;
  else
    result = MainlineBpLimitBpItemProgressLineState.CUR_ENOUGH_BUT_NEXT_NOT;
  end
  self.itemProgressLineState = result;
end


function MainlineBpLimitBpItemModel:LoadLimitBpFurtureItemData(bpNoticeDesc)
  self.itemType = MainlineBpLimitBpItemType.FURTURE_TIPS;
  self.bpNoticeDesc = bpNoticeDesc;
  self.tokenNum = 0;
  self.nextTokenNum = 0;
end


function MainlineBpLimitBpItemModel:IsItemCanClaim()
  if self.itemType ~= MainlineBpLimitBpItemType.REWARD or self.inCanClaimPeriod ~= true then
    return false;
  end
  return self.itemState == MainlineBpLimitBpItemState.IN_CLAIM_AND_CAN_CLAIM;
end


function MainlineBpLimitBpItemModel:IsItemClaimed()
  return self.itemType == MainlineBpLimitBpItemType.REWARD and self.itemState == MainlineBpLimitBpItemState.IN_CLAIM_AND_CLAIMED;
end





local MainlineBpLimitBpBigRewardModel = Class("MainlineBpLimitBpBigRewardModel");

function MainlineBpLimitBpBigRewardModel:ctor()
  self.bpId = "";
  self.accordingThemeId = "";
end





local MainlineBpBpUpDetailItemModel = Class("MainlineBpBpUpDetailItemModel");

function MainlineBpBpUpDetailItemModel:ctor()
  self.sortId = -1;
  self.stageCode = "";
  self.upPercentDesc = 0;
end





























































local MainlineBpViewModel = Class("MainlineBpViewModel", UIViewModel);
MainlineBpViewModel.MAX_MILESTONE_BUFF = 100;


function MainlineBpViewModel:LoadData(actId)
  self.actId = actId;
  self.missionGroupModelList = {};
  self.limitBpItemModelList = {};
  self.limitBpBigRewardModelList = {};
  self.showBpUpDetailPanel = false;
  self.showBpUnlimitDetailPanel = false;
  
  self.m_cachedGameData = MainlineBpUtil.LoadGameData(actId);
  if self.m_cachedGameData == nil then
    return;
  end
  
  self.currPeriodId = MainlineBpUtil.GetCurrentPeriodId(self.m_cachedGameData);
  if self.currPeriodId == nil or self.currPeriodId == "" then
    return;
  end

  self:_LoadMissionData();
  self:_LoadBpData();
  self:_LoadMainTabData();
  self:_LoadBpUpData();

  self:_RefreshPlayerData();
  self:SetMissionAutoFocus();
  self:_SetTabFocus();
end

function MainlineBpViewModel:RefreshPlayerData()
  local currPeriodId = MainlineBpUtil.GetCurrentPeriodId(self.m_cachedGameData);
  local isSamePeriod = currPeriodId ~= nil and 
      currPeriodId ~= nil and 
      self.currPeriodId ~= nil and 
      self.currPeriodId ~= "" and 
      self.currPeriodId == currPeriodId;
  if isSamePeriod then
    self:_RefreshPlayerData();
  else
    self:LoadData(self.actId);
  end
end


function MainlineBpViewModel:_SetTabFocus()
  self.tabState = MainlineBpTabState.MISSION;
  self.showBpUnlimitDetailPanel = false;
  self.showBpUpDetailPanel = false;
  local periodId = self.currPeriodId;
  local gameData = self.m_cachedGameData;
  local periodData = MainlineBpUtil.GetPeriodData(gameData.periodDataList, periodId);
  if gameData == nil or periodData == nil then
    return;
  end
  local isBpPeriod = periodData.canGetUnlimitBp;
  if not isBpPeriod and not self.isAllMissionComplete then
    self.tabState = MainlineBpTabState.MISSION;
    return;
  else
    self.tabState = MainlineBpTabState.BP;
  end
end


function MainlineBpViewModel:_RefreshPlayerData()
  local playerData = MainlineBpUtil.LoadPlayerData(self.actId);
  if playerData == nil then
    return;
  end
  self:_RefreshMissionData(playerData);
  self:_RefreshBpData(playerData);
  self:_RefreshMainTabData(playerData);
end


function MainlineBpViewModel:_LoadMissionData()
  local missionList = CS.Torappu.ActivityDB.data.missionData;
  local data = self.m_cachedGameData;
  local currPeriod = self.currPeriodId;
  local actId = self.actId;
  if data == nil or currPeriod == nil then
    return;
  end
  
  local apEndDesc = "";
  for itemId, endTs in pairs(data.apSupplyOutOfDateDict) do
    local endTime = luaUtils.ToDateTime(endTs);
    apEndDesc = CS.Torappu.FormatUtil.FormatDateTimeyyyyMMddHHmm(endTime);
    break;
  end

  local groupDataList = {};
  for groupId, groupData in pairs(data.missionGroupMap) do
    local needShow = MainlineBpUtil.CheckIfContainPeriod(groupData.showPeriodList, currPeriod);
    if needShow then
      table.insert(groupDataList, groupData);
    end
  end
  table.sort(groupDataList, function(a, b)
    if a.sortId ~= b.sortId then
      return a.sortId < b.sortId
    end
    return a.groupId < b.groupId;
  end);

  local groupSortId = 0;
  for i = 1, #groupDataList do
    groupSortId = i;
    local innerSortId = 1;
    local groupData = groupDataList[i];
    local groupModel = MainlineBpMissionItemModel.new();
    groupModel:LoadMissionGroupData(groupData, apEndDesc);
    groupModel.groupSortId = groupSortId;
    groupModel.innerSortId = innerSortId;
    innerSortId = innerSortId + 1;
    table.insert(self.missionGroupModelList, groupModel);

    for index, missionId in pairs(groupData.missionIdList) do
      local missionData = MainlineBpUtil.GetMissionData(missionList, missionId, actId);
      if missionData ~= nil then
        local missionModel = MainlineBpMissionItemModel.new();
        missionModel:LoadMissionData(missionData, groupData.groupId);
        missionModel.groupSortId = groupSortId;
        missionModel.innerSortId = innerSortId;
        innerSortId = innerSortId + 1;
        table.insert(self.missionGroupModelList, missionModel);
      end
    end
  end

  groupSortId = groupSortId + 1;
  local periodData = MainlineBpUtil.GetPeriodData(data.periodDataList, currPeriod);
  if periodData ~= nil and periodData.bannerImgId ~= nil and periodData.bannerImgId ~= "" then
    local bannerModel = MainlineBpMissionItemModel.new();
    bannerModel:LoadBannerData(periodData.bannerImgId);
    bannerModel.groupSortId = groupSortId;
    table.insert(self.missionGroupModelList, bannerModel);
  end
end



function MainlineBpViewModel:_RefreshMissionData(playerData)
  self.canConfirmMission = false;
  self.isAllMissionComplete = true;

  self.m_zoneGroupDict = CS.Torappu.StageDataUtil.LoadZonesView(self.m_zoneDict);
  self.mainlineViewModel = nil;
  local suc, mainlineModel = self.m_zoneGroupDict:TryGetValue(CS.Torappu.UI.Stage.ZoneViewType.MAINLINE);
  if suc then
    self.mainlineViewModel = mainlineModel;
  end

  local missionGroupModelList = self.missionGroupModelList;
  if missionGroupModelList == nil then
    return;
  end
  local playerData = CS.Torappu.PlayerData.instance.data.mission.missions.Activity;
  for i = 1, #missionGroupModelList do
    local model = missionGroupModelList[i];
    if model.itemType == MainlineBpMissionItemType.MISSION then
      local suc, missionData = playerData:TryGetValue(model.missionId);
      if suc and missionData.progress.Count > 0 then
        local progress = missionData.progress[0];
        if progress ~= nil then
          model.progressCurr = progress.value;
          model.progressTarget = progress.target;
          if model.progressTarget <= 0 then
            model.progressPercent = 0
          else
            model.progressPercent = model.progressCurr / model.progressTarget;
          end
          if missionData.state == CS.Torappu.MissionHoldingState.FINISHED then
            model.missionState = MainlineBpMissionState.CONFIRMED;
          elseif model.progressCurr >= model.progressTarget then
            model.missionState = MainlineBpMissionState.COMPLETE;
            self.isAllMissionComplete = false;
            self.canConfirmMission = true;
          else
            self.isAllMissionComplete = false;
            model.missionState = MainlineBpMissionState.UNCOMPLETE;
          end
        end
      end
    end
  end

  table.sort(missionGroupModelList, MainlineBpUtil.CompareMissionItemModel);
end

function MainlineBpViewModel:SetMissionAutoFocus()
  local missionGroupModelList = self.missionGroupModelList;
  if missionGroupModelList == nil then
    return;
  end
  
  local missionUnconfirmGroup = {};
  for i = 1, #missionGroupModelList do
    local model = missionGroupModelList[i];
    if model.itemType == MainlineBpMissionItemType.MISSION and
        (model.missionState == MainlineBpMissionState.COMPLETE or
        model.missionState == MainlineBpMissionState.UNCOMPLETE) then
      table.insert(missionUnconfirmGroup, model.groupId);
    end
  end

  
  for i = 1, #missionGroupModelList do
    local model = missionGroupModelList[i];
    if model.itemType == MainlineBpMissionItemType.MISSION_GROUP then
      local pos = FindIndex(missionUnconfirmGroup, model.groupId);
      if pos ~= -1 then
        self.missionListFocusPosition = i - 1;
        self.missionFocusCache = self.missionFocusCache + 1;
        break;
      end
    elseif model.itemType == MainlineBpMissionItemType.BANNER then
      self.missionListFocusPosition = i - 1;
      self.missionFocusCache = self.missionFocusCache + 1;
      break;
    end
  end
end


function MainlineBpViewModel:_LoadBpData()
  local data = self.m_cachedGameData;
  local periodId = self.currPeriodId;
  if data == nil or periodId == nil then
    return;
  end
  local periodData = MainlineBpUtil.GetPeriodData(data.periodDataList, periodId);
  local constData = data.constData;
  if periodData == nil or constData == nil then
    return;
  end

  self.canGetUnlimitBpReward = periodData.canGetUnlimitBp;
  self.showBpPreviewBtn = periodData.canCheckBpRewardDetail;
  self.bpBannerId = periodData.bpBannerImgId;


  local unlimitBpRewardTimeTips = "";
  local unlimitBpRewardDataList = data.unlimitBpRewardDataList;
  local unlimitBpRewardDataCount = #unlimitBpRewardDataList;
  if unlimitBpRewardDataCount >= 2 then
    local reward1 = unlimitBpRewardDataList[1].reward;
    local reward2 = unlimitBpRewardDataList[2].reward;
    local viewModel1 = CS.Torappu.UI.UIItemViewModel();
    viewModel1:LoadGameData(reward1.id, reward1.type);
    viewModel1.itemCount = reward1.count;
    local viewModel2 = CS.Torappu.UI.UIItemViewModel();
    viewModel2:LoadGameData(reward2.id, reward2.type);
    viewModel2.itemCount = reward2.count;
    self.unlimitBpRewardData1 = viewModel1;
    self.unlimitBpRewardData2 = viewModel2;
    local itemId1 = reward1.id;
    local itemId2 = reward2.id;
    self.unlimitBpRewardName1 = CS.Torappu.UI.ItemUtil.GetItemName(itemId1);
    self.unlimitBpRewardName2 = CS.Torappu.UI.ItemUtil.GetItemName(itemId2);
    if self.canGetUnlimitBpReward == true then
      if data.apSupplyOutOfDateDict ~= nil then
        local passTime = data.apSupplyOutOfDateDict[itemId1];
        local timeStr = "";
        if passTime ~= nil then
          local passDataTime = luaUtils.ToDateTime(passTime);
          timeStr = CS.Torappu.FormatUtil.FormatDateTimeyyyyMMddHHmm(passDataTime);
        end
        unlimitBpRewardTimeTips = luaUtils.Format(
          StringRes.MAINLINE_BP_UNLIMIT_BP_DETAIL_TIME_TIPS, 
          self.unlimitBpRewardName1, timeStr);
      end
    else
      unlimitBpRewardTimeTips = constData.unlimitedBpDesc2;
    end
  else
    self.unlimitBpRewardData1 = nil;
    self.unlimitBpRewardData2 = nil;
    self.unlimitBpRewardName1 = "";
    self.unlimitBpRewardName2 = "";
  end
  self.unlimitBpRewardTips1 = constData.unlimitedBpDesc1;
  self.unlimitBpRewardTips2 = unlimitBpRewardTimeTips;

  local groupLimitBpDataList = {};
  for groupId, groupBpLimitData in pairs(data.mileStoneGroupMap) do
    local needShow = MainlineBpUtil.CheckIfContainPeriod(groupBpLimitData.showPeriodList, periodId);
    if needShow then
      table.insert(groupLimitBpDataList, groupBpLimitData);
    end
  end

  for i = 1, #groupLimitBpDataList do
    local groupLimitBpData = groupLimitBpDataList[i];
    local groupSortId = groupLimitBpData.sortId;
    local unlockGroupStageId = groupLimitBpData.stageId;
    local unlockStageTips = "";
    if unlockGroupStageId ~= nil and unlockGroupStageId ~= "" then
      local stageData = CS.Torappu.StageDataUtil.GetStageIgnoreTime(unlockGroupStageId);
      if stageData == nil then
        luaUtils.LogError("[MainlineBp][_LoadBpData] Cannot find stage data of [" .. item.stageId .. "].");
        break;
      end
      unlockStageTips = luaUtils.Format(StringRes.MAINLINE_BP_LIMIT_BP_STAGE_LOCK_TIPS, stageData.code);
    end

    local limitBpDataList = groupLimitBpData.bpDataList;
    local inCanClaimPeriod = MainlineBpUtil.CheckIfContainPeriod(groupLimitBpData.getPeriodList, periodId);
    if limitBpDataList ~= nil then
      for j = 1, #limitBpDataList do
        local limitBpData = limitBpDataList[j];
        local limitBpItemId = limitBpData.id;
        local limitBpItemViewModel = MainlineBpLimitBpItemModel.new();
        limitBpItemViewModel:LoadLimitBpRewardItemData(limitBpData);
        limitBpItemViewModel.groupSortId = groupSortId;
        limitBpItemViewModel.unlockStageId = unlockGroupStageId; 
        limitBpItemViewModel.unlockStageTips = unlockStageTips;
        limitBpItemViewModel.inCanClaimPeriod = inCanClaimPeriod;
        table.insert(self.limitBpItemModelList, limitBpItemViewModel);
        if limitBpData.isGrandPrize == true then
          local bpBigRewardModel = MainlineBpLimitBpBigRewardModel.new();
          bpBigRewardModel.bpId = limitBpItemId;
          bpBigRewardModel.accordingThemeId = limitBpData.accordingUiId;
          table.insert(self.limitBpBigRewardModelList, bpBigRewardModel);
        end
      end
    end
  end
  
  local bpFurtureTips = periodData.bpNoticeDesc;
  self.showFurtureTips = bpFurtureTips ~= nil and bpFurtureTips ~= "";
  if self.showFurtureTips then
    local limitBpFurtureItemViewModel = MainlineBpLimitBpItemModel.new();
    limitBpFurtureItemViewModel:LoadLimitBpFurtureItemData(bpFurtureTips);
    table.insert(self.limitBpItemModelList, limitBpFurtureItemViewModel);
  end

  table.sort(self.limitBpItemModelList, MainlineBpUtil.CompareLimitBpItemModel);
end





function MainlineBpViewModel:_RefreshBpData(playerActData)
  if playerActData == nil then
    return;
  end

  self.limitBpPoints = playerActData.milestonePoints;
  self.limitBpRewardStateDict = playerActData.rewardState;
  
  self.m_unlimitBpUnconfirmPoints = playerActData.unconfirmedInfPoints;
  self.m_unlimitBpNextRewardIndex = playerActData.nextRewardIndex;

  self:_RefreshBpUnlimitRewardInfo();
  self.unlimitBpRewardState = self:_RefreshBpUnlimitRewardState();

  local playerHasRewardState = self.limitBpRewardStateDict ~= nil;
  for i = 1, #self.limitBpItemModelList do
    local limitItemModel = self.limitBpItemModelList[i];
    local nextItemIndex = i + 1;
    local nextRewardItemModel = self:_GetLimitItemRewardModelByIndex(nextItemIndex);
    local isCurRewardItem = self:_IsBpLimitItemModelIsValidReward(limitItemModel);
    local isNextItemPointEnough = true;
    local nextRewardTokenNum = 0;
    if nextRewardItemModel ~= nil then
      isNextItemPointEnough = self:_IsBpLimitRewardItemModelPointEnough(nextRewardItemModel,self.limitBpPoints);
      nextRewardTokenNum = nextRewardItemModel.tokenNum;
    end
    if isCurRewardItem == true and playerHasRewardState == true then
      local limitBpRewardState = self.limitBpRewardStateDict[limitItemModel.bpId];
      limitItemModel:RefreshBpItemData(self.limitBpPoints,limitBpRewardState,isNextItemPointEnough,nextRewardTokenNum);
    end
  end

  self.showBpClaimedBigRewardTips = self:_IsAllBigBpRewardClaimed();
  self.showBpAllCanClaimBtn = self:_HasBpRewardCanClaim();
  self.isBpUnlimitHasRewardCanClaim = self:_HasBpUnlimitRewardCanClaim();
end



function MainlineBpViewModel:_GetLimitItemRewardModelByIndex(index)
  if index <= 0 or index > #self.limitBpItemModelList then
    return nil;
  end
  local result = self.limitBpItemModelList[index];
  if result ~= nil and result.itemType ~= MainlineBpLimitBpItemType.REWARD then
    return nil;
  end
  return result;
end



function MainlineBpViewModel:_IsBpLimitItemModelIsValidReward(limitItemModel)
  return limitItemModel ~= nil and limitItemModel.itemType == MainlineBpLimitBpItemType.REWARD and limitItemModel.bpId ~= nil and limitItemModel.bpId ~= ""
end

function MainlineBpViewModel:_IsBpLimitRewardItemModelPointEnough(limitItemModel,totalPoints)
  if limitItemModel == nil or limitItemModel.bpId == nil or limitItemModel.bpId == "" then
    return false;
  end
  return limitItemModel.tokenNum <= totalPoints;
end


function MainlineBpViewModel:_RefreshBpUnlimitRewardInfo()
  self.unlimitBpRewardRoundCount = 0;
  self.showUnlimitBpRewardRound = false;
  self.unlimitBpCurRoundPoints = 0;
  self.unlimitBpCurRoundNeedPoints = 0;
  self.unlimitBpCurRoundProgress = 0;
  self.unlimitBpRewardItemFirst = nil;

  local data = self.m_cachedGameData;
  if data == nil then
    return;
  end
  local unconfirmPoints = self.m_unlimitBpUnconfirmPoints;
  local startIndex = self.m_unlimitBpNextRewardIndex + 1;
  local unlimitRewardData,roundCount,leftPoints = self:_GetUnlimitBpRewardData(data.unlimitBpDataList, startIndex, unconfirmPoints);
  if unlimitRewardData == nil then
    return;
  end
  self.unlimitBpRewardRoundCount = roundCount;
  self.showUnlimitBpRewardRound = roundCount > 0;
  self.unlimitBpCurRoundPoints = leftPoints;
  self.unlimitBpCurRoundNeedPoints = unlimitRewardData.tokenNum;
  if self.unlimitBpCurRoundNeedPoints > 0 then
    self.unlimitBpCurRoundProgress = self.unlimitBpCurRoundPoints / self.unlimitBpCurRoundNeedPoints;
  end
  if unlimitRewardData.reward ~= nil and #unlimitRewardData.reward > 0 then
    local unlimitShowReward = unlimitRewardData.reward[1];
    local viewModel = CS.Torappu.UI.UIItemViewModel();
    viewModel:LoadGameData(unlimitShowReward.id, unlimitShowReward.type);
    viewModel.itemCount = unlimitShowReward.count;
    self.unlimitBpRewardItemFirst = viewModel;
  end
end



function MainlineBpViewModel:_RefreshBpUnlimitRewardState()
  local canGetUnlimitBpReward = self.canGetUnlimitBpReward;
  if canGetUnlimitBpReward == false or self.unlimitBpRewardItemFirst == nil then
    return MainlineBpUnlimitBpState.NOT_IN_CLAIM;
  end

  if self.showUnlimitBpRewardRound then
    return MainlineBpUnlimitBpState.IN_CLAIM_AND_CAN_CLAIM;
  end

  return MainlineBpUnlimitBpState.IN_CLAIM_AND_CANT_CLAIM;
end








function MainlineBpViewModel:_GetUnlimitBpRewardData(unlimitBpDataList, startIndex, totalPoints)
  local listCount = #unlimitBpDataList;
  local oneRoundTotalTokenCount = self:_GetUnlimitBpLeftTotalTokenCount(unlimitBpDataList, 1);
  local oneRoundLeftTotalTokenCount = self:_GetUnlimitBpLeftTotalTokenCount(unlimitBpDataList, startIndex);
  local leftTokenNum = totalPoints - oneRoundLeftTotalTokenCount;
  local firstRoundLeftTokenNum = leftTokenNum;
  local needClaimCount = 0;
  
  local resultShowIndex = 1;
  local resultShowData = nil;
  local resultNeedClaimCount = 0;
  local resultCurRoundLeftTokenNum = 0;

  
  resultShowData,resultNeedClaimCount,resultCurRoundLeftTokenNum = self:_GetUnlimitInRoundShowInfo(unlimitBpDataList, startIndex, totalPoints, needClaimCount);
  
  if firstRoundLeftTokenNum > 0 then
    local leftRoundCount = math.floor(leftTokenNum / oneRoundTotalTokenCount);
    if leftRoundCount > 0 then
      
      resultNeedClaimCount = resultNeedClaimCount + listCount * leftRoundCount;
    end
    
    local lastRoundLeftPoints = leftTokenNum % oneRoundTotalTokenCount;
    resultShowData,resultNeedClaimCount,resultCurRoundLeftTokenNum = self:_GetUnlimitInRoundShowInfo(unlimitBpDataList, 1, lastRoundLeftPoints, resultNeedClaimCount);
  end
  return resultShowData,resultNeedClaimCount,resultCurRoundLeftTokenNum;
end









function MainlineBpViewModel:_GetUnlimitInRoundShowInfo(unlimitBpDataList, startIndex, leftPoints, needClaimCount)
  local left = leftPoints;
  local resultData = nil;
  local resultNeedClaimCount = needClaimCount;
  local resultCurRoundLeftTokenNum = 0;
  if unlimitBpDataList == nil or startIndex < 1 then
    return resultData,resultNeedClaimCount,resultCurRoundLeftTokenNum;
  end
  local listCount = #unlimitBpDataList;
  for i = startIndex, listCount do
    local data = unlimitBpDataList[i];
    local tempLeft = left;
    left = left - data.tokenNum;
    if left >= 0 then
      resultNeedClaimCount = resultNeedClaimCount + 1;
      resultCurRoundLeftTokenNum = left;
    else
      resultCurRoundLeftTokenNum = tempLeft;
    end

    if left == 0 then
      local nextIndex = i % listCount + 1;
      local nextData = unlimitBpDataList[nextIndex];
      resultData = nextData;
      break;
    end

    if left < 0 then
      resultData = data;
      break;
    end
  end
  return resultData,resultNeedClaimCount,resultCurRoundLeftTokenNum;
end




function MainlineBpViewModel:_GetUnlimitBpLeftTotalTokenCount(unlimitBpDataList, startIndex)
  if unlimitBpDataList == nil or startIndex < 1 then
    return 0;
  end
  local result = 0;
  for i = startIndex, #unlimitBpDataList do
    local data = unlimitBpDataList[i];
    if data ~= nil then
      result = result + data.tokenNum;
    end
  end
  return result;
end


function MainlineBpViewModel:GetLimitBpBigRewardAccordingUiId()
  local limitBpBigRewardModelList = self.limitBpBigRewardModelList;
  if #limitBpBigRewardModelList <= 0 then
    return "";
  end
  
  local model = limitBpBigRewardModelList[1];
  if model == nil then
    return "";
  end
  return model.accordingThemeId;
end



function MainlineBpViewModel:_IsAllBigBpRewardClaimed()
  local limitBpBigRewardModelList = self.limitBpBigRewardModelList;
  local limitBpItemList = self.limitBpItemModelList;
  if limitBpBigRewardModelList == nil or limitBpItemList == nil then
    return false;
  end

  local needClaimCount = #limitBpBigRewardModelList;
  if needClaimCount <= 0 then
    return false;
  end

  local claimedCount = 0;
  for j = 1, needClaimCount do
    local model = limitBpBigRewardModelList[j];
    for i = 1, #limitBpItemList do
      local limitBpItemModel = limitBpItemList[i];
      if limitBpItemModel ~= nil and limitBpItemModel.bpId == model.bpId then
        if limitBpItemModel:IsItemClaimed() then
          claimedCount = claimedCount + 1;
        end
        break;    
      end
    end
  end
  return claimedCount >= needClaimCount;
end



function MainlineBpViewModel:_HasBpRewardCanClaim()
  local hasUnlimitCanClaim = self:_HasBpUnlimitRewardCanClaim();
  if hasUnlimitCanClaim == true then
    return true;
  end

  local limitBpItemList = self.limitBpItemModelList;
  if limitBpItemList == nil then
    return false;
  end
  for i = 1, #limitBpItemList do
    local limitBpItemModel = limitBpItemList[i];
    local canClaim = limitBpItemModel:IsItemCanClaim();
    if canClaim == true then
      return true;
    end
  end
  return false;
end



function MainlineBpViewModel:_HasBpUnlimitRewardCanClaim()
  if self.unlimitBpRewardState == MainlineBpUnlimitBpState.IN_CLAIM_AND_CAN_CLAIM then 
    return true;
  end
  return false;
end


function MainlineBpViewModel:TryGetCurLimitBpIndex()
  local points = self.limitBpPoints;
  local limitBpItemList = self.limitBpItemModelList;
  if limitBpItemList == nil then
    return -1;
  end
  local limitBpCount = #limitBpItemList;
  for i = 1,limitBpCount do
    local limitBpData = limitBpItemList[i];
    if limitBpData ~= nil then
      local isItemNotLock = limitBpData.itemState == MainlineBpLimitBpItemState.IN_CLAIM_AND_CAN_CLAIM or limitBpData.itemState == MainlineBpLimitBpItemState.IN_CLAIM_AND_CLAIMED;
      if isItemNotLock == false then
        local lastIndex = i - 1;
        if lastIndex < 1 then
          lastIndex = 1;
        end
        
        return lastIndex;
      end
    end
  end
  
  return limitBpCount;
end


function MainlineBpViewModel:_LoadMainTabData()
  self.bpItemName = "";
  local data = self.m_cachedGameData;
  local periodId = self.currPeriodId;
  if data == nil or periodId == nil then
    return;
  end
  local periodData = MainlineBpUtil.GetPeriodData(data.periodDataList, periodId);
  if periodData == nil then
    return;
  end
  local actId = self.actId;
  local suc, basicData = CS.Torappu.ActivityDB.data.basicInfo:TryGetValue(actId);
  if not suc then
    return;
  end
  local endTs = basicData.endTime;
  local endTime = luaUtils.ToDateTime(endTs);
  self.endTimeDesc = CS.Torappu.FormatUtil.FormatDateTimeyyyyMMddHHmm(endTime);
  self.isBpUpActive = periodData.canGetBuff;
  self.bpUpCondDesc = periodData.bpBuffDesc;
  local suc, actItemList = CS.Torappu.ActivityDB.data.activityItems:TryGetValue(actId);
  if suc and actItemList ~= nil and actItemList.Count > 0 then
    local bpItemId = actItemList[0];
    self.bpItemName = CS.Torappu.UI.ItemUtil.GetItemName(bpItemId);
  end
end



function MainlineBpViewModel:_RefreshMainTabData(playerData)
  if playerData == nil then
    return;
  end
  self.showBpTrackPoint = MainlineBpUtil.CheckIfShowBpTrackPoint(self.m_cachedGameData, self.currPeriodId, playerData);
  self.showMissionTrackPoint = MainlineBpUtil.CheckIfShowMissionTrackPoint(self.m_cachedGameData, self.currPeriodId);
  local currentStage = CS.Torappu.StageDataUtil.GetMainStageProgress();
  if currentStage == nil then
    self.isAllStageComplete = true;
    self.currStageCode = StringRes.MAINLINE_BP_STAGE_COMPLETE;
    self.currStageId = "";
    self.currStageZoneId = "";
  else
    self.isAllStageComplete = false;
    self.currStageId = currentStage.stageId;
    self.currStageZoneId = currentStage.zoneId;
    local diffName = CS.Torappu.StageDataUtil.GetDiffName(currentStage.diffGroup, true);
    if diffName ~= nil and diffName ~= "" then
      self.currStageCode = luaUtils.Format("{0} {1}", diffName, currentStage.code);
    else
      self.currStageCode = currentStage.code;
    end
  end

  if playerData == nil then
    self.bpPoint = 0;
    self.bpUpDesc = "";
    self.bpUpPercent = 0;
    return;
  end
  self.bpPoint = playerData.milestonePoints;
  self.bpUpDesc = luaUtils.Format(StringRes.MAINLINE_BP_UP_DESC_FORMAT, playerData.milestoneBuff);
  self.bpUpPercent = playerData.milestoneBuff / MainlineBpViewModel.MAX_MILESTONE_BUFF;
end

function MainlineBpViewModel:_LoadBpUpData()
  self.bpUpDescModelList = {};
  local data = self.m_cachedGameData;
  if data == nil then
    return;
  end
  for index, item in pairs(data.bpBuffDataList) do
    if item.stageId == nil then
      local model = MainlineBpBpUpDetailItemModel.new();
      model.stageCode = StringRes.MAINLINE_BP_UP_DETAIL_ITEM_DEFAULT;
      model.upPercentDesc = luaUtils.Format("+{0}%", item.bpBuffPercent);
      model.sortId = item.sortId;
      table.insert(self.bpUpDescModelList, model);
    else
      local stageData = CS.Torappu.StageDataUtil.GetStageIgnoreTime(item.stageId);
      if stageData == nil then
        luaUtils.LogError("[MainlineBp] Cannot find stage data of [" .. item.stageId .. "].");
        break;
      end
      local diffGroupDesc = CS.Torappu.StageDataUtil.GetDiffName(stageData.diffGroup, true);
      local model = MainlineBpBpUpDetailItemModel.new();
      model.stageCode = luaUtils.Format(StringRes.MAINLINE_BP_UP_DETAIL_ITEM_FORMAT,
          diffGroupDesc, stageData.code);
      model.upPercentDesc = luaUtils.Format("+{0}%", item.bpBuffPercent);
      model.sortId = item.sortId;
      table.insert(self.bpUpDescModelList, model);
    end
  end
  table.sort(self.bpUpDescModelList, function(a, b)
    if a.sortId ~= b.sortId then
      return a.sortId < b.sortId;
    end
    return a.upPercentDesc < b.upPercentDesc;
  end);
end

return MainlineBpViewModel;