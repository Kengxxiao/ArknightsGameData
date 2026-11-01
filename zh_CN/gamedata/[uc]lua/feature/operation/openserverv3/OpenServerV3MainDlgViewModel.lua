






local OpenServerV3TabEntryViewModel = Class("OpenServerV3TabEntryViewModel");


function OpenServerV3TabEntryViewModel:ctor(tabState)
  self.tabState = tabState;
  self.visible = false;
  self.selected = false;
  self.hasTrackPoint = false;
  self.hasNewSign = false;
  self.showTimeLimitTip = false;
end






function OpenServerV3TabEntryViewModel:Refresh(visible,
    selected, hasTrackPoint, hasNewSign, showTimeLimitTip)
  self.visible = visible;
  self.selected = selected;
  self.hasTrackPoint = hasTrackPoint;
  self.hasNewSign = hasNewSign;
  self.showTimeLimitTip = showTimeLimitTip;
end











OpenServerV3MainDlgViewModel = Class("OpenServerV3MainDlgViewModel", UIViewModel);

local OpenServerV3CheckInViewModel = require("Feature/Operation/OpenServerV3/CheckIn/OpenServerV3CheckInViewModel");
local OpenServerV3MissionViewModel = require("Feature/Operation/OpenServerV3/Mission/OpenServerV3MissionViewModel");
local OpenServerV3StageViewModel = require("Feature/Operation/OpenServerV3/Stage/OpenServerV3StageViewModel");
local OpenServerV3GiftPackageViewModel = require("Feature/Operation/OpenServerV3/GiftPackage/OpenServerV3GiftPackageViewModel");

local TAB_STATE_LIST = {
  OpenServerV3TabState.STATE_TAB_MISSION,
  OpenServerV3TabState.STATE_TAB_CHECK_IN,
  OpenServerV3TabState.STATE_TAB_STAGE,
  OpenServerV3TabState.STATE_TAB_GIFT_PACKAGE,
};

local TAB_INITIAL_TRACK_POINT_LIST = {
  OpenServerV3TabState.STATE_TAB_CHECK_IN,
  OpenServerV3TabState.STATE_TAB_MISSION,
  OpenServerV3TabState.STATE_TAB_STAGE,
  OpenServerV3TabState.STATE_TAB_GIFT_PACKAGE,
};

function OpenServerV3MainDlgViewModel:LoadData()
  self.checkinViewModel = OpenServerV3CheckInViewModel.new();
  self.checkinViewModel:LoadData();
  self.missionViewModel = OpenServerV3MissionViewModel.new();
  self.missionViewModel:LoadData();
  self.stageViewModel = OpenServerV3StageViewModel.new();
  self.stageViewModel:LoadData();
  self.giftPackageViewModel = OpenServerV3GiftPackageViewModel.new();
  self.giftPackageViewModel:LoadData();
  self.tabState = self:_PickInitialTabState();
  self.m_tabEntryModels = {};
  self:_InitTabEntryModels();

  local osModel = OpenServerV3Model.me;
  local osPlayerData = osModel:GetPlayerData();
  local checkInGroupId = osPlayerData ~= nil and osPlayerData.checkIn ~= nil
      and osPlayerData.checkIn.groupId or nil;
  if checkInGroupId == nil or checkInGroupId == "" then
    self.showClaim = true;
    self.claimGuidebookSubSignal = nil;
  else
    self.showClaim = false;
    self.claimGuidebookSubSignal = nil;
    local gameData = osModel:GetGameData();
    if gameData ~= nil then
      local ok, groupData = gameData.checkInData:TryGetValue(checkInGroupId);
      if ok and groupData ~= nil and
          groupData.guidebookTrigger ~= nil and groupData.guidebookTrigger ~= "" then
        self.showClaim = true;
        self.claimGuidebookSubSignal = groupData.guidebookTrigger;
      end
    end
  end

  self:RefreshPlayerData();
  self.missionViewModel:SelectRecommendedStage();
end

function OpenServerV3MainDlgViewModel:RefreshPlayerData()
  if self.checkinViewModel ~= nil then
    self.checkinViewModel:RefreshPlayerData();
  end
  if self.missionViewModel ~= nil then
    self.missionViewModel:RefreshPlayerData();
  end
  if self.stageViewModel ~= nil then
    self.stageViewModel:RefreshPlayerData();
  end

  if self.giftPackageViewModel ~= nil then
    self.giftPackageViewModel:RefreshPlayerData();
  end
  self:_RefreshTabEntryModels();
  self:_EnsureValidTabState();
end


function OpenServerV3MainDlgViewModel:SetTabState(tabState)
  if tabState == nil then
    return;
  end
  local model = self:GetTabEntryModel(tabState);
  if model == nil or not model.visible then
    return;
  end
  self.tabState = tabState;
  self:_RefreshTabEntrySelectedState();
end



