







local CollectionTaskListAdapter = require("Feature/Activity/Collection/CollectionTaskListAdapter")
CollectionTaskListDlg = DlgMgr.DefineDialog("CollectionTaskListDlg", "Activity/Collection/task_list_dlg");

function CollectionTaskListDlg:OnInit()
  self.m_dailyItem = self:CreateWidgetByGO(CollectionDailyTaskItem, self._dailyItem);

  self.m_listAdapter = self:CreateCustomComponent(CollectionTaskListAdapter, self._listAdapter, self);
  self.m_listAdapter.missionList = {};
end

function CollectionTaskListDlg:OnClose()
  if self.m_close then
    self.m_close:Call();
  end
end



function CollectionTaskListDlg:Refresh(activityId, close)
  self.m_activityId = activityId;
  self.m_close = close;

  local actcfg = CollectionActModel.me:GetActCfg(activityId);

  self.m_dailyItem:Refresh(activityId, actcfg);

  
  local missionGrp = CollectionActModel.me:GetMissionGroup(activityId);
  if missionGrp == nil then
    return;
  end

  
  local list = {};
  for idx = 0, missionGrp.missionIds.Length -1 do
    local missionId = missionGrp.missionIds[idx];
    local missionData = CollectionActModel.me:FindMission(missionId);
    
    if missionData then
      table.insert(list, missionData);
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
    
  table.sort(list, comp);
  self.m_listAdapter.missionList = list;
  self.m_listAdapter.actCfg = actcfg;
  self.m_listAdapter:NotifyDataSourceChanged();

  self:_SynTime();
end

function CollectionTaskListDlg:_SynTime()
  
  local time = CS.Torappu.DateTimeUtil.currentTime:AddHours(-1 * CS.Torappu.SharedConsts.GAME_DAY_DIVISION_HOUR);
  local zero = CS.System.DateTime(time.Year, time.Month, time.Day, 0, 0, 0):AddDays(1);
  self._dailyTaskTimeLabel.text = CS.Torappu.Lua.Util.Format(CS.Torappu.StringRes.SHOP_REMAIN_COUNT, CS.Torappu.FormatUtil.FormatTimeDelta(zero - time));
  
  local endTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(CollectionActModel.me:FindBasicInfo(self.m_activityId).endTime);
  local timeRemain = endTime - CS.Torappu.DateTimeUtil.currentTime;
  self._limitTaskTimeLabel.text = CS.Torappu.Lua.Util.Format(CS.Torappu.StringRes.SHOP_REMAIN_COUNT, CS.Torappu.FormatUtil.FormatTimeDelta(timeRemain));
end




function CollectionTaskListDlg:_CheckMissionFinished(playerMissionDict, missionId) 
  local suc, state = playerMissionDict:TryGetValue(missionId);
  return suc and state.state == CS.Torappu.MissionHoldingState.FINISHED;
end