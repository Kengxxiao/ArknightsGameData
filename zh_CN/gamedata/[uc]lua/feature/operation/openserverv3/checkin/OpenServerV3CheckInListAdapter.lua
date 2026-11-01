local OpenServerV3CheckInItemView = require("Feature/Operation/OpenServerV3/CheckIn/OpenServerV3CheckInItemView");







local OpenServerV3CheckInListAdapter = Class("OpenServerV3CheckInListAdapter", UIRecycleAdapterBase);



function OpenServerV3CheckInListAdapter:ViewConstructor(objPool)
  
  local itemView = self:CreateWidgetByPrefab(OpenServerV3CheckInItemView, self._itemPrefab, self._container);
  local rootGo = itemView:RootGameObject();
  self:AddObj(itemView, rootGo);
  return rootGo;
end



function OpenServerV3CheckInListAdapter:OnRender(transform, index)
  
  local item = self:GetWidget(transform.gameObject);
  if item == nil or self.viewModel == nil or self.viewModel.itemList == nil then
    return;
  end
  local luaIndex = index + 1;
  local itemModel = self.viewModel.itemList[luaIndex];
  if itemModel == nil then
    return;
  end
  item:Render(luaIndex, itemModel, self.onItemClick);
end


function OpenServerV3CheckInListAdapter:GetTotalCount()
  if self.viewModel == nil or self.viewModel.itemList == nil then
    return 0;
  end
  return #self.viewModel.itemList;
end

return OpenServerV3CheckInListAdapter;
