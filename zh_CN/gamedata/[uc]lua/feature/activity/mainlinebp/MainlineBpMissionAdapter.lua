








local MainlineBpMissionAdapter = Class("MainlineBpMissionAdapter", UIRecycleAdapterBase);
local MainlineBpMissionItemView = require("Feature/Activity/MainlineBp/MainlineBpMissionItemView");

function MainlineBpMissionAdapter:ViewConstructor(objPool)
  local missionItem = self:CreateWidgetByPrefab(MainlineBpMissionItemView, self._itemPrefab, self._container);
  missionItem.loadDynImage = self.loadDynImage;
  missionItem.onMissionClicked = self.onMissionClicked;
  missionItem.onJumpToZoneClicked = self.onJumpToZoneClicked;
  self:AddObj(missionItem, missionItem:RootGameObject());
  return missionItem:RootGameObject();
end

function MainlineBpMissionAdapter:OnRender(transform, index)
  local luaIndex = index + 1;
  local item = self:GetWidget(transform.gameObject);
  item:Render(self.missionList[luaIndex], self.m_actId);
end


function MainlineBpMissionAdapter:GetTotalCount()
  if self.missionList == nil then
    return 0;
  end
  return #self.missionList;
end

return MainlineBpMissionAdapter;