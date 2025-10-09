local TeamQuestMissionItemView = require("Feature/Activity/TeamQuest/View/TeamQuestMissionItemView")






local TeamQuestMissionListAdapter = Class("TeamQuestMissionListAdapter", UIRecycleAdapterBase)



function TeamQuestMissionListAdapter:SetViewModel(viewModel)
  self.m_viewModel = viewModel
end



function TeamQuestMissionListAdapter:ViewConstructor(objPool)
  
  local itemView = self:CreateWidgetByPrefab(TeamQuestMissionItemView, self._itemPrefab, self._container)
  itemView.onItemClick = self.onItemClick
  local rootGo = itemView:RootGameObject()
  self:AddObj(itemView, rootGo)
  return rootGo
end




function TeamQuestMissionListAdapter:OnRender(transform, index)
  
  local item = self:GetWidget(transform.gameObject)
  local luaIndex = index + 1
  local missionModel = self.m_viewModel.missionList[luaIndex]
  local themeColor = self.m_viewModel.themeColor
  item:Render(missionModel, themeColor, self.m_viewModel:IsInTeam())
end


function TeamQuestMissionListAdapter:GetTotalCount()
  if self.m_viewModel == nil then
    return 0
  end
  return #self.m_viewModel.missionList
end

return TeamQuestMissionListAdapter