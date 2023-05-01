local CheckinAllPlayerDailyItemViewModel = require "Feature/Activity/CheckinAllPlayer/ViewModel/CheckinAllPlayerDailyItemViewModel"
local CheckinAllPlayerBhvRewardViewModel = require "Feature/Activity/CheckinAllPlayer/ViewModel/CheckinAllPlayerBhvRewardViewModel"









CheckinAllPlayerViewModel = Class("CheckinAllPlayerViewModel", UIViewModel);


function CheckinAllPlayerViewModel:Init(actId)
  self.activityId = actId;
  self.checkinList = {};
  self.bhvRewards = {};
  self.focusDay = 0;
  
  local suc, actData = CS.Torappu.ActivityDB.data.activity.allPlayerCheckinData:TryGetValue(actId);
  if not suc then
    LogError("[CHECKIN_ALL_PLAYER]Can't find the activity data:".. actId);
    return false;
  end
  self.activityData = actData;

  
  for dayIdx, dailyData in pairs(actData.checkInList) do
    local itemModel = CheckinAllPlayerDailyItemViewModel.new();
    itemModel.dayIdx = dayIdx;
    itemModel.data = dailyData;
    table.insert(self.checkinList, itemModel);
  end
  table.sort(self.checkinList, function(a, b)
    return a.dayIdx < b.dayIdx;
  end)

  
  for bhvId, pubData in pairs(actData.pubBhvs) do
    local extRewardModel = CheckinAllPlayerBhvRewardViewModel.new();
    extRewardModel.pubBhvData = pubData;
    self.bhvRewards[pubData.displayOrder] = extRewardModel;
  end
  for bhvId, perData in pairs(actData.personalBhvs) do
    local displayOrder = perData.displayOrder;
    local extRewardModel = self.bhvRewards[displayOrder];
    if extRewardModel then
      
      local perBhvModel = {
        perBhvData = perData,
        num = 0,
      };
      table.insert( extRewardModel.perBhvModels, perBhvModel);
    end
  end
  for _, extRewardModel in pairs(self.bhvRewards) do
    table.sort(extRewardModel.perBhvModels, function(a, b)
      return a.perBhvData.sortId < b.perBhvData.sortId;
    end)
  end
end

function CheckinAllPlayerViewModel:UpdateState(fresh)
  local checkinAllPlayers = CS.Torappu.PlayerData.instance.data.activity.checkinAllActivityList;
  local suc, playerActData = checkinAllPlayers:TryGetValue(self.activityId); 
  if not suc then
    LogError("[CHECKIN_ALL_PLAYER]Can't find the activity player data");
    return false;
  end

  self.fresh = fresh;
  self.focusDay = playerActData.history.Count - 1;
  self.skinDay = nil;
  for _, itemModel in ipairs(self.checkinList) do
    itemModel.state = self:_CheckState(itemModel.dayIdx, playerActData.history);
    
    if itemModel.state == CheckinAllPlayerRewardStatus.AVAILABLE and itemModel.dayIdx < self.focusDay then
      self.focusDay = itemModel.dayIdx;
    end
    
    if itemModel.data.showItemOrder > 0 and self.skinDay == nil then
      self.skinDay = itemModel.dayIdx + 1 - playerActData.history.Count;
      if self.skinDay <= 0 then
        if itemModel.state == CheckinAllPlayerRewardStatus.AVAILABLE then
          self.skinDay = 0;
        else
          self.skinDay = -1;
        end
      end
    end
  end

  for _, extRewardModel in pairs(self.bhvRewards) do
    local suc, num = playerActData.allRecord:TryGetValue(extRewardModel.pubBhvData.allBehaviorId);
    if suc then
      extRewardModel.num = num;
    end
    local suc, status = playerActData.allRewardStatus:TryGetValue(extRewardModel.pubBhvData.allBehaviorId);
    if suc then
      extRewardModel.status = status;
    else
      extRewardModel.status = CheckinAllPlayerRewardStatus.NONE;
    end

    for idx, perBhvModel in pairs(extRewardModel.perBhvModels) do
      local suc, perNum = playerActData.personalRecord:TryGetValue(perBhvModel.perBhvData.personalBehaviorId);
      if suc then
        perBhvModel.num = perNum;
      end
    end
  end
end




function CheckinAllPlayerViewModel:_CheckState(dayidx, history)
  if dayidx >= history.Count then
    return CheckinAllPlayerRewardStatus.NONE;
  end
  return history[dayidx];
end


CheckinAllPlayerRewardStatus = {
  DISABLE = 2,
  AVAILABLE = 1,
  RECEIVED = 0,
  NONE = -1, 
}
CheckinAllPlayerRewardStatus = Readonly(CheckinAllPlayerRewardStatus);