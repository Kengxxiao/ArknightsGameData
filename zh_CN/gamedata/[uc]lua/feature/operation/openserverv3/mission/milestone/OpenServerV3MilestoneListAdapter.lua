





local OpenServerV3MilestoneListAdapter = Class("OpenServerV3MilestoneListAdapter", UIRecycleAdapterBase);

local OpenServerV3MilestoneItemView = require(
    "Feature/Operation/OpenServerV3/Mission/Milestone/OpenServerV3MilestoneItemView");



function OpenServerV3MilestoneListAdapter:ViewConstructor(objPool)
  local itemView = self:CreateWidgetByPrefab(OpenServerV3MilestoneItemView, self._itemPrefab, self._container);
  if itemView == nil then
    return nil;
  end
  itemView.createWidgetByGO = self.createWidgetByGO;
  itemView.onItemClicked = self.onItemClicked;
  self:AddObj(itemView, itemView:RootGameObject());
  return itemView:RootGameObject();
end



function OpenServerV3MilestoneListAdapter:OnRender(transform, index)
  local itemView = self:GetWidget(transform.gameObject);
  if itemView == nil then
    return;
  end
  itemView.createWidgetByGO = self.createWidgetByGO;
  itemView.onItemClicked = self.onItemClicked;
  itemView:Render(self.itemList[index + 1]);
end


function OpenServerV3MilestoneListAdapter:GetTotalCount()
  if self.itemList == nil then
    return 0;
  end
  return #self.itemList;
end

return OpenServerV3MilestoneListAdapter;
