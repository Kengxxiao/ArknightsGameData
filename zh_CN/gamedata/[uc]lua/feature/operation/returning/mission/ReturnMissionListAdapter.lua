







local ReturnMissionListAdapter = Class("ReturnMissionListAdapter", UIRecycleAdapterBase);

local ReturnMissionListItemView = require("Feature/Operation/Returning/Mission/ReturnMissionListItemView");

function ReturnMissionListAdapter:ViewConstructor(objPool)
  local missionItem = self:CreateWidgetByPrefab(ReturnMissionListItemView, self._itemPrefab, self._container);
  missionItem.createWidgetByGO = self.createWidgetByGO;
  missionItem.loadFunc = self.loadFunc;
  self:AddObj(missionItem, missionItem:RootGameObject());
  return missionItem:RootGameObject();
end

function ReturnMissionListAdapter:OnRender(transform, index)
  local luaIndex = index + 1;
  local item = self:GetWidget(transform.gameObject);
  item:Render(self.missionList[luaIndex]);
end


function ReturnMissionListAdapter:GetTotalCount()
  if self.missionList == nil then
    return 0;
  end
  return #self.missionList;
end

return ReturnMissionListAdapter;