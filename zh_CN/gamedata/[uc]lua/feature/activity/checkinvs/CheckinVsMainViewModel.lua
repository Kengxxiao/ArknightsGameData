local TasteType = CS.Torappu.VersusCheckInData.TasteType
local luaUtils = CS.Torappu.Lua.Util
local CSItemUtil = CS.Torappu.UI.ItemUtil
local CheckinVsDefine = require("Feature/Activity/CheckinVs/CheckinVsDefine")
















local CheckinVsMainViewModel = Class("CheckinVsMainViewModel", UIViewModel)

CheckinVsMainViewModel.DisplayStatus = {
  MAIN_VIEW = 0,
  RULE_VIEW = 1,
  REWARD_VIEW = 2
}

CheckinVsMainViewModel.RewardStatus = {
  NORMAL = 0,
  ACTIVE = 1,
  FINISH = 2
}

CheckinVsMainViewModel.BtnVoteStatus = {
  INVISIBLE = 0,
  ACTIVE = 1,
  INACTIVE = 2,
  GAIN_REWARD = 3
}



function CheckinVsMainViewModel:InitData(actId)
  self.activityId = actId
  local suc1, actData = CS.Torappu.ActivityDB.data.activity.versusCheckInData:TryGetValue(actId)
  if not suc1 then
    LogError("[CHECKIN_VS]Can't find the activity data: " .. actId)
    return
  end
  self.m_actData = actData

  local suc2, basicInfo = CS.Torappu.ActivityDB.data.basicInfo:TryGetValue(actId)
  if not suc2 then
    LogError("[CHECKIN_VS]Can't find the basic activity info: " .. actId)
  end
  self.m_basicInfo = basicInfo
  self.m_displayStatus = self.DisplayStatus.MAIN_VIEW

  self:UpdatePlayerData()
end


function CheckinVsMainViewModel:UpdatePlayerData()
  self:_ClearPlayerData()

  if string.isNullOrEmpty(self.activityId) then
    return
  end

  local playerCheckinVsActList = CS.Torappu.PlayerData.instance.data.activity.checkinVsActivityList
  local suc, playerData = playerCheckinVsActList:TryGetValue(self.activityId)
  if not suc then
    return
  end

  self.sweetVote = playerData.sweetVote
  self.saltyVote = playerData.saltyVote
  self.voteRewardState = playerData.voteRewardState
  self.canVote = playerData.canVote
  self.todayVoteState = playerData.todayVoteState
  self.signedCnt = playerData.signedCnt
  self.availSignCnt = playerData.availSignCnt
  self.socialState = playerData.socialState
  self.actDay = playerData.actDay
end

function CheckinVsMainViewModel:_ClearPlayerData()
  self.sweetVote = 0
  self.saltyVote = 0
  self.voteRewardState = CheckinVsDefine.VoteRewardStatus.NORMAL
  self.canVote = false
  self.todayVoteState = CheckinVsDefine.TasteChoice.NONE
  self.signedCnt = 0
  self.availSignCnt = 0
  self.socialState = CheckinVsDefine.TasteChoice.NONE
  self.actDay = 0
end


function CheckinVsMainViewModel:GetDislapySignIndex()
  local totalDays = 0
  if self.m_actData ~= nil and self.m_actData.checkInDict ~= nil then
    totalDays = self.m_actData.checkInDict.Count
  end

  local displayIdx = self.signedCnt
  if self.availSignCnt > 0 then
    displayIdx = displayIdx + 1
  end

  return displayIdx
end



function CheckinVsMainViewModel:GetRewardList(dayIndex)
  if self.m_actData == nil or self.m_actData.checkInDict == nil then
    return nil
  end

  local suc, dailyInfo = self.m_actData.checkInDict:TryGetValue(dayIndex)
  if not suc then
    return nil
  end

  return dailyInfo.rewardList
end



function CheckinVsMainViewModel:GetRewardStatus(dayIndex)
  if dayIndex <= self.signedCnt then
    return self.RewardStatus.FINISH
  end
  return self.RewardStatus.NORMAL
end


function CheckinVsMainViewModel:GetRewardListCount()
  if self.m_actData == nil or self.m_actData.checkInDict == nil then
    return 0
  end
  return self.m_actData.checkInDict.Count
end


function CheckinVsMainViewModel:GetApTimeDesc()
  if self.m_actData == nil or self.m_actData.apSupplyOutOfDateDict == nil then
    return ""
  end

  for itemId, dueTime in pairs(self.m_actData.apSupplyOutOfDateDict) do
    local endTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(dueTime)
    local timeStr = luaUtils.Format(StringRes.DATE_FORMAT_YYYY_MM_DD_HH_MM,
        endTime.Year, endTime.Month, endTime.Day, endTime.Hour, endTime.Minute)
    local itemName = CSItemUtil.GetItemName(itemId)
    return luaUtils.Format(StringRes.STAGE_ACTIVITY_AP_ITEM, itemName, timeStr)
  end

  return ""
end


