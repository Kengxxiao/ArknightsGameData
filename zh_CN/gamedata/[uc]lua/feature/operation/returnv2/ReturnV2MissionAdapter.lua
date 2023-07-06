



local ReturnV2MissionAdapter = Class("ReturnV2MissionAdapter", UIRecycleAdapterBase)
local ReturnV2MissionItem = require("Feature/Operation/ReturnV2/ReturnV2MissionItem")

function ReturnV2MissionAdapter:ViewConstructor(objPool)
  local missionItem = self:CreateWidgetByPrefab(ReturnV2MissionItem, self._itemPrefab, self._container);
  self:AddObj(missionItem, missionItem:RootGameObject())
  return missionItem:RootGameObject();
end

function ReturnV2MissionAdapter:OnRender(transform, index)
  local luaIndex = index + 1
  local item = self:GetWidget(transform.gameObject);
  item:Render(self.missionList[luaIndex], true, luaIndex == #self.missionList, false);
end

function ReturnV2MissionAdapter:GetTotalCount()
  local num = #self.missionList
  return num
end

return ReturnV2MissionAdapter