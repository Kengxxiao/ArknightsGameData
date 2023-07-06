



local ReturnV2CheckinRewardModel = Class("ReturnV2CheckinRewardModel")

ReturnV2CheckinRewardModel.SIGN_REWARD_STATE = {
  INCOMING = 1,
  CAN_GAIN = 2,
  GAINED = 3,
}

function ReturnV2CheckinRewardModel:InitData(index, rewardData)
  self.m_rewardIndex = index
  self.m_rewardData = rewardData
end



function ReturnV2CheckinRewardModel:UpdatePlayerData(playerCheckin)
  self.m_state = self:_CalcCompleteStatus(playerCheckin)
end


function ReturnV2CheckinRewardModel:GetState()
  return self.m_state
end


function ReturnV2CheckinRewardModel:GetItemIdx()
  return self.m_rewardIndex
end



function ReturnV2CheckinRewardModel:_CalcCompleteStatus(playerCheckin)
  if playerCheckin == nil or playerCheckin.history == nil then
    return self.SIGN_REWARD_STATE.INCOMING
  end

  local signCnt = playerCheckin.history.Count
  if self.m_rewardIndex >= signCnt then
    return self.SIGN_REWARD_STATE.INCOMING
  end

  local canGain = playerCheckin.history[self.m_rewardIndex] == 1
  if canGain then
    return self.SIGN_REWARD_STATE.CAN_GAIN
  else
    return self.SIGN_REWARD_STATE.GAINED
  end
end


function ReturnV2CheckinRewardModel:GetSortId()
  if self.m_rewardData == nil then
    return 0
  end
  return self.m_rewardData.sortId
end


function ReturnV2CheckinRewardModel:IsImportant()
  if self.m_rewardData == nil then
    return false
  end
  return self.m_rewardData.isImportant
end


function ReturnV2CheckinRewardModel:GetRewardList()
  if self.m_rewardData == nil then
    return nil
  end
  return self.m_rewardData.rewardList
end

return ReturnV2CheckinRewardModel