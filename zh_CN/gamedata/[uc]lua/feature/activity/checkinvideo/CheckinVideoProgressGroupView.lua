






local CheckinVideoProgressGroupView = Class("CheckinVideoProgressGroupView", UIPanel);

local CheckinVideoProgressItemView = require("Feature/Activity/CheckinVideo/CheckinVideoProgressItemView");

function CheckinVideoProgressGroupView:OnInit()
  self.m_progressAdapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._progressContent,
      self._CreateProgressItem, self._GetRewardCount, self._UpdateProgressItem);
end


function CheckinVideoProgressGroupView:OnViewModelUpdate(data)
  if data == nil then
    return;
  end
  self.m_cachedIndex = data.currFocusItem;
  self.m_cachedItemList = data.itemList;
  self.m_cachedEnter = data.isEnter;
  
  if self.m_progressAdapter ~= nil then
    self.m_progressAdapter:NotifyDataSetChanged();
  end
end



function CheckinVideoProgressGroupView:_CreateProgressItem(gameObj)
  local itemView = self:CreateWidgetByGO(CheckinVideoProgressItemView, gameObj);
  return itemView;
end


function CheckinVideoProgressGroupView:_GetRewardCount()
  if self.m_cachedItemList == nil then
    return 0;
  end
  return #self.m_cachedItemList;
end



function CheckinVideoProgressGroupView:_UpdateProgressItem(index, view)
  if view == nil then
    return;
  end
  local idx = index + 1;
  view:Render(self.m_cachedItemList[idx], idx == self.m_cachedIndex, self.m_cachedEnter);
end

return CheckinVideoProgressGroupView;