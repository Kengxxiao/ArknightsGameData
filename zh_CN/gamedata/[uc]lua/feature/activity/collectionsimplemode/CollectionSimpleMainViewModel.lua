local luaUtils = CS.Torappu.Lua.Util






local CollectionSimpleMainViewModel = Class("CollectionSimpleMainViewModel")
local CollectionSimpleTaskListViewModel = require("Feature/Activity/CollectionSimpleMode/CollectionSimpleTaskListViewModel")
local CollectionSimpleRewardViewModel = require("Feature/Activity/CollectionSimpleMode/CollectionSimpleRewardViewModel")


function CollectionSimpleMainViewModel:LoadData(actId)
  if not actId then
    return 
  end

  self.actId = actId
  if not self.taskListViewModel then
    self.taskListViewModel = CollectionSimpleTaskListViewModel.new()
  end
  self.taskListViewModel:LoadData(actId)
  if not self.rewardViewModel then
    self.rewardViewModel = CollectionSimpleRewardViewModel.new()
  end
  self.rewardViewModel:LoadData(actId)
  self.canJumpToFunc = CS.Torappu.UI.ActivityUtil.IfCollectionActivityCanJumpToRelatedSystem(actId)
  self:_LoadActEndTime(actId)

  self:UpdateData(actId)
end


function CollectionSimpleMainViewModel:_LoadActEndTime(actId)
  if not actId then
    return
  end
  local actBasicInfo = CollectionActModel.me:FindBasicInfo(actId)
  if not actBasicInfo then
    return
  end
  local actConfig = CollectionActModel.me:GetActCfg(actId)
  if not actConfig or not actConfig.baseColorHex then
    return
  end
  local endDateTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(actBasicInfo.endTime)
  local timeRemain = endDateTime - CS.Torappu.DateTimeUtil.currentTime
  local timeRemainTxt = CS.Torappu.FormatUtil.FormatTimeDelta(timeRemain)
  self.actEndTimeStr = CS.Torappu.Lua.Util.Format(
      CS.Torappu.StringRes.ACT_COLLECTION_TIME_DESC,
      endDateTime.Year,
      endDateTime.Month,
      endDateTime.Day,
      endDateTime.Hour,
      endDateTime.Minute,
      actConfig.baseColorHex,
      timeRemainTxt)
end


function CollectionSimpleMainViewModel:UpdateData(actId)
  if self.taskListViewModel then
    self.taskListViewModel:UpdateData(actId)
  end
  if self.rewardViewModel then
    self.rewardViewModel:UpdateData(actId)
  end
end

return CollectionSimpleMainViewModel
