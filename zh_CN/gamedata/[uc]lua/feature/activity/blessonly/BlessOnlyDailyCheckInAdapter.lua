




local BlessOnlyDailyCheckInAdapter = Class("BlessOnlyDailyCheckInAdapter", UIRecycleAdapterBase);
local BlessOnlyDailyCheckInItemView = require("Feature/Activity/BlessOnly/BlessOnlyDailyCheckInItemView");

function BlessOnlyDailyCheckInAdapter:ViewConstructor(objPool)
  local checkInItem = self:CreateWidgetByPrefab(BlessOnlyDailyCheckInItemView, self._itemPrefab, self._container);
  self:AddObj(checkInItem, checkInItem:RootGameObject());
  checkInItem.onClickReceiveReward = self.onClickReceiveReward;
  return checkInItem:RootGameObject();
end

function BlessOnlyDailyCheckInAdapter:OnRender(transform, index)
  local luaIndex = index + 1;
  local item = self:GetWidget(transform.gameObject);
  item:Render(self.dailyCheckInModelList[luaIndex]);
end

function BlessOnlyDailyCheckInAdapter:InitEventFunc()
  checkInItem.onClickReceiveReward = self.onClickReceiveReward;
end


function BlessOnlyDailyCheckInAdapter:GetTotalCount()
  if self.dailyCheckInModelList == nil then
    return 0;
  end
  return #self.dailyCheckInModelList;
end

return BlessOnlyDailyCheckInAdapter;