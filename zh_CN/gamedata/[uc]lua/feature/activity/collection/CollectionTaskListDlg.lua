












local CollectionTimedTaskItem = require("Feature/Activity/Collection/CollectionTimedTaskItem")
local CollectionDailyTaskItem = require("Feature/Activity/Collection/CollectionDailyTaskItem")
 
local SimpleWidget = Class("CollectionTaskListSimpleWidget", UIWidget);
CollectionTaskListDlg = DlgMgr.DefineDialog("CollectionTaskListDlg", "Activity/Collection/task_list_dlg");

CollectionTaskItemType = {
  DAILTY_TITLE = 1,
  DAILTY_ITEM = 2,
  TIMED_TITLE = 3,
  TIMED_ITEM = 4,
}
Readonly(CollectionTaskItemType);

local itemSizeTable = {}
itemSizeTable[CollectionTaskItemType.DAILTY_TITLE] = 43;
itemSizeTable[CollectionTaskItemType.DAILTY_ITEM] = 110;
itemSizeTable[CollectionTaskItemType.TIMED_TITLE] = 43;
itemSizeTable[CollectionTaskItemType.TIMED_ITEM] = 131;

function CollectionTaskListDlg:OnInit()
  local viewDefineTable = {};
  viewDefineTable[CollectionTaskItemType.DAILTY_TITLE] = {
    prefab = self._dailyTitlePrefab,
    cls = SimpleWidget
  };
  viewDefineTable[CollectionTaskItemType.DAILTY_ITEM] = {
    prefab = self._dailyItemPrefab,
    cls = CollectionDailyTaskItem
  };
  viewDefineTable[CollectionTaskItemType.TIMED_TITLE] = {
    prefab = self._timedTitlePrefab,
    cls = SimpleWidget
  };
  viewDefineTable[CollectionTaskItemType.TIMED_ITEM] = {
    prefab = self._timedItemPrefab,
    cls = CollectionTimedTaskItem
  };

  self.m_adapter = self:CreateCustomComponent(UIVirtualViewAdapter, self, self._recycleGroup, viewDefineTable,self._RefreshListItem)
end

function CollectionTaskListDlg:OnClose()
  if self.m_close then
    self.m_close:Call();
  end
end



function CollectionTaskListDlg:Refresh(activityId, close)
  self.m_activityId = activityId;
  self.m_close = close;

  self.m_actCfg = CollectionActModel.me:GetActCfg(activityId);

  
  local missionGrp = CollectionActModel.me:GetMissionGroup(activityId);
  if missionGrp == nil then
    return;
  end

  
  self.m_missionList = {};
  for idx = 0, missionGrp.missionIds.Length -1 do
    local missionId = missionGrp.missionIds[idx];
    local missionData = CollectionActModel.me:FindMission(missionId);
    
    if missionData then
      table.insert(self.m_missionList, missionData);
    end
  end
  
  local playerMissions = CS.Torappu.PlayerData.instance.data.mission.missions;
  local suc, typeMissions = playerMissions:TryGetValue(CS.Torappu.MissionPlayerDataGroup.MissionTypeString.ACTIVITY);
  if not suc then
    return;
  end

  local comp = function(a, b) 
    local a_finish = self:_CheckMissionFinished(typeMissions, a.id);
    local b_finish = self:_CheckMissionFinished(typeMissions, b.id);

    if a_finish == b_finish then
      return a.sortId < b.sortId;
    end
    return b_finish;
  end;
    
  table.sort(self.m_missionList, comp);
  self:_RebuildVirtualViews();
  self.m_adapter:NotifyRebuildAll();
end




function CollectionTaskListDlg:_CheckMissionFinished(playerMissionDict, missionId) 
  local suc, state = playerMissionDict:TryGetValue(missionId);
  return suc and state.state == CS.Torappu.MissionHoldingState.FINISHED;
end

function CollectionTaskListDlg:_RebuildVirtualViews()
  self.m_adapter:RemoveAllViews();
  self.m_adapter:AddView({
    viewType = CollectionTaskItemType.DAILTY_TITLE,
    data = nil,
    size = itemSizeTable[CollectionTaskItemType.DAILTY_TITLE]
  });
  self.m_adapter:AddView({
    viewType = CollectionTaskItemType.DAILTY_ITEM,
    data = nil,
    size = itemSizeTable[CollectionTaskItemType.DAILTY_ITEM]
  });
  self.m_adapter:AddView({
    viewType = CollectionTaskItemType.TIMED_TITLE,
    data = nil,
    size = itemSizeTable[CollectionTaskItemType.TIMED_TITLE]
  });

  for idx = 1, #self.m_missionList do
    self.m_adapter:AddView({
      viewType = CollectionTaskItemType.TIMED_ITEM,
      data = self.m_missionList[idx],
      size = itemSizeTable[CollectionTaskItemType.TIMED_ITEM]
    });
  end
end




function CollectionTaskListDlg:_RefreshListItem(viewType, widget, model)
  if viewType == CollectionTaskItemType.DAILTY_TITLE then
    local time = CS.Torappu.DateTimeUtil.currentTime:AddHours(-1 * CS.Torappu.SharedConsts.GAME_DAY_DIVISION_HOUR);
    local zero = CS.System.DateTime(time.Year, time.Month, time.Day, 0, 0, 0):AddDays(1);
    widget._timeLabel.text = CS.Torappu.Lua.Util.Format(CS.Torappu.StringRes.SHOP_REMAIN_COUNT, CS.Torappu.FormatUtil.FormatTimeDelta(zero - time));
    return;
  elseif viewType == CollectionTaskItemType.DAILTY_ITEM then
    
    local dailyItem = widget;
    dailyItem:Refresh(self.m_activityId, self.m_actCfg);
    return;
  elseif viewType == CollectionTaskItemType.TIMED_TITLE then
    local endTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(CollectionActModel.me:FindBasicInfo(self.m_activityId).endTime);
    local timeRemain = endTime - CS.Torappu.DateTimeUtil.currentTime;
    widget._timeLabel.text = CS.Torappu.Lua.Util.Format(CS.Torappu.StringRes.SHOP_REMAIN_COUNT, CS.Torappu.FormatUtil.FormatTimeDelta(timeRemain));
    return;
  elseif viewType == CollectionTaskItemType.TIMED_ITEM then
    
    local timedItem = widget;
    timedItem:Refresh(model, self.m_actCfg);
    return;
  end
end