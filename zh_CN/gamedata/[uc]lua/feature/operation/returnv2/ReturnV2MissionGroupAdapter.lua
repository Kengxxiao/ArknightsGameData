






local ReturnV2MissionGroupAdapter = Class("ReturnV2MissionGroupAdapter", UIRecycleAdapterBase)
local ReturnV2MissionGroupItem = require("Feature/Operation/ReturnV2/ReturnV2MissionGroupItem")

function ReturnV2MissionGroupAdapter:ViewConstructor(objPool)
  local groupTabItem = self:CreateWidgetByPrefab(ReturnV2MissionGroupItem, self._itemPrefab, self._container);
  groupTabItem.clickEvent = self.clickEvent
  groupTabItem.loadSpriteFunc = self.loadSpriteFunc
  self:AddObj(groupTabItem, groupTabItem:RootGameObject())
  return groupTabItem:RootGameObject();
end

function ReturnV2MissionGroupAdapter:OnRender(transform, index)
  local item = self:GetWidget(transform.gameObject);
  item:Render(self.missionGroupList[index+1], self.activeMissionGroupId);
end

function ReturnV2MissionGroupAdapter:GetTotalCount()
  local num = #self.missionGroupList
  return num
end

return ReturnV2MissionGroupAdapter