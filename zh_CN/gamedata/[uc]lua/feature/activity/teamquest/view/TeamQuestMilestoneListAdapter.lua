local TeamQuestMilestoneItemView = require("Feature/Activity/TeamQuest/View/TeamQuestMilestoneItemView")






local TeamQuestMilestoneListAdapter = Class("TeamQuestMilestoneListAdapter", UIRecycleAdapterBase)



function TeamQuestMilestoneListAdapter:SetViewModel(viewModel)
  self.m_viewModel = viewModel
end



function TeamQuestMilestoneListAdapter:ViewConstructor(objPool)
  local itemView = self:CreateWidgetByPrefab(TeamQuestMilestoneItemView, self._itemPrefab, self._container)
  itemView.onItemClick = self.onItemClick
  local rootGo = itemView:RootGameObject()
  self:AddObj(itemView, rootGo)
  return rootGo
end




function TeamQuestMilestoneListAdapter:OnRender(transform, index)
  
  local item = self:GetWidget(transform.gameObject)
  local luaIndex = index + 1
  local milestoneModel = self.m_viewModel.milestoneList[luaIndex]
  local themeColor = self.m_viewModel.themeColor
  item:Render(milestoneModel, themeColor)
end


function TeamQuestMilestoneListAdapter:GetTotalCount()
  if self.m_viewModel == nil then
    return 0
  end
  return #self.m_viewModel.milestoneList
end

return TeamQuestMilestoneListAdapter