local FloatParadeSignedPanel = require "Feature/Activity/FloatParade/FloatParadeSignedPanel"
local FloatParadeSignAnimPanel = require "Feature/Activity/FloatParade/FloatParadeSignAnimPanel"





































FloatParadeMainDlg = Class("FloatParadeMainDlg", DlgBase);
FloatParadeMainDlg.ENTRY_ANIM = "float_parade_entry";

function FloatParadeMainDlg:OnInit()
  self:AddButtonClickListener(self._btnClose, FloatParadeMainDlg._HandleClose);
  self:AddButtonClickListener(self._btnShowRule, FloatParadeMainDlg._HandleShowActRule);

  self.m_data = FloatParadeMainDlgData.new();
  if not self.m_data:Init(self.m_parent:GetData("actId")) then
    return;
  end

  local initTacticSelIdx = -1;
  
  self.m_probDetailPanel = self:CreateWidgetByPrefab(FloatParadeProbDetailPanel, self._probDetailPrefab, self._probDetailRoot);
  self.m_signedPanel = self:CreateWidgetByGO(FloatParadeSignedPanel, self._endLayout);
  self.m_adapter = self:CreateCustomComponent(FloatParadeRecycleDayListAdapter, self._adapterNode, self);
  self.m_adapter.clickEvent = Event.Create(self, self._HandleShowRewardRule);
  self:_InitTacticTabs();
  self:_RenderDailyContent();
  self:_UpdateTacticSelect(initTacticSelIdx, true);
  if self.m_data.canRaffleToday then
    self._animWrapper:InitIfNot();
    self._animWrapper:Play(FloatParadeMainDlg.ENTRY_ANIM);
  end
end

function FloatParadeMainDlg:_InitTacticTabs()
  if self.m_tacticTabs then
    return;
  end
  self.m_tacticTabs = {};
  local tactics = self.m_data.actData.tacticList;
  for idx = 0, tactics.Count -1 do
    
    local tab = self:CreateWidgetByPrefab(FloatParadeTacticTab, self._tacticTabPrefab, self._tacticTabRoot);
    tab:Render(idx, tactics[idx]);
    tab.selectTacticEvent = Event.Create(self, self._HandleTacticSelectChanged);
    tab.confirmTacticEvent = Event.Create(self, self._HandleConfirmTacticSelect);
    table.insert(self.m_tacticTabs, tab);
  end
end

function FloatParadeMainDlg:_RenderDailyContent()
  self:_RebuildDayList();
  self:_RenderBasicAndDayInfo();
  self:_RefreshSignStatus();
end

function FloatParadeMainDlg:_RebuildDayList()

  local dayModels = {};
  local days = self.m_data.actData.dailyDataDic;
  for idx = 0, days.Count - 1 do
    local dayData = days[idx];

    
    local dayModel = FloatParadeRecycleDayListAdapter.FloatParadeDayModel:new();
    dayModel.dayIndex = dayData.dayIndex;
    dayModel.dayName = dayData.dateName;
    dayModel.currIndex = self.m_data.currDayIndex;
    dayModel.hasExt = dayData.extReward ~= nil;
    dayModel.canRaffleToday = self.m_data.canRaffleToday;

    table.insert(dayModels, dayModel);
  end
  local scrollPos = self.m_data.currDayIndex / (days.Count -1);
  self.m_adapter.dayList = dayModels;
  self.m_adapter:NotifyDataChanged();

  
  self:_AutoFocusDayScroll()
end

function FloatParadeMainDlg:_RenderBasicAndDayInfo()
  
  local endt = CS.Torappu.DateTimeUtil.TimeStampToDateTime(self.m_data.basicData.endTime);
  self._endTime.text = CS.Torappu.FormatUtil.FormatDateTimeyyyyMMddHHmm(endt);
  
  local hubPath = CS.Torappu.ResourceUrls.GetFloatParadeHubPath(self.m_data.activityId);
  
  local sprite = self:LoadSpriteFromAutoPackHub(hubPath, self.m_data.actData.constData.cityNamePic);
  self._cityName.sprite = sprite;
  self._cityNameElement.preferredWidth = sprite.rect.width;
  
  self._placeName.text = self.m_data.todayData.placeName;
  self._zoneName.text = self.m_data.todayGroupInfo.name;
  self._probTitle.text = self.m_data.actData.constData.variationTitle;
  self._placePic.sprite = self:LoadSpriteFromAutoPackHub(hubPath, self.m_data.todayData.placePic);
  local hasExtReward = self.m_data.todayData.extReward ~= nil;
  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._extRewardFlag, hasExtReward);
