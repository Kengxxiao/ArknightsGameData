local luaUtils = CS.Torappu.Lua.Util







local GridGachaPackageModel = Class("GridGachaPackageModel");

function GridGachaPackageModel:ctor()
  self.isGrandAward = false;
end

function GridGachaPackageModel:SyncToModel(index, gridModel)
  self.isGrandAward = gridModel:CheckIfGrandAward(index);
  self.isReward = gridModel:CheckIfReward(index);
  self.hasGacha = gridModel:HasGacha();
  self.isShowing = gridModel:IsGacha();
  self.isCritical = gridModel:CheckIfCritical(index);
end


















local GridGachaViewModel = Class("GridGachaViewModel");

function GridGachaViewModel:CalculatePosition(row, column)
  return 10 * row + column + 1;
end

function GridGachaViewModel:InitData(actId, packageCount)
  if self.packageModels == nil then
    self.packageModels = {};
  end
  if self.grandAwardModels == nil then
    self.grandAwardModels = {};
  end
  local modelCount = #self.packageModels;
  for i = 1, packageCount do
    local model = self.packageModels[i];
    if model == nil then
      model = GridGachaPackageModel.new();
      table.insert(self.packageModels, i, model);
    end
  end
  for i = modelCount, packageCount + 1, -1 do
    table.remove(self.packageModels, i);
  end
  self.packageCount = packageCount;
  self.m_isShowing = false;
  self.m_skipAnime = false;
  self:_LoadPlayerData(actId);
  self:_LoadGameData(actId);
  self:_SyncInfoToPackModels();
end

function GridGachaViewModel:_LoadPlayerData(actId)
  self.m_hasGacha = true;
  self.m_isLastDay = true;
  self.m_isFirstDay = true;

  local playerActList = CS.Torappu.PlayerData.instance.data.activity.gridGachaActivityList
  if actId == nil or playerActList == nil then
    return
  end
  local suc, playerAct = playerActList:TryGetValue(actId)
  if not suc then
    return
  end
  self.m_isLastDay = playerAct.lastDay;
  self.m_isFirstDay = playerAct.firstDay;
  
  local openedPosition = playerAct.openedPosition;
  if openedPosition.Count == 0 then
    self.rewardModel = -1;
    self.m_hasGacha = false;
  else
    self.rewardModel = self:CalculatePosition(openedPosition[0], openedPosition[1]);
    self.rewards = playerAct.rewardCount;
    self.openedType = playerAct.openedType;
  end
  
  
  
  local grandPositions = playerAct.grandPositions;
  for i = 0, grandPositions.Count - 1 do
    local info = grandPositions[i];
    local luaIndex = i + 1;
    table.insert(self.grandAwardModels, luaIndex, self:CalculatePosition(info[0], info[1]));
  end
end

function GridGachaViewModel:_LoadGameData(actId)
  self.endTimeDesc = nil;
  self.m_endTime = nil;
  local suc, basicInfo = CS.Torappu.ActivityDB.data.basicInfo:TryGetValue(actId);
  if not suc then
    return
  end
  local endTime = luaUtils.ToDateTime(basicInfo.endTime);
  self.endTimeDesc = CS.Torappu.Lua.Util.Format(
    CS.Torappu.StringRes.DATE_FORMAT_YYYY_MM_DD_HH_MM, 
    endTime.Year, endTime.Month, endTime.Day, endTime.Hour, endTime.Minute
  );
  self.m_endTime = endTime;
end

function GridGachaViewModel:CheckIfGrandAward(index)
  for i, index1 in ipairs(self.grandAwardModels) do
    if index == index1 then
      return true;
    end
  end
  return false;
end

function GridGachaViewModel:CheckIfCritical(index)
  if index == self.rewardModel then
    return (self.openedType == 1);
  end
  return false;
end

function GridGachaViewModel:CheckIfReward(index)
  return (index == self.rewardModel);
end

function GridGachaViewModel:_SyncInfoToPackModels()
  for index, packModel in ipairs(self.packageModels) do
    packModel:SyncToModel(index, self);
  end
end

function GridGachaViewModel:MarkGachaStart()
  self.m_isShowing = true;
end

function GridGachaViewModel:MarkGachaFinish()
  self.m_isShowing = false;
  self.m_hasGacha = true;
end 

function GridGachaViewModel:HasGacha()
  return self.m_hasGacha;
end 


function GridGachaViewModel:IsGacha()
  return self.m_isShowing;
end


return GridGachaViewModel;