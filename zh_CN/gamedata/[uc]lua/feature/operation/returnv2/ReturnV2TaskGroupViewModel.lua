












local ReturnV2MissionViewModel = Class("ReturnV2MissionViewModel")
local CLICKED_MISSION_GROUP_FLAG = "ReturnV2MissionGroup";

function ReturnV2MissionViewModel:ctor()
  self.missionId = ""
  self.groupId = ""
  self.sortId = 0
  self.jumpType = CS.Torappu.ReturnV2JumpType.NONE
  self.jumpParam = ""
  self.missionDesc = ""
  self.rewardList = {}
  self.value = 0
  self.target = 0
  self.progress = 0
  self.state = ReturnV2TaskState.TASK_DOING
  self.sortState = ReturnV2TaskSortState.UNCOMPLETE
end


function ReturnV2MissionViewModel:InitData(missionData)
  if missionData == nil then
    return
  end

  self.missionId = missionData.missionId
  self.groupId = missionData.groupId
  self.sortId = missionData.sortId
  self.jumpType = missionData.jumpType
  self.jumpParam = missionData.jumpParam
  self.missionDesc = missionData.desc
  self.rewardList = ToLuaArray(missionData.rewardList)

  self.value = 0
  self.target = 0
  self.progress = 0
  self.state = ReturnV2TaskState.TASK_CLAIMED
  self.sortState = ReturnV2TaskSortState.CONFIRMED
end


function ReturnV2MissionViewModel:RefreshData(missionProgressData)
  if missionProgressData == nil then
    return
  end

  self.value = missionProgressData.current
  self.target = missionProgressData.target
  if self.target <= 0 then
    self.progress = 0
  else
    self.progress = self.value / self.target
  end
  self.state = missionProgressData.status
  if self.state == ReturnV2TaskState.TASK_DOING then
    self.sortState = ReturnV2TaskSortState.UNCOMPLETE
  elseif self.state == ReturnV2TaskState.TASK_CAN_CLAIM then
    self.sortState = ReturnV2TaskSortState.COMPLETE
  elseif self.state == ReturnV2TaskState.TASK_CLAIMED then
    self.sortState = ReturnV2TaskSortState.CONFIRMED
  end
end















local ReturnV2MissionGroupViewModel = Class("ReturnV2MissionGroupViewModel")

function ReturnV2MissionGroupViewModel:ctor()
  self.groupId = ""
  self.sortId = 0
  self.tabTitle = ""
  self.title = ""
  self.desc = ""
  self.diffMissionCount = 0
  self.startTime = 0
  self.endTime = 0
  self.imageId = ""
  self.iconId = ""
  self.missionList = {}
  self.groupState = ReturnV2TaskGroupState.ALL_COMPLETED
end



function ReturnV2MissionGroupViewModel:LoadData(missionGroupData, csMissionProgressDataList)
  if missionGroupData == nil or csMissionProgressDataList == nil then
    return
  end

  self.groupId = missionGroupData.groupId
  self.sortId = missionGroupData.sortId
  self.tabTitle = missionGroupData.tabTitle
  self.title = missionGroupData.title
  self.desc = missionGroupData.desc
  self.diffMissionCount = missionGroupData.diffMissionCount
  self.startTime = missionGroupData.startTime
  self.endTime = missionGroupData.endTime
  self.imageId = missionGroupData.imageId
  self.iconId = missionGroupData.iconId
  
  self.missionList = {}
  local missionDataList = ToLuaArray(missionGroupData.missionList)
  self.groupState = ReturnV2TaskGroupState.ALL_COMPLETED
  local missionProgressDataList = ToLuaArray(csMissionProgressDataList)
  if missionProgressDataList ~= nil and #missionProgressDataList ~= 0 then
    for idx = 1, #missionProgressDataList do
      local missionProgressData = missionProgressDataList[idx]
      local missionData = self:_GetMissionData(missionDataList, missionProgressData.missionId)
      if missionData ~= nil then
        local mission = ReturnV2MissionViewModel:new()
        mission:InitData(missionData)
        mission:RefreshData(missionProgressData)
        table.insert(self.missionList, mission)

        if mission.state == ReturnV2TaskState.TASK_CAN_CLAIM then
          self.groupState = ReturnV2TaskGroupState.HAVE_REWARD
        elseif self.groupState ~= ReturnV2TaskGroupState.HAVE_REWARD and mission.state == ReturnV2TaskState.TASK_DOING then
          self.groupState = ReturnV2TaskGroupState.UNCOMPLETE
        end
      end
    end
  end

  self:_SortMissionList()
