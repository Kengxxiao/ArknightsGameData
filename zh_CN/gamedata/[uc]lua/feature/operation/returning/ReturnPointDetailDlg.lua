









ReturnPointDetailDlg = DlgMgr.DefineDialog("ReturnPointDetailDlg", "Operation/[UC]Returning/return_point_detail_dlg");

local ReturnPointDetailLevelView = require("Feature/Operation/Returning/PointDetail/ReturnPointDetailLevelView");
local ReturnPointDetailRewardGroupView = require("Feature/Operation/Returning/PointDetail/ReturnPointDetailRewardGroupView");

function ReturnPointDetailDlg:OnInit()
  self.m_levelAdapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._levelContent,
      self._CreateLevelItemView, self._GetPointLevelCount, self._UpdateLevelItemView);
  self.m_rewardAdapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._rewardContent,
      self._CreateRewardItemView, self._GetPointLevelCount, self._UpdateRewardItemView);

  self:AddButtonClickListener(self._btnClose, self._EventOnCloseClicked);
  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnClose);
end


function ReturnPointDetailDlg:Render(model)
  if model == nil then
    return;
  end
  self._textPrice.text = model.returnPointDesc;
  self._textTip.text = model.returnPointLevelTip;
  self.m_pointModelList = model.pointList;
  self.m_levelAdapter:NotifyDataSetChanged();
  self.m_rewardAdapter:NotifyDataSetChanged();
end


function ReturnPointDetailDlg:_GetPointLevelCount()
  if self.m_pointModelList == nil then
    return 0;
  end
  return #self.m_pointModelList;
end



function ReturnPointDetailDlg:_CreateLevelItemView(gameObj)
  local itemView = self:CreateWidgetByGO(ReturnPointDetailLevelView, gameObj);
  return itemView;
end




function ReturnPointDetailDlg:_UpdateLevelItemView(index, view)
  view:Render(self.m_pointModelList[index + 1], index == 0);
end



function ReturnPointDetailDlg:_CreateRewardItemView(gameObj)
  local itemView = self:CreateWidgetByGO(ReturnPointDetailRewardGroupView, gameObj);
  if itemView ~= nil then
    itemView.createWidgetByGO = function(widgetCls, layout)
        return self:CreateWidgetByGO(widgetCls, layout);
      end;
  end
  return itemView;
end




function ReturnPointDetailDlg:_UpdateRewardItemView(index, view)
  view:Render(self.m_pointModelList[index + 1]);
end


function ReturnPointDetailDlg:_EventOnCloseClicked()
  self:Close();
end