function CheckinVsMainViewModel:GetRewardGainStatus()
  if self.voteRewardState ~= CheckinVsDefine.VoteRewardStatus.HAS_GOT then
    return CheckinVsDefine.TasteChoice.NONE
  end

  local tasteInfo = self:GetCurrentTasteInfo()
  if tasteInfo == nil then
    return CheckinVsDefine.TasteChoice.NONE
  end

  if tasteInfo.tasteType == TasteType.SWEET then
    return CheckinVsDefine.TasteChoice.SWEET
  end

  if tasteInfo.tasteType == TasteType.SALT then
    return CheckinVsDefine.TasteChoice.SALTY
  end

  if tasteInfo.tasteType == TasteType.DRAW then
    return self.socialState
  end
end


function CheckinVsMainViewModel:GetRuleDesc()
  if self.m_actData == nil then
    return ""
  end
  return self.m_actData.ruleText
end



function CheckinVsMainViewModel:GetSpecialRewardName(isSalty)
  local tasteType = nil
  if isSalty then
    tasteType = TasteType.SALT
  else
    tasteType = TasteType.SWEET
  end
  
  local suc, rewardData = self.m_actData.tasteRewardDict:TryGetValue(tasteType)
  if not suc then
    return ""
  end

  local rewardItem = rewardData.rewardItem
  if rewardItem == nil then
    return ""
  end
  return CSItemUtil.GetItemName(rewardItem:GetItemId(), rewardItem:GetItemType())
end


function CheckinVsMainViewModel:IsVoteFinish()
  local totalVoteDay = self:GetTotalVoteDay()
  return self.actDay > totalVoteDay
end

function CheckinVsMainViewModel:IsVoteCntVisible()
  if self.sweetVote <= 0 and self.saltyVote <= 0 then
    return false
  end

  if self:IsVoteFinish() and self.voteRewardState ~= CheckinVsDefine.VoteRewardStatus.ACTIVE then
    return false
  end

  return true
end



function CheckinVsMainViewModel:CalcBtnVoteStatus(btnTaste)
  if btnTaste == CheckinVsDefine.TasteChoice.NONE then
    return CheckinVsMainViewModel.BtnVoteStatus.INVISIBLE
  end

  local isVoteFinish = self:IsVoteFinish()

  if isVoteFinish then
    if self.voteRewardState ~= CheckinVsDefine.VoteRewardStatus.ACTIVE then
      return CheckinVsMainViewModel.BtnVoteStatus.INVISIBLE
    end

    local tasteInfo = self:GetCurrentTasteInfo()
    if tasteInfo == nil then
      return CheckinVsMainViewModel.BtnVoteStatus.INVISIBLE
    end

    if tasteInfo.tasteType == TasteType.SWEET and btnTaste == CheckinVsDefine.TasteChoice.SWEET then
      return CheckinVsMainViewModel.BtnVoteStatus.GAIN_REWARD
    end

    if tasteInfo.tasteType == TasteType.SALT and btnTaste == CheckinVsDefine.TasteChoice.SALTY then
      return CheckinVsMainViewModel.BtnVoteStatus.GAIN_REWARD
    end

    if tasteInfo.tasteType == TasteType.DRAW then
      if self.socialState == btnTaste then
        return CheckinVsMainViewModel.BtnVoteStatus.GAIN_REWARD
      end
    end

    return CheckinVsMainViewModel.BtnVoteStatus.INVISIBLE
  end

  if self.canVote then
    return CheckinVsMainViewModel.BtnVoteStatus.ACTIVE
  end

  if self.availSignCnt <= 0 then
    if self.todayVoteState == btnTaste then
      return CheckinVsMainViewModel.BtnVoteStatus.INACTIVE
    end
  end

  return CheckinVsMainViewModel.BtnVoteStatus.INVISIBLE
end


function CheckinVsMainViewModel:GetCurrentTasteInfo()
  if self.m_actData == nil or self.m_actData.voteTasteList == nil then
    return nil
  end

  local targetTasteData = nil
  for i = 0, self.m_actData.voteTasteList.Count-1 do
    local voteTasteData = self.m_actData.voteTasteList[i]
    if self.sweetVote == voteTasteData.plSweetNum and self.saltyVote == voteTasteData.plSaltyNum then
      targetTasteData = voteTasteData
      break
    end
  end

  if targetTasteData == nil then
    return nil
  end

  local suc, tasteInfoData = self.m_actData.tasteInfoDict:TryGetValue(targetTasteData.plTaste)
  if not suc then
    return nil
  end

  return tasteInfoData
end



function CheckinVsMainViewModel:GetDisplayRewardStatus()
  if self.availSignCnt <= 0 then
    return CheckinVsMainViewModel.RewardStatus.FINISH
  end
  
  if self.canVote == false and self.voteRewardState ~= CheckinVsDefine.VoteRewardStatus.ACTIVE then
    return CheckinVsMainViewModel.RewardStatus.ACTIVE
  end

  return CheckinVsMainViewModel.RewardStatus.NORMAL
end


function CheckinVsMainViewModel:GetTotalVoteDay()
  if self.m_actData == nil then
    return 0
  end
  return self.m_actData.versusTotalDays
end


function CheckinVsMainViewModel:GetEndTime()
  if self.m_basicInfo == nil then
    return 0
  end
  return self.m_basicInfo.endTime
end

return CheckinVsMainViewModel