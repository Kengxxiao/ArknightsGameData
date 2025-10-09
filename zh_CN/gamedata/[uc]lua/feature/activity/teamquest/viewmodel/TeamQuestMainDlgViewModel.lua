local luaUtils = CS.Torappu.Lua.Util
local TeamQuestMilestoneViewModel = require("Feature/Activity/TeamQuest/ViewModel/TeamQuestMilestoneViewModel")
local TeamQuestMissionViewModel = require("Feature/Activity/TeamQuest/ViewModel/TeamQuestMissionViewModel")
local TeamQuestTeammateViewModel = require("Feature/Activity/TeamQuest/ViewModel/TeamQuestTeammateViewModel")









local TeamQuestTabViewModel  = Class("TeamQuestTabViewModel", nil)


function TeamQuestTabViewModel:InitData(tabType)
  self.tabType = tabType
  if tabType == TeamQuestTabType.MILESTONE then
    self.tabName = I18NTextRes.ACT_TEAMQUEST_COMMON_ACT_TEAMQUEST_AWARD
  elseif tabType == TeamQuestTabType.MISSION then
    self.tabName = I18NTextRes.ACT_TEAMQUEST_COMMON_ACT_TEAMQUEST_QUEST
  elseif tabType == TeamQuestTabType.TEAM then
    self.tabName = I18NTextRes.ACT_TEAMQUEST_COMMON_ACT_TEAMQUEST_TEAM
  end
end


function TeamQuestTabViewModel:CheckHasTrackPoint(mainViewModel)
  
  local type = self.tabType
  if type == TeamQuestTabType.TEAM then
    return mainViewModel.isNewInvite
  elseif type == TeamQuestTabType.MISSION then
    return mainViewModel.isNewMission
  elseif type == TeamQuestTabType.MILESTONE  then
    return mainViewModel.isNewMilestone
  end
  return false
end




























local TeamQuestMainDlgViewModel = Class("TeamQuestMainDlgViewModel", UIViewModel)



function TeamQuestMainDlgViewModel:InitData(actId)
  local actDBData = CS.Torappu.ActivityDB.data
  if actDBData == nil or actDBData.dynActs == nil then
    return
  end

  local suc, basicData = actDBData.basicInfo:TryGetValue(actId)
  if not suc then
    return
  end
  self.endTime = basicData.rewardEndTime

  local suc1, jObject = actDBData.dynActs:TryGetValue(actId)
  if not suc1 then
    LogError("[TeamQuest]Can't find the activity data: " .. actId)
    return
  end

  local actData = luaUtils.ConvertJObjectToLuaTable(jObject)
  self.actId = actId

  if actData.constData ~= nil then
    self.themeColor = actData.constData.themeColor
    self.teamSlotCnt = actData.constData.teamSlotCnt
    self.milestoneItemId = actData.constData.milestoneItemId
    self.m_inviteFormatStr = actData.constData.inviteFormatStr
  end

  self.tabList = {}
  for tabName, tabVal in pairs(TeamQuestTabType) do
    local tabModel = TeamQuestTabViewModel.new()
    tabModel:InitData(tabVal)
    table.insert(self.tabList, tabModel)
  end
  table.sort(self.tabList, function (t1, t2)
    return t1.tabType < t2.tabType
  end)

  self.milestoneList = {}
  for _, milestoneData in ipairs(actData.milestoneList) do
    local milestoneModel = TeamQuestMilestoneViewModel.new()
    milestoneModel:InitData(milestoneData)
    table.insert(self.milestoneList, milestoneModel)
  end
  table.sort(self.milestoneList, function (m1, m2)
    return m1.level < m2.level
  end)

  self.missionList = {}
  for _, missionData in ipairs(actData.missionList) do
    local missionModel = TeamQuestMissionViewModel.new()
    missionModel:InitData(missionData)
    table.insert(self.missionList, missionModel)
  end

  self:_RefreshPlayerData()

  if self.isNewMilestone and not self.isNewMission then
      self.selectTabType = TeamQuestTabType.MILESTONE
  else
      self.selectTabType = TeamQuestTabType.MISSION
  end
end

function TeamQuestMainDlgViewModel:ClearShowDetailMateInfo()
  self.showDetailMateId = nil
  self.showDetailMatePos = nil
end

function TeamQuestMainDlgViewModel:RefreshPlayerData()
  self:_RefreshPlayerData()
end


function TeamQuestMainDlgViewModel:RefreshTeammateList(rsp)
  self.mateModelDict = {}
  self.mateNameCardRspDict = {}

  if rsp == nil or rsp.players == nil then
    return
  end
  for index, mateId in ipairs(self.mateIdList) do
    local mateInfo = rsp.players[index]
    local friendStatus = rsp.friendStatusList[index]
    if mateInfo == nil or friendStatus == nil then
      break
    end
    
    local mateModel = TeamQuestTeammateViewModel.new()
    mateModel:LoadData(mateInfo, friendStatus)
    self.mateModelDict[mateId] = mateModel
  end