end

function FloatParadeMainDlg:_RefreshSignStatus()
  local canRaffleToday = self.m_data.canRaffleToday;

  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._probNode, canRaffleToday);
  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._tacticsNode, canRaffleToday);
  self.m_signedPanel:SetVisible(not canRaffleToday);
  if not self.m_data.canRaffleToday then
    self.m_signedPanel:Render(self.m_data);
  end
end

function FloatParadeMainDlg:_UpdateTacticSelect(selTacticIdx, fastMode)
  if not self.m_data:SetSelectedTactic(selTacticIdx) then
    return;
  end
  
  if selTacticIdx >= 0 then
    self._tipToggle.state = CS.Torappu.UI.TwoStateToggle.State.SELECT;
  else
    self._tipToggle.state = CS.Torappu.UI.TwoStateToggle.State.UNSELECT;
  end
  
  for _, tab in ipairs(self.m_tacticTabs) do
    tab:UpdateSelected(selTacticIdx, fastMode);
  end
  
  self.m_probDetailPanel:UpdateRewards(self.m_data, fastMode);
end

function FloatParadeMainDlg:_HandleTacticSelectChanged(selIdx)
  self:_UpdateTacticSelect(selIdx, false);
end

function FloatParadeMainDlg:_HandleConfirmTacticSelect(selIdx)
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  if selIdx < 0 and selIdx >= self.actData.tacticList.Count then
    LogError("invalide tactic index:"..selIdx);
    return;
  end

  local tactic = self.m_data.actData.tacticList[selIdx];
  
  if not self.m_signAnimPanel then
    self.m_signAnimPanel = self:CreateWidgetByPrefab(FloatParadeSignAnimPanel, self._signAnimPrefab, self._signAnimRoot);
  end
  self.m_signAnimPanel:PlaySignAnim();

  UISender.me:SendRequest(FloatParadeServiceCode.RAFFLE,
  {
    activityId = self.m_data.activityId,
    strategy = tactic.id,
  }, 
  {
    onProceed = Event.Create(self, self._HandleResponse);
    onBlock = Event.Create(self, self._HandleResponseFailed)
  });
end

function FloatParadeMainDlg:_HandleResponse(response)
  if self:IsDestroy() then
    return;
  end
  
  self.m_data:UpdateTodayInfo();
  local rewardCnt = 0;
  local extRewardCnt = 0;
  local items = {};
  for _, reward in ipairs(response.awards) do
    table.insert(items, reward);
    rewardCnt = rewardCnt + reward.count;
  end
  for _, reward in ipairs(response.zoneAwards) do
    table.insert(items, reward);
    extRewardCnt = extRewardCnt + reward.count;
  end

  self.m_signAnimPanel:FlushData(self.m_data, rewardCnt, extRewardCnt, Event.Create(self, self._ShowGainedItem, items));
end

function FloatParadeMainDlg:_ShowGainedItem(items)
  local this = self;
  local handler = CS.Torappu.UI.LuaUIMisc.ShowGainedItems(items, CS.Torappu.UI.UIGainItemFloatPanel.Style.DEFAULT,
  function()
    this:_RenderDailyContent();
    this.m_signAnimPanel:Dispose();
    this.m_signAnimPanel = nil;
  end);
  self:_AddDisposableObj(handler);
end

function FloatParadeMainDlg:_HandleResponseFailed()
  if self.m_signAnimPanel then
    self.m_signAnimPanel:Dispose();
    self.m_signAnimPanel = nil;
  end
end

function FloatParadeMainDlg:_HandleClose()
  self:Close();
end

function FloatParadeMainDlg:_HandleShowRewardRule()
  if not self.m_rewardRulePanel then
    self.m_rewardRulePanel = self:CreateWidgetByPrefab(FloatParadeRewardRulePanel, self._rewardRulePrefab, self._rewardRuleRoot);
  end
  self.m_rewardRulePanel:Show(self.m_data.activityId,self.m_data.currDayIndex);
end

function FloatParadeMainDlg:_HandleShowActRule()
  if not self.m_actRulePanel then
    self.m_actRulePanel = self:CreateWidgetByPrefab(FloatParadeRulePanel, self._actRulePrefab, self._actRuleRoot);
  end
  self.m_actRulePanel:Show(self.m_data.actData);
end

