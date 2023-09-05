





local MainlineBpBpLimitAdapter = Class("MainlineBpMissionAdapter", UIRecycleAdapterBase)
local MainlineBpBpLimitItemView = require("Feature/Activity/MainlineBp/MainlineBpBpLimitItemView");

function MainlineBpBpLimitAdapter:ViewConstructor(objPool)
  local rewardItem = self:CreateWidgetByPrefab(MainlineBpBpLimitItemView, self._itemPrefab, self._container);
  rewardItem.onRewardClaimClicked = self.onRewardClaimClicked;
  self:AddObj(rewardItem, rewardItem:RootGameObject());
  return rewardItem:RootGameObject();
end

function MainlineBpBpLimitAdapter:OnRender(transform, index)
  local luaIndex = index + 1;
  local item = self:GetWidget(transform.gameObject);
  item:Render(self.rewardList[luaIndex]);
end


function MainlineBpBpLimitAdapter:GetTotalCount()
  if self.rewardList == nil then
    return 0;
  end
  return #self.rewardList;
end

return MainlineBpBpLimitAdapter;