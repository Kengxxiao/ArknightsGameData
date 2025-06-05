local luaUtils = CS.Torappu.Lua.Util









local CollectionSimpleTaskListView = Class("CollectionSimpleTaskListView", UIPanel)
local CollectionSimpleTaskAdapter = require("Feature/Activity/CollectionSimpleMode/CollectionSimpleTaskAdapter")
local CollectionSimpleTaskClaimAllView = require("Feature/Activity/CollectionSimpleMode/CollectionSimpleTaskClaimAllView")

function CollectionSimpleTaskListView:OnInit()
  if self._missionAdapter then
    self.m_missionAdapter = self:CreateCustomComponent(CollectionSimpleTaskAdapter, self._missionAdapter, self)
  end
  if self._confirmAllMissionView then
    self.m_confirmAllMissionView = self:CreateWidgetByGO(CollectionSimpleTaskClaimAllView, self._confirmAllMissionView)
  end
end

function CollectionSimpleTaskListView:InitEventFunc()
  if self.m_missionAdapter then
    self.m_missionAdapter.onMissionClaimed = self.onMissionItemClaimed
  end
  if self.m_confirmAllMissionView then
    self.m_confirmAllMissionView.onClaimAllClicked = self.onClaimAllClicked
  end
end


function CollectionSimpleTaskListView:Render(model)
  if not model or not model.taskListViewModel or not model.rewardViewModel then
    return
  end

  local hasAllRewardClaimed = model.rewardViewModel.claimedRewardCount >= model.rewardViewModel.totalRewardCount
  luaUtils.SetActiveIfNecessary(self._blockClickMask, hasAllRewardClaimed)
  self.m_missionAdapter.taskModelList = model.taskListViewModel.missionItemList
  self.m_missionAdapter.isAllRewardClaimed = hasAllRewardClaimed
  self.m_missionAdapter:NotifyDataSourceChanged()
  self.m_confirmAllMissionView:Render(model.taskListViewModel, hasAllRewardClaimed)
  local themeColor = model.rewardViewModel.themeColor
  self._themeColorScrollBar.color = themeColor
end

return CollectionSimpleTaskListView