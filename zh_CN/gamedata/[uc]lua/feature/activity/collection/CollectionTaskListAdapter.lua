






local CollectionTaskListAdapter = Class("CollectionTaskListAdapter", UIRecycleAdapterBase);
local CollectionTimedTaskItem = require("Feature/Activity/Collection/CollectionTimedTaskItem");

function CollectionTaskListAdapter:ViewConstructor(objPool)
  local missionItem = self:CreateWidgetByPrefab(CollectionTimedTaskItem, self._itemPrefab, self._container);
  self:AddObj(missionItem, missionItem:RootGameObject());  
  return missionItem:RootGameObject();
end

function CollectionTaskListAdapter:OnRender(transform, index)
  if #self.missionList <= 0 then
    return;
  end 
  
  local luaIndex = index + 1;
  local missionData = self.missionList[luaIndex];
  local item = self:GetWidget(transform.gameObject);
  item:Refresh(missionData, self.actCfg);
end


function CollectionTaskListAdapter:GetTotalCount()
  if self.missionList == nil then
    return 0;
  end
  return #self.missionList;
end

return CollectionTaskListAdapter;