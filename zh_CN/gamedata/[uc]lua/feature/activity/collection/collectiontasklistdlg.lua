---@class CollectionTaskListDlg : DlgBase
---@field _dailyTaskTimeLabel Text
---@field _limitTaskTimeLabel Text
---@field _dailyItem LuaLayout
---@field _limitContainer Transform
---@field _limitItemPrefab LuaLayout
---@field m_limitItems CollectionTimedTaskItem[]
---@field m_activityId string
---@field m_close Event
---@field m_dailyItem CollectionDailyTaskItem
CollectionTaskListDlg = DlgMgr.DefineDialog("CollectionTaskListDlg", "Activity/Collection/task_list_dlg");

function CollectionTaskListDlg:OnInit()
  self.m_limitItems = {}
  self.m_dailyItem = self:CreateWidgetByGO(CollectionDailyTaskItem, self._dailyItem);
end

function CollectionTaskListDlg:OnClose()
  if self.m_close then
    self.m_close:Call();
  end
end

---@param activityId string
---@param close Event
function CollectionTaskListDlg:Refresh(activityId, close)
  self.m_activityId = activityId;
  self.m_close = close;

  local actcfg = CollectionActModel.me:GetActCfg(activityId);

  self.m_dailyItem:Refresh(activityId, actcfg);

  --refresh missions
  local missionGrp = CollectionActModel.me:GetMissionGroup(activityId);
  if missionGrp == nil then
    return;
  end

  ---@type CollectionTimedTaskItem[]
  local list = {};
  for idx = 0, missionGrp.missionIds.Length -1 do
    local missionId = missionGrp.missionIds[idx];
    local missionData = CollectionActModel.me:FindMission(missionId);
    
    if missionData then
      local item = null;
      if idx < #self.m_limitItems then
        item = self.m_limitItems[idx+1];
      else
        item = self:CreateWidgetByPrefab(CollectionTimedTaskItem, self._limitItemPrefab);
        table.insert(self.m_limitItems, item);
      end

      item:Refresh(missionData, actcfg);
      table.insert(list, item);
    end
      
  end

  table.sort(list, function(a, b)
    if a:Finished() == b:Finished() then
      return a:SortId() < b:SortId();
    end
    return b:Finished();
  end);

  local co = coroutine.create(function()
    for _, item in ipairs(list) do
      item:CreateRewardIcon(actcfg);
      item:Root().transform:SetParent(self._limitContainer, false);
      coroutine.yield();
    end
  end);
  self:Frame(#list, self._RunCoroutine, co);

  self:_SynTime();
end

function CollectionTaskListDlg:_RunCoroutine(co)
  coroutine.resume(co);
end

function CollectionTaskListDlg:_SynTime()
  --refresh daily task time
  local time = CS.Torappu.DateTimeUtil.currentTime:AddHours(-1 * CS.Torappu.SharedConsts.GAME_DAY_DIVISION_HOUR);
  local zero = CS.System.DateTime(time.Year, time.Month, time.Day, 0, 0, 0):AddDays(1);
  self._dailyTaskTimeLabel.text = CS.Torappu.Lua.Util.Format(CS.Torappu.StringRes.SHOP_REMAIN_COUNT, CS.Torappu.FormatUtil.FormatTimeDelta(zero - time));
  --refresh collection mission time
  local endTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(CollectionActModel.me:FindBasicInfo(self.m_activityId).endTime);
  local timeRemain = endTime - CS.Torappu.DateTimeUtil.currentTime;
  self._limitTaskTimeLabel.text = CS.Torappu.Lua.Util.Format(CS.Torappu.StringRes.SHOP_REMAIN_COUNT, CS.Torappu.FormatUtil.FormatTimeDelta(timeRemain));
end
