














local ReturnCheckinView = Class("ReturnCheckinView", UIPanel);

local ReturnCheckinItemView = require("Feature/Operation/Returning/Checkin/ReturnCheckinItemView");
local ReturnCheckinProgressNodeView = require("Feature/Operation/Returning/Checkin/ReturnCheckinProgressNodeView");


function ReturnCheckinView:OnViewModelUpdate(data)
  if data == nil or data.checkinViewModel == nil then
    return;
  end
  self.m_viewModel = data.checkinViewModel;
  self.m_totalModel = data;
  self:_InitIfNot();
  self:_Render();
end


function ReturnCheckinView:_Render()
  self._titleText.text = self.m_viewModel.titleText;
  self._endTimeText.text = self.m_viewModel.finishDateTimeText;
  self._checkinDayText.text = tostring(self.m_viewModel.checkinDays);
  self._allOpenDayText.text = tostring(self.m_viewModel.allOpenDays);
  self.m_signListAdapter:NotifyDataSetChanged();
  self.m_progressAdapter:NotifyDataSetChanged();
  self._imgProgress.fillAmount = self.m_viewModel.fillAmount or 0;
end


function ReturnCheckinView:_InitIfNot()
  if self.m_hasInited then
    return;
  end
  self.m_hasInited = true;

  self.m_signListAdapter = self:CreateCustomComponent(
      UISimpleLayoutAdapter, self, self._itemList, self._CreateItemView,
      self._GetItemCount, self._UpdateItemView);
  self.m_progressAdapter = self:CreateCustomComponent(
      UISimpleLayoutAdapter, self, self._progressList, self._CreateProgressNodeView,
      self._GetProgressNodeCount, self._UpdateProgressNodeView);
end



function ReturnCheckinView:_CreateItemView(gameObj)
  local itemView = self:CreateWidgetByGO(ReturnCheckinItemView, gameObj);
  return itemView;
end



function ReturnCheckinView:_CreateProgressNodeView(gameObj)
  local progressNodeView = self:CreateWidgetByGO(ReturnCheckinProgressNodeView, gameObj);
  return progressNodeView;
end




function ReturnCheckinView:_UpdateItemView(index, itemView)
  local luaIndex = index + 1;
  local signList = self.m_viewModel.itemList;
  
  
  itemView:Render(luaIndex, signList[luaIndex], self.onItemClick);
end

function ReturnCheckinView:_UpdateProgressNodeView(index, progressNodeView)
  local luaIndex = index + 1;
  local itemList = self.m_viewModel.itemList;
  local length = self.m_viewModel.checkinDays or 1;
  local posX = 0;
  if length > 1 then
    posX = index / (length - 1);
  end

  local root = progressNodeView:RootGameObject();
  if root ~= nil then
    local rt = root:GetComponent("RectTransform");
    if rt ~= nil then
      rt.anchorMin = {x = posX, y = rt.anchorMin.y};
      rt.anchorMax = {x = posX, y = rt.anchorMax.y};
    end
  end

  progressNodeView:Render(itemList[luaIndex].state);
end


function ReturnCheckinView:_GetItemCount()
  return self.m_viewModel.checkinDays;
end

function ReturnCheckinView:_GetProgressNodeCount()
  return self.m_viewModel.checkinDays;
end

return ReturnCheckinView;