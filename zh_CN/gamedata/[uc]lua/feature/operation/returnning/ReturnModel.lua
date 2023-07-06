




ReturnModel =  ModelMgr.DefineModel("ReturnModel");

local CLICKED_ALL_OPEN_TAB_FLAG  = "ReturnAllOpen"

function ReturnModel:OnInit()
  self.m_clickedOpenTab = nil;
  CS.Torappu.UI.Home.HomeMainStateBean.SetExtension(self);
end

function ReturnModel:OnDispose()
  CS.Torappu.UI.Home.HomeMainStateBean.SetExtension(nil);
  if self.m_guideHandler then
    self.m_guideHandler:Dispose();
    self.m_guideHandler = nil;
  end
end

function ReturnModel:SetAlreadyPopup()
  if not self.m_updatePopTime then
    return;
  end
  local popupStamp = CS.Torappu.DateTimeUtil.timeStampNow;
  CS.Torappu.PlayerPrefsWrapper.SetUserInt("ReturnPopTime", popupStamp);
end


function ReturnModel:ShowGuide(forceRead)
  if self.m_guideHandler then
    self.m_guideHandler:Dispose();
    self.m_guideHandler = nil;
  end

  local currentData = CS.Torappu.PlayerData.instance.data.backflow.current;
  if not currentData then
    return false;
  end

  local forceReadCnt = -1;
  if forceRead then
    forceReadCnt = 3;
  end

  local guides = {};
  local fromTs = currentData.lastOnlineTs;
  local toTs = currentData.start;
  local introes = CS.Torappu.OpenServerDB.returnData.intro;
  for idx = 0, introes.Count -1 do
    local intro = introes[idx];
    local pubTime = intro.pubTime;
    if pubTime > fromTs and pubTime < toTs then
      table.insert(guides, intro.image);
      if #guides >= 8 then
        break;
      end
    end
  end

  if #guides <= 0 then
    local defaultIntro = CS.Torappu.OpenServerDB.returnData.constData.defaultIntro;
    if defaultIntro == nil or defaultIntro == "" then
      guides = {"[PACK]Return/page_return"};
    else
      table.insert(guides, defaultIntro);
    end
  end

  local this = self;
  self.m_guideHandler = CS.Torappu.UI.LuaUIMisc.OpenGuidebookExt(guides, forceReadCnt, function()
    CS.Torappu.PlayerPrefsWrapper.SetUserInt("ReturnIntro" .. currentData.start, 1);
  end);
end

function ReturnModel:CheckIfNeedReadIntro(currentData)
  currentData = currentData or CS.Torappu.PlayerData.instance.data.backflow.current;
  if not currentData then
    return false;
  end

  local introRecord = CS.Torappu.PlayerPrefsWrapper.GetUserInt("ReturnIntro" .. currentData.start, 0);
  return introRecord == 0;
end


function ReturnModel:GetOnceRewardStatus()
  local currentData = CS.Torappu.PlayerData.instance.data.backflow.current;
  if not currentData then
    return ReturnOnceRewardStatus.ERROR;
  end
  if currentData.reward then
    return ReturnOnceRewardStatus.GOT;
  end

  
  local passSec = CS.Torappu.DateTimeUtil.timeStampNow - currentData.start;
  local dur = CS.Torappu.OpenServerDB.returnData.constData.systemTab_time;
  if passSec > dur * 24 * 3600 then
    return ReturnOnceRewardStatus.TIME_OUT;
  end

  return ReturnOnceRewardStatus.READY;
end

function ReturnModel:HasOnceReward()
  return self:GetOnceRewardStatus() == ReturnOnceRewardStatus.READY;
end

function ReturnModel:CanClaimTaskOrCredit()
  local canClaimCredit = self:CanClaimCredit()
  if canClaimCredit then
    return true
  end

  local canClaimTask = self:CanClaimTask()
  if canClaimTask then
    return true
  end
  
  return false
end

function ReturnModel:CanClaimTask()
  local currentData = CS.Torappu.PlayerData.instance.data.backflow.current
  if not currentData then
    return false
  end
  if not currentData.mission then
    return false
  end
  
  local dailyList = currentData.mission.dailyList
  for idx = 0, dailyList.Count - 1 do
    local daily = dailyList[idx]
    if daily.status == ReturnTaskState.STATE_TASK_DONE then
      return true
    end
  end
  
  local longTermList = currentData.mission.longList
  for idx = 0, longTermList.Count - 1 do
    local longTerm = longTermList[idx]
    if longTerm.status == ReturnTaskState.STATE_TASK_DONE then
      return true
    end
  end

  return false
end

function ReturnModel:CanClaimCredit()
  local currentData = CS.Torappu.PlayerData.instance.data.backflow.current
  if not currentData then
    return false
  end
  local mission = currentData.mission
  if not mission then
    return false
  end

  local returnConst = CS.Torappu.OpenServerDB.returnData.constData
  local curCreditPro = mission.point
  local targetCreditPro = returnConst.needPoints
  local creditFull = targetCreditPro > 0 and curCreditPro >= targetCreditPro

  local canClaim = creditFull and not currentData.mission.reward
  return canClaim
end

function ReturnModel:CanClaimTaskReward(missionId)
  local data = self:_GetPlayerDailyTask(missionId)
  if not data then
    data = self:_GetPlayerLongTermTask(missionId)
  end
  if not data then
    return false
  end
  return data.status == ReturnTaskState.STATE_TASK_DONE
end

