local luaUtil = CS.Torappu.Lua.Util
local colorRes = CS.Torappu.ColorRes


























local ReturnV2MissionItem = Class("ReturnV2MissionItem", UIPanel)
local UICommonItemCard = require("Feature/Supportor/UI/UICommonItemCard")

function ReturnV2MissionItem:OnInit()
  self:AddButtonClickListener(self._btnMissionClick, self._OnMissionItemClick)
  self.m_missionRewardList = {}
  local rewardItemNum = tonumber(self._missionRewardItemNum)
  for idx = 1, rewardItemNum do 
    local itemCard = self:CreateWidgetByPrefab(UICommonItemCard, self._itemCardPrefab, self._rectMissionReward)
    table.insert(self.m_missionRewardList, itemCard)
  end
end





function ReturnV2MissionItem:Render(missionModel, isInListPanel, isEnd, canOpenMissionList)
  if missionModel == nil then
    return
  end
  self.m_missionState = missionModel.state
  self.m_groupId = missionModel.groupId
  self.m_canOpenMissionList = canOpenMissionList
  
  self._textMissionDesc.text = missionModel.missionDesc
  self._textMissionProgressLeft.text = missionModel.value
  self._textMissionProgressRight.text = string.format("/%d", missionModel.target)
  self._sliderMissionProgress.value = missionModel.progress

  local canClaim = missionModel.state == ReturnV2TaskState.TASK_CAN_CLAIM
  local haveClaimed = missionModel.state == ReturnV2TaskState.TASK_CLAIMED
  luaUtil.SetActiveIfNecessary(self._objInListBkg, isInListPanel)
  luaUtil.SetActiveIfNecessary(self._objCanClaimBkg, not isInListPanel and canClaim)
  luaUtil.SetActiveIfNecessary(self._objNormalBkg, not isInListPanel and not canClaim)
  luaUtil.SetActiveIfNecessary(self._objClaimedStyle, haveClaimed)
  self._graphicHotspot.raycastTarget = not isInListPanel
  SetGameObjectActive(self._objOpenDetail, not isInListPanel and canOpenMissionList)
  SetGameObjectActive(self._objDivideLine, isInListPanel and not isEnd)
  if missionModel.state == ReturnV2TaskState.TASK_CAN_CLAIM then
    self._imgOpenDetail.color = colorRes.TweenHtmlStringToColor(self._imgOpenDetailCanClaimColor)
  else
    self._imgOpenDetail.color = colorRes.TweenHtmlStringToColor(self._imgOpenDetailNormalColor)
  end

  local rewards = ToLuaArray(missionModel.rewardList)
  local rewardsNum = #rewards
  for idx = 1, rewardsNum do 
    local reward = rewards[idx]
    local itemCard = self.m_missionRewardList[idx]
    itemCard:Render(reward, {
      itemScale = tonumber(self._missionRewardItemCardScale),
      isCardClickable = true,
      showItemName = false,
      showItemNum = true,
      showBackground = true,
    });
    luaUtil.SetActiveIfNecessary(itemCard.gameObject, true)
  end
  for idx = rewardsNum+1, tonumber(self._missionRewardItemNum) do
    local itemCard = self.m_missionRewardList[idx]
    luaUtil.SetActiveIfNecessary(itemCard.gameObject, false)
  end
end

function ReturnV2MissionItem:_OnMissionItemClick()
  local canClaim = self.m_missionState == ReturnV2TaskState.TASK_CAN_CLAIM
  if canClaim and self.claimRewardClick then
    self.claimRewardClick:Call(self.m_groupId)
    return
  end
  if not canClaim and self.openMissionListPanelClick and self.m_canOpenMissionList then
    self.openMissionListPanelClick:Call()
    return
  end
end

return ReturnV2MissionItem