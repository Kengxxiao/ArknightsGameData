local luaUtils = CS.Torappu.Lua.Util;
















local CheckinAccessMainView = Class("CheckinAccessMainView", UIPanel);

local CheckinAccessRewardItemView = require("Feature/Activity/CheckinAccess/CheckinAccessRewardItemView");


function CheckinAccessMainView:OnViewModelUpdate(data)
  self:_InitIfNot();
  if data == nil then
    return;
  end

  luaUtils.SetActiveIfNecessary(self._panelBtnCheckin, data.status == CheckinAccessStatus.CAN_CONFIRM);
  luaUtils.SetActiveIfNecessary(self._panelAlreadyCheckin, data.status == CheckinAccessStatus.CONFIRMED);
  luaUtils.SetActiveIfNecessary(self._panelAllCheckin, data.status == CheckinAccessStatus.ALL_CONFIRMED);

  self._textApSupplyTime.text = data.apSupplyTip;
  self._textActTime.text = data.actTimeTip;
  self._textRewardTip.text = data.rewardItemTip;
  self._textCurrTimesTip.text = data.confirmedTimesTip;
  self._textTotalTimesTip.text = data.totalTimesTip;
  self._imgTotalTimesBkg.color = data.totalTimesBkgColor;

  self.m_rewardList = data.itemList;
  self.m_hasConfirmed = data.status == CheckinAccessStatus.ALL_CONFIRMED or
                        data.status == CheckinAccessStatus.CONFIRMED;
  self.m_adapter:NotifyDataSetChanged();
end




function CheckinAccessMainView:_CreateRewardItem(gameObj)
  local item = self:CreateWidgetByGO(CheckinAccessRewardItemView, gameObj);
  item.createWidgetByPrefab = function(widgetCls, layout, parent)
    return self:CreateWidgetByPrefab(widgetCls, layout, parent);
  end
  return item;
end



function CheckinAccessMainView:_GetRewardCount()
  if self.m_rewardList == nil then
    return 0;
  end
  return #self.m_rewardList;
end




function CheckinAccessMainView:_RenderItemView(index, item)
  local idx = index + 1;
  item:Render(self.m_rewardList[idx], self.m_hasConfirmed);
end


function CheckinAccessMainView:_InitIfNot()
  if self.m_hasInited then
    return;
  end
  self.m_hasInited = true;
  self.m_adapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._content,
      self._CreateRewardItem, self._GetRewardCount, self._RenderItemView);
end

return CheckinAccessMainView;