function ReturnModel:GetReturnStatus()
  local status = {
    open = false;
    shouldPopup = false;
    showTrackPoint = false;
    onlyWeekly = false;
  }
  local playerData = CS.Torappu.PlayerData.instance.data.backflow;
  if playerData == nil then
    status.open = false;
    return status;
  else
    status.open = playerData.open;
  end

  local returnV2Model = ReturnV2Model.me;
  local useOld = self:GetReturnVersion();
  if not useOld then
    status.open = status.open and returnV2Model:IsReturnV2Show(playerData);
  end
  if not status.open then
    return status;
  end

  if useOld then
    status.onlyWeekly = self:CheckIfOnlyWeeklyOpen();
    status.shouldPopup = self:_CheckIfPopupReturnPage();
    status.showTrackPoint = not status.onlyWeekly and self:_CheckShowTrackPoint();
  else
    status.onlyWeekly = returnV2Model:CheckIfOnlyWeeklyOpen(playerData);
    status.shouldPopup = returnV2Model:CheckIfPopupReturnPage();
    status.showTrackPoint = not status.onlyWeekly and returnV2Model:CheckShowTrackPoint();
  end

  return status;
end


function ReturnModel:GetReturnVersion()
  return CS.Torappu.PlayerData.instance.data.backflow == nil or 
      CS.Torappu.PlayerData.instance.data.backflow.version == nil or
      CS.Torappu.PlayerData.instance.data.backflow.version == CS.Torappu.PlayerReturnData.Version.OLD;
end

function ReturnModel:_CheckIfPopupReturnPage()

  
  if self:HasOnceReward() or self:CheckIfNeedReadIntro() then
    self.m_updatePopTime = true;
    return true;
  end

  
  local prePopTime = nil;
  local popupStamp = CS.Torappu.PlayerPrefsWrapper.GetUserInt("ReturnPopTime", 0);
  if popupStamp ~= nil and popupStamp ~= 0 then
    prePopTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(popupStamp);
  end

  local current = CS.Torappu.DateTimeUtil.currentTime;
  if prePopTime and CS.Torappu.DateTimeUtil.IsSameDay(prePopTime, current) then
    return false;
  end

  
  local currentData = CS.Torappu.PlayerData.instance.data.backflow.current;
  if not currentData then
    return false;
  end

  
  local passSec = CS.Torappu.DateTimeUtil.timeStampNow - currentData.start;
  local dur = CS.Torappu.OpenServerDB.returnData.constData.systemTab_time;
  if passSec > dur * 24 * 3600 then
    return false;
  end

  self.m_updatePopTime = true;
  return true;
end

function ReturnModel:_CheckShowTrackPoint()
  return TrackPointModel.me:UpdateNode(ReturnEntryTrackPoint);
end


function ReturnModel:CheckIfOnlyWeeklyOpen()
  local currentData = CS.Torappu.PlayerData.instance.data.backflow.current;
  if not currentData then
    return false;
  end

  local passSec = CS.Torappu.DateTimeUtil.timeStampNow - currentData.start;
  local dur = CS.Torappu.OpenServerDB.returnData.constData.systemTab_time;
  return passSec >= dur * 24 * 3600;
end

function ReturnModel:_GetPlayerLongTermTask(missionId)
  local currentData = CS.Torappu.PlayerData.instance.data.backflow.current
  if not currentData then
    return nil
  end
  if not currentData.mission then
    return nil
  end
  for idx, cur in pairs(currentData.mission.longList) do
    if cur.missionId == missionId then
      return cur
    end
  end 
  return nil
end

function ReturnModel:_GetPlayerDailyTask(missionId)
  local currentData = CS.Torappu.PlayerData.instance.data.backflow.current
  if not currentData then
    return nil
  end
  if not currentData.mission then
    return nil
  end
  for idx, cur in pairs(currentData.mission.dailyList) do
    if cur.missionId == missionId then
      return cur
    end
  end 
  return nil
end



function ReturnModel:GetLongTermTask(id)
  for idx, cur in pairs(CS.Torappu.OpenServerDB.returnData.returnLongTermTaskList) do
    if cur.id == id then
      return cur
    end
  end 
  return nil
end




function ReturnModel:GetDailyTask(groupId, id)
  local dailyTaskDic = CS.Torappu.OpenServerDB.returnData.returnDailyTaskDic
  if groupId == nil or dailyTaskDic == nil then
    return nil
  end
  local suc, dailyTasks = dailyTaskDic:TryGetValue(groupId)
  if suc then
    for idx, cur in pairs(dailyTasks) do
      if cur.id == id then
        return cur
      end
    end 
    return nil
  end
  return nil
end


function ReturnModel:GetCheckinListCount()
  local list = CS.Torappu.OpenServerDB.returnData.checkinRewardList
  if not list then
    return 0
  end
  return list.Count
end

function ReturnModel:HasClickedAllOpenTab()
  local currentData = CS.Torappu.PlayerData.instance.data.backflow.current
  if not currentData then
    return true
  end
  if self.m_clickedOpenTab == nil then
    self.m_clickedOpenTab = CS.Torappu.PlayerPrefsWrapper.GetUserInt(CLICKED_ALL_OPEN_TAB_FLAG .. currentData.start, 0) == 1
  end
  return self.m_clickedOpenTab
end


function ReturnModel:SetAllOpenTabClicked(value)
  if self.m_clickedOpenTab ~= nil and self.m_clickedOpenTab == value then
    return
  end

  local currentData = CS.Torappu.PlayerData.instance.data.backflow.current
  if not currentData then
    return
  end
  local flag = 1
  if value == true then
    flag = 1
  else
    flag = 0
  end
  CS.Torappu.PlayerPrefsWrapper.SetUserInt(CLICKED_ALL_OPEN_TAB_FLAG .. currentData.start, flag)
  self.m_clickedOpenTab = value
end