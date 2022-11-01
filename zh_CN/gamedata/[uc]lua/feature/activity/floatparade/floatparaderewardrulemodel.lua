local eutil = CS.Torappu.Lua.Util









local FloatParadeRewardGroupModel = Class("FloatParadeRewardGroupModel")

function FloatParadeRewardGroupModel:HasExtReward()
  return self.extRewardCnt > 0 and self.extRewardDay >= 0
end




function FloatParadeRewardGroupModel.LoadGroupRewardList(groupId, actData)
  if not actData or not groupId then
    return {}
  end
  local suc, pools = actData.rewardPools:TryGetValue(groupId)
  if not suc then
    eutil.LogError("Failed to load reward pool: ".. groupId)
    return {}
  end
  local rewardList = {}
  for id, pool in pairs(pools) do
    local reward = {
      count = 0,
      desc = pool.desc
    }
    if pool.reward ~= nil then
      reward.count = pool.reward.count
    end
    table.insert(rewardList, reward)
  end
  return rewardList
end




local FloatParadeRewardRuleModel = Class("FloatParadeRewardRuleModel")




function FloatParadeRewardRuleModel:Init(actId, curDayIndex)
  local suc, actData = CS.Torappu.ActivityDB.data.activity.floatParadeData:TryGetValue(actId)
  if not suc then
    return false
  end
  local groupInfos = actData.groupInfos
  
  local groupModelList = {}
  for id, groupData in pairs(groupInfos) do 
    local groupModel = FloatParadeRewardGroupModel.new()

    
    groupModel.groupId = groupData.groupId
    groupModel.rewardList = FloatParadeRewardGroupModel.LoadGroupRewardList(groupData.groupId, actData)
    groupModel.name = groupData.name
    groupModel.extRewardDay = groupData.extRewardDay
    groupModel.extRewardCnt = groupData.extRewardCount
    groupModel.startDay = groupData.startDay
    groupModel.endDay = groupData.endDay

    table.insert(groupModelList, groupModel)
  end
  
  table.sort(groupModelList, function(lhs, rhs)
    return lhs.startDay < rhs.startDay
  end)
  self.groupList = groupModelList
  
  local curDayNum = curDayIndex + 1 
  self.focusGroupIdx = 1
  for i, groupModel in ipairs(groupModelList) do
    if curDayNum >= groupModel.startDay and curDayNum <= groupModel.endDay then
      self.focusGroupIdx = i
      break
    end
  end

  
  return true
end


function FloatParadeRewardRuleModel:CalcFocusProgress(countPerScreen)
  if not self.groupList then
    return 0
  end
  local totalCount = #self.groupList - countPerScreen
  if totalCount <= 1 or self.focusGroupIdx <= 1 then
    return 0
  end
  return (self.focusGroupIdx - 1) / totalCount
end

FloatParadeRewardRuleModel.GroupModel = FloatParadeRewardGroupModel

return FloatParadeRewardRuleModel