function OpenServerV3MainDlgViewModel:GetTabEntryModel(tabState)
  if self.m_tabEntryModels == nil then
    return nil;
  end
  return self.m_tabEntryModels[tabState];
end


function OpenServerV3MainDlgViewModel:_InitTabEntryModels()
  for _, tabState in ipairs(TAB_STATE_LIST) do
    local model = OpenServerV3TabEntryViewModel.new(tabState);
    model:Refresh(self:_IsTabVisible(tabState), self.tabState == tabState, false, false, false);
    self.m_tabEntryModels[tabState] = model;
  end
end


function OpenServerV3MainDlgViewModel:_RefreshTabEntryModels()
  for _, tabState in ipairs(TAB_STATE_LIST) do
    local model = self.m_tabEntryModels[tabState];
    if model ~= nil then
      
      model:Refresh(
          model.visible,
          self.tabState == tabState,
          self:_HasTabTrackPoint(tabState),
          self:_HasTabNewSign(tabState),
          self:_ShowTimeLimitTip(tabState));
    end
  end
end


function OpenServerV3MainDlgViewModel:_RefreshTabEntrySelectedState()
  for _, tabState in ipairs(TAB_STATE_LIST) do
    local model = self.m_tabEntryModels[tabState];
    if model ~= nil then
      model:Refresh(
          model.visible,
          self.tabState == tabState,
          model.hasTrackPoint,
          model.hasNewSign,
          model.showTimeLimitTip);
    end
  end
end



function OpenServerV3MainDlgViewModel:_PickInitialTabState()
  for _, tabState in ipairs(TAB_INITIAL_TRACK_POINT_LIST) do
    if self:_IsTabVisible(tabState) and self:_HasTabTrackPoint(tabState) then
      return tabState;
    end
  end
  for _, tabState in ipairs(TAB_STATE_LIST) do
    if self:_IsTabVisible(tabState) then
      return tabState;
    end
  end
  return OpenServerV3TabState.STATE_TAB_MISSION;
end


function OpenServerV3MainDlgViewModel:_EnsureValidTabState()
  local currentModel = self:GetTabEntryModel(self.tabState);
  if currentModel ~= nil and currentModel.visible then
    return;
  end
  for _, tabState in ipairs(TAB_STATE_LIST) do
    local model = self:GetTabEntryModel(tabState);
    if model ~= nil and model.visible then
      self.tabState = tabState;
      break;
    end
  end
  self:_RefreshTabEntrySelectedState();
end




function OpenServerV3MainDlgViewModel:_IsTabVisible(tabState)
  local model = OpenServerV3Model.me;
  if tabState == OpenServerV3TabState.STATE_TAB_CHECK_IN then
    return not model:CheckIfCheckInComplete();
  end
  if tabState == OpenServerV3TabState.STATE_TAB_MISSION then
    return not model:CheckIfMissionTabComplete();
  end
  if tabState == OpenServerV3TabState.STATE_TAB_STAGE then
    return not model:CheckIfStageComplete();
  end
  if tabState == OpenServerV3TabState.STATE_TAB_GIFT_PACKAGE then
    return not model:CheckIfGiftPackageComplete();
  end
  return false;
end




function OpenServerV3MainDlgViewModel:_HasTabTrackPoint(tabState)
  local model = OpenServerV3Model.me;
  if tabState == OpenServerV3TabState.STATE_TAB_CHECK_IN then
    return model:CheckIfHasCheckInReward();
  end
  if tabState == OpenServerV3TabState.STATE_TAB_MISSION then
    return model:CheckIfHasMissionReward() or model:CheckIfHasMilestoneReward();
  end
  return false;
end




function OpenServerV3MainDlgViewModel:_HasTabNewSign(tabState)
  local model = OpenServerV3Model.me;
  if tabState == OpenServerV3TabState.STATE_TAB_MISSION then
    return model:CheckIfHasMissionTabNewTip();
  elseif tabState == OpenServerV3TabState.STATE_TAB_STAGE then
    return model:CheckIfHasStageNewTip();
  elseif tabState == OpenServerV3TabState.STATE_TAB_GIFT_PACKAGE then
    return model:CheckIfHasGiftPackageNewTip();
  end
  return false;
end




function OpenServerV3MainDlgViewModel:_ShowTimeLimitTip(tabState)
  if tabState == OpenServerV3TabState.STATE_TAB_STAGE and self.stageViewModel ~= nil then
    return self.stageViewModel.showResourceFullOpen or
        self.stageViewModel.isResourceFullOpenPaused;
  elseif tabState == OpenServerV3TabState.STATE_TAB_GIFT_PACKAGE and
      self.giftPackageViewModel ~= nil and self.giftPackageViewModel.itemList ~= nil then
    for _, value in ipairs(self.giftPackageViewModel.itemList) do
      if value.isLimit then
        return true;
      end
    end
    return false;
  end
  return false;
end