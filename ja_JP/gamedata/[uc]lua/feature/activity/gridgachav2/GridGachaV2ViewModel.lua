local luaUtils = CS.Torappu.Lua.Util;







local GridGachaV2ItemModel = Class("GridGachaV2ItemModel");

function GridGachaV2ItemModel:ctor()
  self.isCritical = false;
  self.isGrand = false;
  self.isNew = false;
  self.isReward = false;
end

function GridGachaV2ItemModel:SyncToModel(index, gridModel)
  self.isGrand = gridModel:CheckIfGrandAward(index);
  self.isCritical = gridModel:CheckIfCritical(index);
  self.hasGacha = gridModel:HasGacha();
  self.isReward = gridModel:CheckIfReward(index);
  self.isNew = gridModel:CheckIfNew(index);
end


















local GridGachaV2ViewModel = Class("GridGachaV2ViewModel");



function GridGachaV2ViewModel:CalculatePosition(row, column)
  return 10 * row + column + 1;
end

function GridGachaV2ViewModel:InitData(actId, itemCount)
  if self.itemModels == nil then
    self.itemModels = {};
  end
  if self.grandAwardModelIdList == nil then
    self.grandAwardModelIdList = {};
  end
  if self.newAwardModelIdList == nil then
    self.newAwardModelIdList = {};
  end
  if self.grandSegmentStatus == nil then
    self.grandSegmentStatus = {};
  end
  local currItemModelCount = #self.itemModels;
  for i = 1, itemCount do
    local model = self.itemModels[i];
    if model == nil then
      model = GridGachaV2ItemModel.new();
      table.insert(self.itemModels, i, model);
    end
  end
  for i = currItemModelCount, itemCount +1, -1 do
    table.remove(self.itemModels, i);
  end
  self.itemCount = itemCount;
  self.m_isShowing = false;
  self:_LoadPlayerData(actId);
  self:_LoadGameData(actId);
  self:_SyncInfoToItemModels();
end




function GridGachaV2ViewModel:_LoadPlayerData(actId)
  self.m_hasGacha = true;
  self.m_isSegment = false;
  self.grandPercent = 0.02;
  self.rewardModelId = 0;
  self.rewards = 0;
  self.openedType = -1;

  local playerActList = CS.Torappu.PlayerData.instance.data.activity.gridGachaV2ActivityList;
  if actId == nil or playerActList == nil then
    return;
  end
  local suc, playerAct = playerActList:TryGetValue(actId);
  if not suc then
    return;
  end

  local playerActData = luaUtils.ConvertJObjectToLuaTable(playerAct);

  local today = playerActData.today;
  local matrix = playerActData.matrix;
  self.grandPercent = playerActData.bestRatio;
  self.grandSegmentStatus = playerActData.bestSegments;
  
  self.m_hasGacha = today.done == 1;
  if self.m_hasGacha then
    self.m_isSegment = today.isGift == 1;
    self.rewardModelId = self:CalculatePosition(today.pos.x, today.pos.y);
    self.rewards = today.count;
    self.openedType = today.type;
  end
  
  self.grandAwardModelIdList = {};
  for i = 1, #matrix do
    local position = matrix[i];
    table.insert(self.grandAwardModelIdList, self:CalculatePosition(position.x, position.y));
  end
  
  self.newAwardModelIdList = {};
  for i = 1, #today.newPosition do
    local position = today.newPosition[i]; 
    table.insert(self.newAwardModelIdList, self:CalculatePosition(position.x, position.y));
  end
end

function GridGachaV2ViewModel:_LoadGameData(actId)
  self.endTimeDesc = nil;
  self.m_endTime = nil;
  local suc, basicInfo = CS.Torappu.ActivityDB.data.basicInfo:TryGetValue(actId);
  if not suc then
    return;
  end
  local endTime = luaUtils.ToDateTime(basicInfo.endTime);
  self.endTimeDesc = CS.Torappu.Lua.Util.Format(
    CS.Torappu.StringRes.DATE_FORMAT_YYYY_MM_DD_HH_MM,
    endTime.Year, endTime.Month, endTime.Day, endTime.Hour, endTime.Minute
  );
  self.m_endTime = endTime;
end

function GridGachaV2ViewModel:_SyncInfoToItemModels()
  for index, itemModel in ipairs(self.itemModels) do
    itemModel:SyncToModel(index, self);
  end
end

function GridGachaV2ViewModel:CheckIfGrandAward(index)
  if index == self.rewardModelId then
    return (self.openedType == 2);
  end

  for i, grandIndex in ipairs(self.grandAwardModelIdList) do
    if index == grandIndex then
      return true;
    end
  end

  return false;
end

function GridGachaV2ViewModel:CheckIfCritical(index)
  if index == self.rewardModelId then
    return (self.openedType == 1);
  end
  return false;
end

function GridGachaV2ViewModel:MarkGachaStart()
  self.m_isShowing = true;
end

function GridGachaV2ViewModel:MarkGachaFinish()
  self.m_isShowing = false;
  self.m_hasGacha = true;
end

function GridGachaV2ViewModel:CheckIfReward(index)
  return (index == self.rewardModelId);
end

function GridGachaV2ViewModel:CheckIfNew(index)
  for i, newIndex in ipairs(self.newAwardModelIdList) do
    if index == newIndex then
      return true;
    end
  end
  return false;
end

function GridGachaV2ViewModel:HasGacha()
  return self.m_hasGacha;
end 

function GridGachaV2ViewModel:IsShowing()
  return self.m_isShowing;
end

function GridGachaV2ViewModel:IsSegment()
  return self.m_isSegment;
end

return GridGachaV2ViewModel;