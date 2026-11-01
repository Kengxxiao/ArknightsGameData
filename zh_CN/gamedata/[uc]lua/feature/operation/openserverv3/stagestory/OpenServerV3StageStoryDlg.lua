











OpenServerV3StageStoryDlg = DlgMgr.DefineDialog(
    "OpenServerV3StageStoryDlg",
    "Operation/[UC]OpenServerV3/OpenServerV3Story/open_server_v3_stage_story_dlg",
    DlgBase);

local OpenServerV3StageStoryMainStoryItemView = require("Feature/Operation/OpenServerV3/StageStory/OpenServerV3StageStoryMainStoryItemView");
local OpenServerV3StageStorySsItemView = require("Feature/Operation/OpenServerV3/StageStory/OpenServerV3StageStorySsItemView");

function OpenServerV3StageStoryDlg:OnInit()
  self:AddButtonClickListener(self._btnClose, self._EventOnCloseBtnClicked);

  self.m_viewModel = self:CreateViewModel(OpenServerV3StageStoryDlgViewModel);
  self.m_viewModel:LoadData();

  local isSsSystemUnlocked = self.m_viewModel.isSsSystemUnlocked;
  SetGameObjectActive(self._pnlListSsGo, isSsSystemUnlocked);
  SetGameObjectActive(self._pnlSsLockedGo, not isSsSystemUnlocked);
  if self._canvasTitleSs ~= nil then
    self._canvasTitleSs.alpha = isSsSystemUnlocked and 1 or (tonumber(self._alphaTitleSs) or 1);
  end
  if self._textSsLocked ~= nil then
    self._textSsLocked.text = self.m_viewModel.ssLockedTip or "";
  end

  self.m_mainStoryAdapter = self:CreateCustomComponent(
      UISimpleLayoutAdapter, self, self._pnlListMain,
      self._CreateMainStoryItemView, self._GetMainStoryItemCount, self._UpdateMainStoryItemView);
  self.m_mainStoryAdapter:NotifyDataSetChanged();

  self.m_ssStoryAdapter = self:CreateCustomComponent(
      UISimpleLayoutAdapter, self, self._pnlListSs,
      self._CreateSsItemView, self._GetSsItemCount, self._UpdateSsItemView);
  self.m_ssStoryAdapter:NotifyDataSetChanged();
end



function OpenServerV3StageStoryDlg:_CreateMainStoryItemView(gameObj)
  return self:CreateWidgetByGO(OpenServerV3StageStoryMainStoryItemView, gameObj);
end


function OpenServerV3StageStoryDlg:_GetMainStoryItemCount()
  if self.m_viewModel == nil or self.m_viewModel.mainStoryList == nil then
    return 0;
  end
  return #self.m_viewModel.mainStoryList;
end



function OpenServerV3StageStoryDlg:_UpdateMainStoryItemView(index, itemView)
  if self.m_viewModel == nil or self.m_viewModel.mainStoryList == nil then
    return;
  end
  local luaIndex = index + 1;
  local itemModel = self.m_viewModel.mainStoryList[luaIndex];
  if itemModel == nil then
    return;
  end
  itemView:Render(itemModel, Event.Create(self, self._EventOnMainStoryItemClicked));
end



function OpenServerV3StageStoryDlg:_CreateSsItemView(gameObj)
  local itemView = self:CreateWidgetByGO(OpenServerV3StageStorySsItemView, gameObj);
  itemView.createWidgetByGO = function(widgetCls, layout)
    return self:CreateWidgetByGO(widgetCls, layout);
  end
  return itemView;
end


function OpenServerV3StageStoryDlg:_GetSsItemCount()
  if self.m_viewModel == nil or self.m_viewModel.ssStoryList == nil then
    return 0;
  end
  return #self.m_viewModel.ssStoryList;
end



function OpenServerV3StageStoryDlg:_UpdateSsItemView(index, itemView)
  if self.m_viewModel == nil or self.m_viewModel.ssStoryList == nil then
    return;
  end
  local luaIndex = index + 1;
  local itemModel = self.m_viewModel.ssStoryList[luaIndex];
  if itemModel == nil then
    return;
  end
  itemView:Render(itemModel, Event.Create(self, self._EventOnSsItemClicked));
end



function OpenServerV3StageStoryDlg:_EventOnSsItemClicked(storySetId)
  if storySetId == nil or storySetId == "" then
    return;
  end
  CS.Torappu.GameAnalytics.RecordOpenServerV3StageTabDetailClick(storySetId, true);
  CS.Torappu.UI.UIRouteUtil.RouteToMixStoryBrief(storySetId);
end



function OpenServerV3StageStoryDlg:_EventOnMainStoryItemClicked(zoneId)
  if zoneId == nil or zoneId == "" then
    return;
  end
  CS.Torappu.GameAnalytics.RecordOpenServerV3StageTabDetailClick(zoneId, true);
  CS.Torappu.UI.UIRouteUtil.RouteToStage(zoneId, nil);
end


function OpenServerV3StageStoryDlg:_EventOnCloseBtnClicked()
  self:Close();
end
