






local TeamQuestMilestoneViewModel = Class("TeamQuestMilestoneViewModel", nil)


function TeamQuestMilestoneViewModel:InitData(milestoneData)
  self.id = milestoneData.id
  self.level = milestoneData.level
  self.needPointCnt = milestoneData.needPointCnt
  self.isBetterShow = milestoneData.isBetterShow

  if milestoneData.rewardItem ~= nil then
    local rewardItemData = milestoneData.rewardItem
    local itemModel = CS.Torappu.UI.UIItemViewModel()
    itemModel:LoadGameData(rewardItemData.id, rewardItemData.type)
    itemModel.itemCount = rewardItemData.count
    self.itemModel = itemModel
  end
end


function TeamQuestMilestoneViewModel:RefreshPlayerData(playerActData)
  self.statusType = self:_CalcStatusType(playerActData)
end



function TeamQuestMilestoneViewModel:_CalcStatusType(playerActData)
  if playerActData == nil or playerActData.milestone == nil then
    return TeamQuestMilestoneStatusType.UNCOMPLETE
  end

  if self.needPointCnt > playerActData.milestone.point then
    return TeamQuestMilestoneStatusType.UNCOMPLETE
  end

  for _, milestoneId in ipairs(playerActData.milestone.got) do
    if milestoneId == self.id then
      return TeamQuestMilestoneStatusType.COMPLETE
    end
  end
  return TeamQuestMilestoneStatusType.AVAIL
end

return TeamQuestMilestoneViewModel