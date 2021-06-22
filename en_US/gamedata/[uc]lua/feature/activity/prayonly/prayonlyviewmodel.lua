local luaUtils = CS.Torappu.Lua.Util









local PrayOnlyPackageModel = Class("PrayOnlyPackageModel")

function PrayOnlyPackageModel:ctor()
  self.reward = 0
  self.isSelected = false
  self.canSelectMore = false
  self.hasPrayed = false
  self.isConfirmedReward = false
end



function PrayOnlyPackageModel:SyncToModel(index, prayModel)
  self.reward = prayModel:GetRewardCount(index)
  self.isSelected = prayModel:CheckIfSelected(index)
  self.canSelectMore = prayModel:CheckCanSelectMore()
  self.hasPrayed = prayModel:HasPrayed()
  self.isConfirmedReward = prayModel:RewardIndex() == index
  self.isPraying = prayModel:IsPraying()
end


















local PrayOnlyViewModel = Class("PrayOnlyViewModel")


PrayOnlyViewModel.IsUpView = function(index)
  return (index % 2) ~= 0
end


function PrayOnlyViewModel:InitData(actId, packageCount)
  
  if self.packageModels == nil then
    self.packageModels = {}
  end
  local modelCount = #self.packageModels
  for i = 1, packageCount do 
    local model = self.packageModels[i]
    if model == nil then
      model = PrayOnlyPackageModel.new()
      table.insert(self.packageModels, i, model)
    end
  end
  for i = modelCount, packageCount + 1, -1 do 
    table.remove(self.packageModels, i)
  end
  self.packageCount = packageCount
  
  local upCount = 0
  local downCount = 0
  local upModels = {}
  local downModels = {}
  for i = 1, packageCount do
    local model = self.packageModels[i]
    if PrayOnlyViewModel.IsUpView(i) then
      upCount = upCount + 1
      table.insert(upModels, model)
    else
      downCount = downCount + 1
      table.insert(downModels, model)
    end
  end
  self.upCount = upCount
  self.downCount = downCount
  self.upModels = upModels
  self.downModels = downModels
  self.m_isPraying = false
  
  self:_LoadPlayerData(actId)
  
  self:_LoadGameData(actId)
  
  self:_SyncInfoToPackModels()
end

function PrayOnlyViewModel:_LoadPlayerData(actId)
  
  self.m_maxSelectCnt = 0
  self.m_hasPrayed = true
  self.m_confirmedRewardIndex = 0
  self.m_selectedIds = {}
  self.m_rewardMap = {}
  self.extraCount = 0
  self.m_lastTs = -1
  local playerActList = CS.Torappu.PlayerData.instance.data.activity.prayOnlyActivityList
  if actId == nil or playerActList == nil then
    return
  end
  local suc, playerAct = playerActList:TryGetValue(actId)
  if not suc then
    return
  end
  self.m_maxSelectCnt = playerAct.prayDaily
  self.m_hasPrayed = playerAct.praying
  self.extraCount = playerAct.extraCount
  self.m_lastTs = playerAct.lastTs

  local prayArrayList = playerAct.prayArray
  for i = 0, prayArrayList.Count - 1 do
    local info = prayArrayList[i]
    local luaIndex = info.index + 1
    self.m_rewardMap[luaIndex] = info.count
    table.insert(self.m_selectedIds, luaIndex)
  end
  self.m_confirmedRewardIndex = playerAct.prayMaxIndex + 1 
end

function PrayOnlyViewModel:_LoadGameData(actId)
  self.endTimeDesc = nil
  self.m_endTime = nil
  local suc, basicInfo = CS.Torappu.ActivityDB.data.basicInfo:TryGetValue(actId);
  if not suc then
    return
  end
  local endTime = luaUtils.ToDateTime(basicInfo.endTime)
  self.endTimeDesc = CS.Torappu.Lua.Util.Format(
      CS.Torappu.StringRes.DATE_FORMAT_YYYY_MM_DD_HH_MM,
      endTime.Year, endTime.Month, endTime.Day, endTime.Hour, endTime.Minute)
  self.m_endTime = endTime
end


function PrayOnlyViewModel:CheckIfSelected(index)
  if self.m_selectedIds == nil or index == nil then
    return false
  end
  for i, selectIndex in ipairs(self.m_selectedIds) do
    if selectIndex == index then
      return true
    end
  end
  return false
end


function PrayOnlyViewModel:CheckCanSelectMore()
  local selectCount = self:GetSelectCount()
  return selectCount < self.m_maxSelectCnt
end

function PrayOnlyViewModel:HasPrayed()
  return self.m_hasPrayed
end


function PrayOnlyViewModel:RewardIndex()
  return self.m_confirmedRewardIndex
end


function PrayOnlyViewModel:TryToggleSelectModel(index)
  local ret = self:_ToggleSelectImpl(index)
  if ret then
    self:_SyncInfoToPackModels()
  end
  return ret
end
function PrayOnlyViewModel:_ToggleSelectImpl(index)
  local selectedIds = self.m_selectedIds
  if selectedIds == nil then
    return false
  end
  for i, selectIndex in ipairs(selectedIds) do 
    if selectIndex == index then
      
      table.remove(selectedIds, i)
      return true
    end
  end
  
  local curSelectCount = #selectedIds
  if curSelectCount >= self.m_maxSelectCnt then
    return false
  end
  table.insert(selectedIds, index)
  return true
end


function PrayOnlyViewModel:GetSelectedIds()
  return self.m_selectedIds
end

function PrayOnlyViewModel:CheckIfCanGetReward()
  if self.m_hasPrayed then
    return false
  end
  if self:CheckCanSelectMore() then
    return false
  end
  return true
end

function PrayOnlyViewModel:GetRewardCount(index)
  if self.m_rewardMap == nil then
    return 0
  end
  local count = self.m_rewardMap[index]
  if count == nil then
    return 0
  end
  return count
end

function PrayOnlyViewModel:GetSelectCount()
  local selectCount = 0
  if self.m_selectedIds ~= nil then
    selectCount = #self.m_selectedIds
  end
  return selectCount
end

function PrayOnlyViewModel:GetMaxSelectCount() 
  return self.m_maxSelectCnt
end



function PrayOnlyViewModel:HasChanceNextDay()
  local endTime = self.m_endTime
  local lastTs = self.m_lastTs
  if endTime == nil or lastTs == nil or lastTs < 0 then
    return false
  end
  local checkTs = luaUtils.ToTimeStamp(endTime:AddDays(-1))
  return lastTs <= checkTs
end

function PrayOnlyViewModel:IsPraying()
  return self.m_isPraying
end

function PrayOnlyViewModel:MarkPrayingStart()
  self.m_isPraying = true
  self:_SyncInfoToPackModels()
end

function PrayOnlyViewModel:MarkPrayingFinish()
  self.m_isPraying = false
  self:_SyncInfoToPackModels()
end


function PrayOnlyViewModel:_SyncInfoToPackModels()
  for index, packModel in ipairs(self.packageModels) do
    packModel:SyncToModel(index, self)
  end
end

return PrayOnlyViewModel