end




function ReturnV2MissionGroupViewModel:_GetMissionData(missionDataList, missionId)
  if missionDataList == nil then
    return
  end

  for idx = 1, #missionDataList do 
    local missionData = missionDataList[idx]
    if missionId == missionData.missionId then
      return missionData
    end
  end
  return nil
end

function ReturnV2MissionGroupViewModel:RefreshMissionPlayerData()
  self.groupState = ReturnV2TaskGroupState.ALL_COMPLETED
  local csMissionProgressDataList = ReturnV2Model.me:GetReturnV2MissionPlayerData(self.groupId)
  local missionProgressDataList = nil
  if csMissionProgressDataList ~= nil then
    missionProgressDataList = ToLuaArray(csMissionProgressDataList)
  end
  if missionProgressDataList ~= nil and #missionProgressDataList ~= 0 then
    for idx = 1, #missionProgressDataList do
      local missionProgressData = missionProgressDataList[idx]
      local missionModel = self:_GetMissionModel(missionProgressData.missionId)
      if missionModel ~= nil then
        missionModel:RefreshData(missionProgressData)

        if missionModel.state == ReturnV2TaskState.TASK_CAN_CLAIM then
          self.groupState = ReturnV2TaskGroupState.HAVE_REWARD
        elseif self.groupState ~= ReturnV2TaskGroupState.HAVE_REWARD and missionModel.state == ReturnV2TaskState.TASK_DOING then
          self.groupState = ReturnV2TaskGroupState.UNCOMPLETE
        end
      end
    end
  end

  self:_SortMissionList()
end


function ReturnV2MissionGroupViewModel:_GetMissionModel(missionId)
  if self.missionList == nil then
    return nil
  end

  for idx = 1, #self.missionList do
    local missionModel = self.missionList[idx]
    if missionModel.missionId == missionId then
      return missionModel
    end
  end
  return nil
end


function ReturnV2MissionGroupViewModel:GetDisplayMission()
  if self.missionList and #self.missionList > 0 then
    return self.missionList[1]
  end
  return nil
end

function ReturnV2MissionGroupViewModel:_SortMissionList()
  if self.missionList == nil then
    return
  end

  table.sort(self.missionList, function(a,b)
    if a.sortState ~= b.sortState then
      return a.sortState < b.sortState
    elseif a.sortId ~= b.sortId then
      return a.sortId < b.sortId
    end
    return a.missionId < b.missionId
  end)
end

function ReturnV2MissionGroupViewModel:CanOpenMissionList()
  return self.missionList and #self.missionList > 1
end

function ReturnV2MissionGroupViewModel:HasClickedMissionGroupTab()
  local currentData = CS.Torappu.PlayerData.instance.data.backflow.currentV2;
  if not currentData then
    return true;
  end
  if self.m_hasClicked == nil then
    local userClickCache = CS.Torappu.PlayerPrefsWrapper.GetUserInt(CLICKED_MISSION_GROUP_FLAG .. currentData.start .. self.groupId, 0);
    self.m_hasClicked = userClickCache == 1;
  end
  return self.m_hasClicked;
end


function ReturnV2MissionGroupViewModel:SetMissionGroupTabClicked(value)
  if self.m_hasClicked and self.m_hasClicked == value then
    return;
  end

  local currentData = CS.Torappu.PlayerData.instance.data.backflow.currentV2;
  if not currentData then
    return;
  end
  local flag = 1;
  if value == true then
    flag = 1;
  else
    flag = 0;
  end
  CS.Torappu.PlayerPrefsWrapper.SetUserInt(CLICKED_MISSION_GROUP_FLAG .. currentData.start .. self.groupId, flag);
  self.m_hasClicked = value;
end

return ReturnV2MissionGroupViewModel