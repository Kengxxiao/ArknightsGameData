local TeamQuestMissionListAdapter = require("Feature/Activity/TeamQuest/View/TeamQuestMissionListAdapter")
local TeamQuestGetAllBtnView = require("Feature/Activity/TeamQuest/View/TeamQuestGetAllBtnView")








local TeamQuestMissionView = Class("TeamQuestMissionView", UIPanel)



function TeamQuestMissionView:Init(onMissionItemClick, onBtnAllClick)
  self.m_missionListAdapter = self:CreateCustomComponent(TeamQuestMissionListAdapter, self._missionListGO, self)
  self.m_missionListAdapter.onItemClick = onMissionItemClick

  self.onBtnAllClick = onBtnAllClick
  self.m_getAllBtnView = self:CreateWidgetByPrefab(TeamQuestGetAllBtnView, self._getAllBtnPrefab, self._getAllBtnContainer)
end


function TeamQuestMissionView:Render(viewModel)
  self.m_missionListAdapter:SetViewModel(viewModel)
  self.m_missionListAdapter:NotifyDataChanged()
  
  if self.m_getAllBtnView ~= nil then
    local hasMilestoneAvail = viewModel:HasMissionAvail()
    self.m_getAllBtnView:Render(hasMilestoneAvail, viewModel.themeColor, self.onBtnAllClick)
  end
end

return TeamQuestMissionView