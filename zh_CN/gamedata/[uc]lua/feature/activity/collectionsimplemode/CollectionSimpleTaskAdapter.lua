






local CollectionSimpleTaskAdapter = Class("CollectionSimpleTaskAdapter", UIRecycleAdapterBase)
local CollectionSimpleTaskView = require("Feature/Activity/CollectionSimpleMode/CollectionSimpleTaskView")

function CollectionSimpleTaskAdapter:ViewConstructor(objPool)
  
  local taskItem = self:CreateWidgetByPrefab(CollectionSimpleTaskView, self._itemPrefab, self._container);
  taskItem.onMissionClaimed = self.onMissionClaimed;
  self:AddObj(taskItem, taskItem:RootGameObject());
  return taskItem:RootGameObject();
end

function CollectionSimpleTaskAdapter:OnRender(transform, index)
  local luaIndex = index + 1;
  
  local item = self:GetWidget(transform.gameObject);
  item:Render(self.taskModelList[luaIndex], self.isAllRewardClaimed);
end


function CollectionSimpleTaskAdapter:GetTotalCount()
  if self.taskModelList == nil then
    return 0;
  end
  return #self.taskModelList;
end


function CollectionSimpleTaskAdapter:_EventOnMissionClaimed(missionId)
  if not self.onMissionClaimed or not missionId then
    return
  end
  Event.Call(self.onMissionClaimed, missionId)
end

return CollectionSimpleTaskAdapter