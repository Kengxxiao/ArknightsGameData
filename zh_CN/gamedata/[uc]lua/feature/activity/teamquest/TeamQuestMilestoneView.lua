local TeamQuestMilestoneListAdapter = require("Feature/Activity/TeamQuest/View/TeamQuestMilestoneListAdapter")
local TeamQuestGetAllBtnView = require("Feature/Activity/TeamQuest/View/TeamQuestGetAllBtnView")








local TeamQuestMilestoneView = Class("TeamQuestMilestoneView", UIPanel)



function TeamQuestMilestoneView:Init(onMilestoneItemClick, onBtnAllMilestoneClick)
  self.m_milestoneListAdapter = self:CreateCustomComponent(TeamQuestMilestoneListAdapter, self._milestoneListGO, self)
  self.m_milestoneListAdapter.onItemClick = onMilestoneItemClick

  self.onBtnAllMilestoneClick = onBtnAllMilestoneClick
  self.m_getAllBtnView = self:CreateWidgetByPrefab(TeamQuestGetAllBtnView, self._getAllBtnPrefab, self._getAllBtnContainer)
end


function TeamQuestMilestoneView:Render(viewModel)
  self.m_milestoneListAdapter:SetViewModel(viewModel)
  self.m_milestoneListAdapter:NotifyDataChanged()
  
  if self.m_getAllBtnView ~= nil then
    local hasMilestoneAvail = viewModel:HasMilestoneAvail()
    self.m_getAllBtnView:Render(hasMilestoneAvail, viewModel.themeColor, self.onBtnAllMilestoneClick)
  end
end


return TeamQuestMilestoneView