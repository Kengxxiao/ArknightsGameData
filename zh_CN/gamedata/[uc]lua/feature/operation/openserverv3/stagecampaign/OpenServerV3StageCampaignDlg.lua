local luaUtils = CS.Torappu.Lua.Util;







OpenServerV3StageCampaignDlg = DlgMgr.DefineDialog("OpenServerV3StageCampaignDlg", "Operation/[UC]OpenServerV3/OpenServerV3Campaign/open_server_v3_stage_campaign_dlg", DlgBase);

local OpenServerV3StageCampaignItemView = require("Feature/Operation/OpenServerV3/StageCampaign/OpenServerV3StageCampaignItemView");

function OpenServerV3StageCampaignDlg:OnInit()
  self:AddButtonClickListener(self._btnClose, self._EventOnCloseBtnClicked);

  self.m_viewModel = self:CreateViewModel(OpenServerV3StageCampaignDlgViewModel);
  self.m_viewModel:LoadData();

  self.m_stageAdapter = self:CreateCustomComponent(
      UISimpleLayoutAdapter, self, self._content,
      self._CreateItemView, self._GetItemCount, self._UpdateItemView);
  self.m_stageAdapter:NotifyDataSetChanged();
end



function OpenServerV3StageCampaignDlg:_CreateItemView(gameObj)
  local itemView = self:CreateWidgetByGO(OpenServerV3StageCampaignItemView, gameObj);
  itemView.createWidgetByGO = function(widgetCls, layout)
    return self:CreateWidgetByGO(widgetCls, layout);
  end
  return itemView;
end


function OpenServerV3StageCampaignDlg:_GetItemCount()
  if self.m_viewModel == nil or self.m_viewModel.stageList == nil then
    return 0;
  end
  return #self.m_viewModel.stageList;
end



function OpenServerV3StageCampaignDlg:_UpdateItemView(index, itemView)
  if self.m_viewModel == nil or self.m_viewModel.stageList == nil then
    return;
  end
  local luaIndex = index + 1;
  local itemModel = self.m_viewModel.stageList[luaIndex];
  if itemModel == nil then
    return;
  end
  itemView:Render(itemModel, Event.Create(self, self._EventOnItemClicked));
end



function OpenServerV3StageCampaignDlg:_EventOnItemClicked(stageId)
  if stageId == nil or stageId == "" or self.m_viewModel == nil or
      self.m_viewModel.stageList == nil or
      CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end

  local itemModel = nil;
  for _, model in ipairs(self.m_viewModel.stageList) do
    if model ~= nil and model.stageId == stageId then
      itemModel = model;
      break;
    end
  end
  if itemModel == nil then
    return;
  end
  CS.Torappu.GameAnalytics.RecordOpenServerV3StageTabDetailClick(stageId, itemModel.isUnlock);
  if not itemModel.isUnlock then
    luaUtils.TextToast(itemModel.unlockTip);
    return;
  end

  local zoneId = itemModel.zoneId;
  if zoneId == nil or zoneId == "" then
    return;
  end
  CS.Torappu.UI.UIRouteUtil.RouteToCampaign(zoneId, stageId);
end


function OpenServerV3StageCampaignDlg:_EventOnCloseBtnClicked()
  self:Close();
end
