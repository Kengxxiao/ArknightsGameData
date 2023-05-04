local luaUtils = CS.Torappu.Lua.Util;



































local ReturnTaskView = Class("ReturnTaskView", UIPanel)

local ReturnTaskItem = require("Feature/Operation/Returnning/ReturnTaskItem")

local STATE_CREDIT_DOING         = 0
local STATE_CREDIT_CAN_CLAIM     = 1
local STATE_CREDIT_COMPLETE      = 2

local SCROLL_BIAS = 0.014

  function ReturnTaskView:OnInit()
    self.m_currentData = {}
    self.m_dailyTaskItems = {}
    self.m_longTermTaskItems = {}
    self:AddButtonClickListener(self._btnCreditDetail, self._EventOnCreditClick)
    self:AddButtonClickListener(self._btnClaimAll, self._EventOnClaimAllClick)
    self:AddButtonClickListener(self._btnCreditClaim, self._EventOnCreditClaimClick)
  end

  function ReturnTaskView:Bind(dlg)
    if dlg == nil then
      return
    end
    self.m_dlg = dlg
  end

  function ReturnTaskView:Render()
    self.m_currentData = CS.Torappu.PlayerData.instance.data.backflow.current
    self:_RenderCreditPart()
    self:_RenderTaskPart(true)
    self:_RenderClaimAllPart()
    self:_RenderTimePart()
  end

  function ReturnTaskView:_RenderCreditPart()
    
    if not self.m_currentData then
      return
    end
    local returnConst = CS.Torappu.OpenServerDB.returnData.constData
    local mission = self.m_currentData.mission
    local curCreditPro = mission.point
    local targetCreditPro = returnConst.needPoints
    local creditFull = targetCreditPro > 0 and curCreditPro >= targetCreditPro
    SetGameObjectActive(self._objCreditProgressInfo, not creditFull)
    SetGameObjectActive(self._objCreditProgressMax, creditFull)
    if not creditFull then
      self._txtCreditProgressCur.text =  string.format("%d", curCreditPro)
      self._txtCreditProgressAll.text = string.format("/%d", targetCreditPro)
    end
    
    if targetCreditPro <= 0 then
      self._creditProgress.size = 0
    else
      self._creditProgress.size = curCreditPro / targetCreditPro
    end
    
    self:_RenderCreditClaimPart(creditFull)
  end

  function ReturnTaskView:_RenderCreditClaimPart(creditFull)
    if not self.m_currentData then
      return
    end
    local mission = self.m_currentData.mission
    local rewardClaimed = mission.reward
    if creditFull then
      if rewardClaimed then
        self.m_creditState = STATE_CREDIT_COMPLETE
      else
        self.m_creditState = STATE_CREDIT_CAN_CLAIM
      end
    else
      self.m_creditState = STATE_CREDIT_DOING
    end
    SetGameObjectActive(self._objCreditNormal, self.m_creditState == STATE_CREDIT_DOING)
    SetGameObjectActive(self._objCreditCanClaim, self.m_creditState == STATE_CREDIT_CAN_CLAIM)
    SetGameObjectActive(self._objCreditClaimed, self.m_creditState == STATE_CREDIT_COMPLETE)
  end

  
  
  
  function ReturnTaskView:_RenderTaskPart(refreshScrollProgress)
    if not self.m_currentData then
      return
    end
    
    local dailyList = ToLuaArray(self.m_currentData.mission.dailyList)
    if dailyList and #dailyList > 0 then
      self.m_hasCanClaimDailyTask = self:_InitTaskItemList(dailyList, true, self.m_dailyTaskItems, self._dailyTaskItemPrefab, self._rectGroupDailyTask)
    end
    
    local longTermList = ToLuaArray(self.m_currentData.mission.longList)
    if longTermList and #longTermList > 0 then
      self.m_hasCanClaimLongTermTask = self:_InitTaskItemList(longTermList, false, self.m_longTermTaskItems, self._longTermTaskItemPrefab, self._rectGroupLongTermTask)
    end
    
    if not dailyList or not longTermList then
      return
    end

    if refreshScrollProgress then
      local this = self
      if not this.m_firstScroll then 
        local waitFrames = #dailyList + #longTermList + 1
        local co = coroutine.create(function()
          for i = 1, waitFrames do
            if i == waitFrames then
              this:_InitTaskScrollProgress(dailyList, longTermList)
            end
            coroutine.yield()
          end
        end)
        this:Frame(waitFrames, this._RunCoroutine, co)  
        this.m_firstScroll = true
      else
        this:_InitTaskScrollProgress(dailyList, longTermList)
      end

    end
  end

  
  
  
  
  
  function ReturnTaskView:_InitTaskItemList(playerDataList, isDaily, taskItems, taskItemPrefab, parent)
    local taskItemList = {}
    local hasCanClaimTask = false
    for idx = 1, #playerDataList do
      local data = playerDataList[idx]
      if data.status == ReturnTaskState.STATE_TASK_DONE then
        hasCanClaimTask = true
      end
      local gameData = nil
      if isDaily then
        gameData = ReturnModel.me:GetDailyTask(data.missionGroupId, data.missionId)
      else
        gameData = ReturnModel.me:GetLongTermTask(data.missionId)
      end
      if gameData ~= nil then
        local item = nil
        if idx <= #taskItems then
          item = taskItems[idx]
        else
          item = self:CreateWidgetByPrefab(ReturnTaskItem, taskItemPrefab, parent)
          table.insert(taskItems, item)
        end
        local missionGameData = {
          missionId = data.missionId,
          current =  data.current,
          target = data.target,
          status = data.status,
          data = gameData,
        }
        item:Render(self, missionGameData, isDaily)
        table.insert(taskItemList, item)
      end
    end

    table.sort(taskItemList, 
      function(a, b)
        if a:SortState() == b:SortState() then
          return a:SortId() < b:SortId()
        end
        return a:SortState() < b:SortState() 
      end)

    local co = coroutine.create(function()
      for i = 1, #taskItemList do
        local item = taskItemList[i]
        item:RootGameObject().transform:SetSiblingIndex(i - 1)
        coroutine.yield()
      end
    end)
    self:Frame(#taskItemList, self._RunCoroutine, co)  

    return hasCanClaimTask
  end

  function ReturnTaskView:_RunCoroutine(co)
    coroutine.resume(co);
  end

  function ReturnTaskView:_RenderClaimAllPart()
    SetGameObjectActive(self._objBtnClaimAll, self.m_creditState == STATE_CREDIT_CAN_CLAIM or self.m_hasCanClaimDailyTask or self.m_hasCanClaimLongTermTask)
  end

  function ReturnTaskView:_RenderTimePart()
    if not self.m_currentData then
      return
    end
    local returnConst = CS.Torappu.OpenServerDB.returnData.constData
    if not returnConst then
      return
    end
    
    local startTime = self.m_currentData.start
    local endDateTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(startTime):AddDays(returnConst.permMission_time)
    local timedesc = CS.Torappu.Lua.Util.Format(CS.Torappu.StringRes.DATE_FORMAT_YYYY_MM_DD_HH_MM, endDateTime.Year, endDateTime.Month, endDateTime.Day, endDateTime.Hour,endDateTime.Minute);
    self._txtFinishTime.text = timedesc

    
    local timeRemain = endDateTime - CS.Torappu.DateTimeUtil.currentTime
    self._txtLongTermUpdateTime.text = CS.Torappu.Lua.Util.Format(CS.Torappu.StringRes.COMMON_LEFT_TIME, CS.Torappu.FormatUtil.FormatTimeDelta(timeRemain))
    
    
    local time = CS.Torappu.DateTimeUtil.currentTime:AddHours(-1 * CS.Torappu.SharedConsts.GAME_DAY_DIVISION_HOUR);
    local zero = CS.System.DateTime(time.Year, time.Month, time.Day, 0, 0, 0):AddDays(1);
    self._txtDailyUpdateTime.text = CS.Torappu.Lua.Util.Format(CS.Torappu.StringRes.RETURN_REFRESH_INFO, CS.Torappu.FormatUtil.FormatTimeDelta(zero - time));
  end

  
  function ReturnTaskView:_InitTaskScrollProgress(dailyList, longTermList)
    local isDailyTaskNotFinish = false
    local dailyTaskCount = #dailyList
    for idx = 1, dailyTaskCount do
      local data = dailyList[idx]
      if data.status ~= ReturnTaskState.STATE_TASK_COMPLETE then
        isDailyTaskNotFinish = true
        break
      end
    end

    if isDailyTaskNotFinish then
      self._scrollViewTask.verticalNormalizedPosition = 1
    else
      local longTermTaskCount = #longTermList
      local target = math.max(0, 1 - self:_CalculateTaskScrollProgress(dailyTaskCount, longTermTaskCount))
      self._scrollViewTask:DoScrollVertTo(target, 0.3)
    end
  end

  
  function ReturnTaskView:_CalculateTaskScrollProgress(dailyTotalCount, longTermTotalCount)
    local dailyColumn = math.ceil(dailyTotalCount / 2)
    local totalColumn = dailyColumn + longTermTotalCount
    local focusColumn = dailyColumn + 1
    local offset = SCROLL_BIAS * dailyColumn
    local to = focusColumn / totalColumn + offset
    if to >= 1 then
      return 1
    else
      return to
    end
  end

  function ReturnTaskView:EventOnClaimTaskClick(mId)
    if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
      return
    end
    if not ReturnModel.me:CanClaimTaskReward(mId) then
      return
    end
    
    UISender.me:SendRequest(ReturnServiceCode.GET_MISSION_REWARD,
    {
      missionId = mId,
    },
    {
      onProceed = Event.Create(self, self._ClaimTaskGetResponse),
      abortIfBusy = true
    })
  end

  
  function ReturnTaskView:_ClaimTaskGetResponse(response)
    
    CS.Torappu.Activity.ActivityUtil.DoShowGainedItems(response.items)
    
    self.m_currentData = CS.Torappu.PlayerData.instance.data.backflow.current
    
    self:_RenderCreditPart()
    
    self:_RenderTaskPart(false)
    
    self:_RenderClaimAllPart()
    
    TrackPointModel.me:UpdateNode(ReturnTaskTabTrackPoint);
  end

  function ReturnTaskView:_EventOnCreditClick()
    if self.m_dlg == nil then
      return
    end
    self.m_dlg:EventOnShowCreditRewards()
  end

  function ReturnTaskView:_EventOnClaimAllClick()
    if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
      return
    end
    if not ReturnModel.me:CanClaimTaskOrCredit() then
      return
    end
    
    UISender.me:SendRequest(ReturnServiceCode.AUTO_GET_REWARD,
    {
    },
    {
      onProceed = Event.Create(self, self._ClaimAllGetResponse),
      abortIfBusy = true
    })
  end

  
  function ReturnTaskView:_ClaimAllGetResponse(response)
    
    CS.Torappu.Activity.ActivityUtil.DoShowGainedItems(response.items)
    
    self.m_currentData = CS.Torappu.PlayerData.instance.data.backflow.current
    
    self:_RenderTaskPart(false)
    
    self:_RenderCreditPart()
    
    self:_RenderClaimAllPart()
    
    TrackPointModel.me:UpdateNode(ReturnTaskTabTrackPoint);
  end

  function ReturnTaskView:_EventOnCreditClaimClick()
    if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
      return
    end
    if not ReturnModel.me:CanClaimCredit() then
      return
    end

    UISender.me:SendRequest(ReturnServiceCode.GET_POINT_REWARD,
    {     
    },
    {
      onProceed = Event.Create(self, self._CreditClaimGetResponse),
      abortIfBusy = true
    })
  end

  
  function ReturnTaskView:_CreditClaimGetResponse(response)
    
    CS.Torappu.Activity.ActivityUtil.DoShowGainedItems(response.items)
    
    self.m_currentData = CS.Torappu.PlayerData.instance.data.backflow.current
    
    self:_RenderCreditClaimPart(true)
    
    self:_RenderTaskPart(false)
    
    self:_RenderClaimAllPart()
    
    TrackPointModel.me:UpdateNode(ReturnTaskTabTrackPoint);
  end

return ReturnTaskView