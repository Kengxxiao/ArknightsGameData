local luaUtils = CS.Torappu.Lua.Util;
local FadeSwitchTween = CS.Torappu.UI.FadeSwitchTween;












local MainlineBpBpUpDetailView = Class("MainlineBpBpUpDetailView", UIPanel);

local MainlineBpBpUpDetailItemView = require("Feature/Activity/MainlineBp/MainlineBpBpUpDetailItemView");

function MainlineBpBpUpDetailView:OnInit()
  self:AddButtonClickListener(self._btnClose, self._OnCloseBtnClicked);

  self.m_adapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._contentItem, 
      self._CreateUpDetailItem, self._GetItemCount, self._RenderItemView);

  self.m_switchTween = FadeSwitchTween(self._canvasSelf, tonumber(self._floatTweenDur));
  self.m_switchTween:Reset(false);
end


function MainlineBpBpUpDetailView:OnViewModelUpdate(data)
  if data == nil then
    return;
  end
  self.m_switchTween.isShow = data.showBpUpDetailPanel;
  self.m_cachedDataList = data.bpUpDescModelList;
  self.m_adapter:NotifyDataSetChanged();
end



function MainlineBpBpUpDetailView:_CreateUpDetailItem(gameObj)
  local itemView = self:CreateWidgetByGO(MainlineBpBpUpDetailItemView, gameObj);
  return itemView;
end



function MainlineBpBpUpDetailView:_GetItemCount()
  if self.m_cachedDataList == nil then
    return 0;
  end
  return #self.m_cachedDataList;
end




function MainlineBpBpUpDetailView:_RenderItemView(index, itemView)
  itemView:Render(self.m_cachedDataList[index + 1]);
end


function MainlineBpBpUpDetailView:_OnCloseBtnClicked()
  if self.onCloseBtnClick == nil then
    return;
  end
  Event.Call(self.onCloseBtnClick);
end

return MainlineBpBpUpDetailView;