function FloatParadeMainDlg:_AutoFocusDayScroll() 
  if not self.m_adapter then
    return
  end
  local viewCount = 5;
  local rect = self._scrollRect:GetComponent(typeof(CS.UnityEngine.RectTransform));
  if rect then
    local itemHeight = self.m_adapter:GetItemHeight();
    local viewHeight = rect.rect.size.y;
    viewCount = math.ceil(viewHeight / itemHeight);
  end
  
  local totalCount = self.m_adapter:GetTotalCount();
  local beginIdx = self.m_data.currDayIndex;
  if beginIdx > 0 then
    beginIdx = beginIdx - 1;
    if totalCount - beginIdx <= viewCount then
      beginIdx = totalCount - viewCount;
    end
  end
  self.m_adapter:NotifyRebuildWithIndex(beginIdx);
end

FloatParadeServiceCode = 
{
  RAFFLE = "/activity/floatParade/raffle";
}
Readonly(FloatParadeServiceCode);














FloatParadeMainDlgData = Class("FloatParadeMainDlgData");


function FloatParadeMainDlgData:Init(actId)
  self.activityId = actId;
  local suc, basicData = CS.Torappu.ActivityDB.data.basicInfo:TryGetValue(actId);
  if not suc then
    LogError("Can't find the activity basic data:".. actId);
    return false;
  end
  self.basicData = basicData;

  local suc, actData = CS.Torappu.ActivityDB.data.activity.floatParadeData:TryGetValue(actId);
  if not suc then
    LogError("Can't find the activity data:".. actId);
    return false;
  end
  self.actData = actData;

  return self:UpdateTodayInfo();
end

function FloatParadeMainDlgData:SetSelectedTactic(selIdx)
  if not self.todayData or not self.todayData.eventGroupId then
    return false
  end
  if self.tacticSelIdx == selIdx then
    return false;
  end
  self.tacticSelIdx = selIdx;

  self.todayRewards = {};
  local selTactic = nil;
  if selIdx >= 0 and selIdx < self.actData.tacticList.Count then
    selTactic = self.actData.tacticList[selIdx];
  end

  local suc, pools = self.actData.rewardPools:TryGetValue(self.todayData.eventGroupId);
  if not suc then
    LogError("[FloatParade]Get reward group failed!".. self.todayData.eventGroupId);
    return false;
  end
  for id, pool in pairs(pools) do
    local rewardVar = 0;
    if selTactic then
      local suc, value = selTactic.rewardVar:TryGetValue(pool.id);
      if suc then
        rewardVar = value;
      end
    end
    table.insert(self.todayRewards, {rewardPool = pool, var = rewardVar});
  end
  return true;
end

function FloatParadeMainDlgData:UpdateTodayInfo()
  self.currDayIndex = 0;
  self.canRaffleToday = false;
  self.todayResult = nil;

  local result = nil;
  local floatParades = CS.Torappu.PlayerData.instance.data.activity.floatParadeActivityList;
  local suc, playerActData = floatParades:TryGetValue(self.activityId);
  if suc then
    self.canRaffleToday = playerActData.canRaffle;
    if playerActData.canRaffle then
      self.currDayIndex = playerActData.day;
    else
      self.currDayIndex = playerActData.day -1;
    end
    result = playerActData.result;
  end
  local dayDic = self.actData.dailyDataDic;
  local todayData = dayDic[self.currDayIndex];
  self.totalDayCnt = dayDic.Count
  self.todayData = todayData

  if not self.canRaffleToday and result ~= nil then
    self.todayResult = {
      tactic = self:_FindTactic(result.strategy),
      reward = nil,
    };

    local suc, pools = self.actData.rewardPools:TryGetValue(self.todayData.eventGroupId);
    if suc then
      local poolSuc, pool = pools:TryGetValue(result.eventId);
      if poolSuc then
        self.todayResult.reward = pool;
      end
    end
    
  end

  
  repeat 
    self.todayGroupInfo = nil
    if not todayData or not todayData.eventGroupId then
      break
    end
    local suc, groupData = self.actData.groupInfos:TryGetValue(todayData.eventGroupId)
    if suc then
      self.todayGroupInfo = groupData
    end
  until true
  if self.todayGroupInfo == nil then
    LogError("Failed to load group for day ".. self.currDayIndex)
    self.todayGroupInfo = {}
  end

  return true;
end

function FloatParadeMainDlgData:_FindTactic(id)
  local tactics = self.actData.tacticList;
  for idx = 0, tactics.Count -1 do
    local tactic = tactics[idx];
    if tactic.id == id then
      return tactic;
    end
  end
  return nil;
end