end

function TeamQuestMainDlgViewModel:_RefreshPlayerData()
  local playerData = CS.Torappu.PlayerData.instance.data
  if playerData == nil then
    return
  end

  self.myUid = luaUtils.GetUid()

  local playerActs = playerData.activity.teamQuestActivityList
  if playerActs == nil then
    LogError("[ActTeamQuest] Cannot load player data.")
    return
  end

  local suc, jObject = playerActs:TryGetValue(self.actId)
  if not suc then
    LogError("[ActTeamQuest] Cannot load player data.")
    return
  end

  local playerData = luaUtils.ConvertJObjectToLuaTable(jObject)
  if playerData == nil then
    return
  end

  if playerData.milestone ~= nil then
    self.milestoneItemCnt = playerData.milestone.point
  end

  self.isNewMilestone = false
  self.isMilestoneFinished = true
  for _, milestoneModel in ipairs(self.milestoneList) do
    milestoneModel:RefreshPlayerData(playerData)

    local avail = milestoneModel.statusType == TeamQuestMilestoneStatusType.AVAIL
    local notComplete = avail or milestoneModel.statusType == TeamQuestMilestoneStatusType.UNCOMPLETE
    if avail then
      self.isNewMilestone = true
    end
    if notComplete then
      self.isMilestoneFinished = false
    end
  end

  self.isNewMission = false
  for _, missionModel in ipairs(self.missionList) do
    missionModel:RefreshPlayerData(playerData)
    if missionModel.statusType == TeamQuestMissionStatusType.AVAIL then
      self.isNewMission = true
    end
  end
  table.sort(self.missionList, function(m1, m2)
    if m1.statusType ~= m2.statusType then
      return m1.statusType < m2.statusType
    end
    return m1.sortId < m2.sortId
  end)

  self.inviteCode = playerData.team ~= nil and playerData.team.teamId or ""

  local isInTeam = playerData.team ~= nil and playerData.team.member ~= nil and #playerData.team.member > 1
  local leaveTs = 0
  self.mateIdList = {}
  if isInTeam then
    for _, mateId in ipairs(playerData.team.member) do
      table.insert(self.mateIdList, mateId)
    end
    leaveTs = playerData.team.leaveTs
  end
  self.m_isInTeam = isInTeam
  self.m_leaveTs = leaveTs

  self.isNewInvite = (not isInTeam) and luaUtils.CheckHasActivityNewInvite(self.actId)
  self.isUncomplete = self.isNewMission or self.isNewMilestone or self.isNewInvite
end


function TeamQuestMainDlgViewModel:HasPendingLeave()
  return self.m_leaveTs ~= nil and self.m_leaveTs > 0
end

function TeamQuestMainDlgViewModel:IsInTeam()
  return self.m_isInTeam
end


function TeamQuestMainDlgViewModel:CheckIfMateChanged()
  if not self:IsInTeam() then
    return false
  end

  if self.mateModelDict == nil then
    return true
  end

  for _, mateId in ipairs(self.mateIdList) do
    if self.mateModelDict[mateId] == nil then
      return true
    end
  end
  return false
end


function TeamQuestMainDlgViewModel:UpdateInputInviteCode(inputVal)
  local isSucc, inviteCode = luaUtils.TryExtractInviteCode(inputVal)
  if not isSucc then
    inviteCode = inputVal
  end
  self.inputInviteCode = inviteCode
end


function TeamQuestMainDlgViewModel:GetInviteFormatStr()
  if string.isNullOrEmpty(self.m_inviteFormatStr) or string.isNullOrEmpty(self.inviteCode) then
    return ""
  end

  local playerData = CS.Torappu.PlayerData.instance.data
  if playerData == nil or playerData.status == nil then
    return
  end

  local playerStatus = playerData.status
  return luaUtils.Format(self.m_inviteFormatStr, self.inviteCode, playerStatus.nickName, playerStatus.nickNumber)
end


function TeamQuestMainDlgViewModel:HasMilestoneAvail()
  for _, milestoneModel in ipairs(self.milestoneList) do
    if milestoneModel.statusType == TeamQuestMilestoneStatusType.AVAIL then
      return true
    end
  end
  return false
end


function TeamQuestMainDlgViewModel:HasMissionAvail()
  for _, missionModel in ipairs(self.missionList) do
    if missionModel.statusType == TeamQuestMissionStatusType.AVAIL then
      return true
    end
  end
  return false
end

return TeamQuestMainDlgViewModel