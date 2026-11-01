






local OpenServerV3MissionTaskListAdapter = Class("OpenServerV3MissionTaskListAdapter", UIRecycleAdapterBase);

local OpenServerV3MissionTaskItemView = require("Feature/Operation/OpenServerV3/Mission/OpenServerV3MissionTaskItemView");

function OpenServerV3MissionTaskListAdapter:ViewConstructor(objPool)
  local itemView = self:CreateWidgetByPrefab(OpenServerV3MissionTaskItemView, self._itemPrefab, self._container);
  if itemView == nil then
    return nil;
  end
  itemView.createWidgetByGO = self.createWidgetByGO;
  itemView.onTaskClicked = self.onTaskClicked;
  itemView.onTaskJumpClicked = self.onTaskJumpClicked;
  self:AddObj(itemView, itemView:RootGameObject());
  return itemView:RootGameObject();
end

function OpenServerV3MissionTaskListAdapter:OnRender(transform, index)
  local luaIndex = index + 1;
  local itemView = self:GetWidget(transform.gameObject);
  if itemView ~= nil then
    itemView.createWidgetByGO = self.createWidgetByGO;
    itemView.onTaskClicked = self.onTaskClicked;
    itemView.onTaskJumpClicked = self.onTaskJumpClicked;
    itemView:Render(self.missionList[luaIndex]);
  end
end


function OpenServerV3MissionTaskListAdapter:GetTotalCount()
  if self.missionList == nil then
    return 0;
  end
  return #self.missionList;
end

return OpenServerV3MissionTaskListAdapter;
