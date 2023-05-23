




FloatParadeRecycleDayListAdapter = Class("FloatParadeRecycleDayListAdapter", UIRecycleAdapterBase);

function FloatParadeRecycleDayListAdapter:ViewConstructor(objPool)
  local dayItem = self:CreateWidgetByPrefab(FloatParadeRecycleDayListAdapter.FloatParadeDayItem, self._itemPrefab, self._container);
  dayItem.clickEvent = self.clickEvent;
  self:AddObj(dayItem, dayItem:RootGameObject())
  return dayItem:RootGameObject();
end

function FloatParadeRecycleDayListAdapter:OnRender(transform, index)
  
  local item = self:GetWidget(transform.gameObject);
  item:Render(self.dayList[index+1]);
end

function FloatParadeRecycleDayListAdapter:GetTotalCount()
  return #self.dayList;
end

function FloatParadeRecycleDayListAdapter:GetItemHeight()
  local grid = self._container:GetComponent("UnityEngine.UI.GridLayoutGroup");
  local itemHeight = 76;
  if grid then
    itemHeight = grid.cellSize.y;
  end
  return itemHeight;
end














local FloatParadeDayItem = Class("FloatParadeDayItem", UIWidget);

function FloatParadeDayItem:OnInitialize()
  self:AddButtonClickListener(self._btnClick, FloatParadeDayItem._HandleClick);
end


function FloatParadeDayItem:Render(data)
  local luaUtil = CS.Torappu.Lua.Util;
  luaUtil.SetActiveIfNecessary( self._clearNode, data.dayIndex < data.currIndex);
  luaUtil.SetActiveIfNecessary(self._currentNode, data.dayIndex == data.currIndex);
  luaUtil.SetActiveIfNecessary(self._futureNode, data.dayIndex > data.currIndex);
  if data.dayIndex == data.currIndex then
    local currDayContent = "DAY " .. data.dayIndex +1;
    self._currLabel.text = currDayContent;
    self._currLabel2.text = currDayContent;
    luaUtil.SetActiveIfNecessary(self._currCompleteNode, not data.canRaffleToday);
    luaUtil.SetActiveIfNecessary(self._currUncompleteNode, data.canRaffleToday);
  end
  self._name.text = data.dayName;
  luaUtil.SetActiveIfNecessary(self._extFlag, data.hasExt and data.dayIndex >= data.currIndex );
end

function FloatParadeDayItem:_HandleClick()
  if self.clickEvent then
    self.clickEvent:Call();
  end
end
FloatParadeRecycleDayListAdapter.FloatParadeDayItem = FloatParadeDayItem;







local FloatParadeDayModel = Class("FloatParadeDayModel");
function FloatParadeDayModel:ctor()
  self.dayIndex = 0;
  self.dayName = "";
  self.currIndex = 0;
  self.hasExt = false;
  self.canRaffleToday = true;
end
FloatParadeRecycleDayListAdapter.FloatParadeDayModel = FloatParadeDayModel;


