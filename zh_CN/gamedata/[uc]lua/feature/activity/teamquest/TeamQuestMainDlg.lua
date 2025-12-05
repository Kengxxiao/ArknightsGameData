








































local luaUtils = CS.Torappu.Lua.Util
local TeamQuestMainDlgViewModel = require("Feature/Activity/TeamQuest/ViewModel/TeamQuestMainDlgViewModel")
local TeamQuestMainDlgView = require("Feature/Activity/TeamQuest/TeamQuestMainDlgView")
local TeamQuestRecordView = require("Feature/Activity/TeamQuest/TeamRecord/TeamQuestRecordView")
local TeamQuestUtil = require("Feature/Activity/TeamQuest/TeamQuestUtil")

local REFRESH_INFO_COOLDOWN = 5 
local TAB_DIALOG_INVITE = "invite"
local TAB_DIALOG_RECEIVE_INVITED = "receive_invited"
local CLS_INVITE_DIALOG = CS.Torappu.UI.CommonInviteDialog.CommonInviteDialog
local CLS_TEXT_CONFIG = CLS_INVITE_DIALOG.TextConfig









TeamQuestMainDlg = Class("TeamQuestMainDlg", BridgeDlgBase)

function TeamQuestMainDlg:OnInit()
  self.m_view = self:CreateWidgetByGO(TeamQuestMainDlgView, self._view)
  self.m_view.onTabItemClick = Event.Create(self, self._EventOnTabItemClick)
  self.m_view.onMilestoneItemClick = Event.Create(self, self._EventOnMilestoneItemClick)
  self.m_view.onBtnAllMilestoneClick = Event.Create(self, self._EventOnGetAllMilestone)
  self.m_view.onMissionItemClick = Event.Create(self, self._EventOnMissionItemClick)
  self.m_view.onBtnAllMissionClick = Event.Create(self, self._EventOnGetAllMission)
  
  local teamViewInput = {}
  teamViewInput.onBtnCopyClick = Event.Create(self, self._EventOnBtnCopyCode)
  teamViewInput.onCodeInputValChanged = Event.Create(self, self._EventOnCodeInputValChanged)
  teamViewInput.onBtnJoinCodeClick = Event.Create(self, self._EventOnBtnJoinCode)
  teamViewInput.onBtnInviteFriend = Event.Create(self, self._EventOnBtnInviteFriend)
  teamViewInput.onBtnQuitTeamClick = Event.Create(self, self._EventOnBtnQuitTeamClick)
  teamViewInput.onMateDetailClick = Event.Create(self, self._EventOnMateDetailClick)
  teamViewInput.onBtnReceiveClick = Event.Create(self, self._EventOnBtnReceiveInvited)
  self.m_view.teamViewInput = teamViewInput
  
  local mateDetailViewInput = {}
  mateDetailViewInput.onBtnCloseClick = Event.Create(self, self._EventOnCloseMateDetail)
  mateDetailViewInput.onBtnRequestFriendClick = Event.Create(self, self._EventOnSendFriendReq)
  mateDetailViewInput.onBtnViewNameCard = Event.Create(self, self._EventOnViewNameCard)
  self.m_view.mateDetailViewInput = mateDetailViewInput
  self.m_view.onRecordItemClick = Event.Create(self, self._EventOnSendRecord)
  self.m_view.onToActClick = Event.Create(self, self._EventOnToAct)


  self.m_viewModel = self:CreateViewModel(TeamQuestMainDlgViewModel)
  local actId = self.m_parent:GetData("actId")
  self.m_viewModel:InitData(actId)
  self.m_viewModel:NotifyUpdate()

  self.m_judgeDialog = self:CreateCustomComponent(CSJudgeDialogHandle)
  self:_InitTabPager()
  self:_InitRefreshInfoWidget()

  self:_RequestData(TeamQuestServiceCode.REFRESH_INFO, Event.Create(self, function()
    self.m_viewModel:RefreshPlayerData()
    self.m_viewModel:NotifyUpdate()
  end))
end

function TeamQuestMainDlg:_InitTabPager()
  
  local inviteDialog = {}
  inviteDialog.dialogType = typeof(CLS_INVITE_DIALOG)
  inviteDialog.resPath = CS.Torappu.ResourceUrls.GetActMultiV3InviteDialogPath()
  inviteDialog.tabId = TAB_DIALOG_INVITE
  inviteDialog.inputFunc = self._InviteDialogInput

  
  local receiveInvitedDialog = {}
  receiveInvitedDialog.dialogType = typeof(CLS_INVITE_DIALOG)
  receiveInvitedDialog.resPath = CS.Torappu.ResourceUrls.GetActMultiV3InviteDialogPath()
  receiveInvitedDialog.tabId = TAB_DIALOG_RECEIVE_INVITED
  receiveInvitedDialog.inputFunc = self._ReceiveInvitedDialogInput
  receiveInvitedDialog.onTabCallback = self._HandleReceiveInvitedDialog

  
  local tabConfigs = { inviteDialog, receiveInvitedDialog } 
  
  local options = {}
  options.dlgHost = self.m_parent:UICompDialogHost()
  options.tabPager = self._compDlgPager
  self.m_tabPager = self:CreateCustomComponent(UITabPager, self, tabConfigs, options)
end

function TeamQuestMainDlg:_InitRefreshInfoWidget()
  
  local refreshInfoService = {}
  refreshInfoService.cacheExpireTime = REFRESH_INFO_COOLDOWN
  refreshInfoService.serviceFunc = Event.Create(self,self._SendRefreshInfoService)

  
  local config = {}
  config.serviceMappings = {}
  config.serviceMappings[TeamQuestServiceCode.REFRESH_INFO] = refreshInfoService
  
  self.m_dataRequest = self:CreateCustomComponent(DataRequestWidget, config)
end



function TeamQuestMainDlg:_RequestData(requestId, nextStep)
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  if not nextStep then
    return
  end
  if not self.m_dataRequest then
    nextStep:Call()
    return
  end
  self.m_dataRequest:RequestData(requestId, nextStep, false)
end



function TeamQuestMainDlg:_EventOnMateDetailClick(mateId, matePos)
  if self.m_viewModel == nil or self.m_viewModel.showDetailMateId ~= nil or string.isNullOrEmpty(mateId) then
    return
  end

  self.m_viewModel.showDetailMateId = mateId 
  self.m_viewModel.showDetailMatePos = matePos
  self.m_viewModel:NotifyUpdate()
end

function TeamQuestMainDlg:_EventOnCloseMateDetail()
  if self.m_viewModel == nil or string.isNullOrEmpty(self.m_viewModel.showDetailMateId) then
    return
  end

  self.m_viewModel:ClearShowDetailMateInfo()
  self.m_viewModel:NotifyUpdate()
end


function TeamQuestMainDlg:_EventOnViewNameCard(mateId)
  if self.m_viewModel == nil or string.isNullOrEmpty(mateId) then
    return
  end

  local nameCardRsp = self.m_viewModel.mateNameCardRspDict[mateId]
  if nameCardRsp ~= nil then
    self:_OpenFriendNameCard(nameCardRsp)
    return
  end

  if luaUtils.CheckCrossDaysAndResync() then
    return
  end

  UISender.me:SendRequest(CS.Torappu.Network.ServiceCode.GET_OTHER_PLAYER_NAME_CARD,
    {
      uid = mateId
    },
    {
      onProceed = Event.Create(self, self._HandleGetNameCardRsp, mateId),
      abortIfBusy = true
    })
end


function TeamQuestMainDlg:_HandleGetNameCardRsp(rsp, mateId)
  self:_OpenFriendNameCard(rsp)
  if self.m_viewModel ~= nil then
    self.m_viewModel.mateNameCardRspDict[mateId] = rsp
    self.m_viewModel:NotifyUpdate()
  end
end


function TeamQuestMainDlg:_OpenFriendNameCard(nameCardRsp)
  if self.m_viewModel ~= nil then
    self.m_viewModel:ClearShowDetailMateInfo()
    self.m_viewModel:NotifyUpdate()
  end

  if nameCardRsp == nil or nameCardRsp.nameCard == nil then
    return
  end

  local options = CS.Torappu.UI.UIPageOption()
  local nameCardParam = CS.Torappu.UI.Friend.NameCardDisplayPage.Params()
  nameCardParam.isSelf = false 
  nameCardParam.friendData = nameCardRsp.nameCard
  nameCardParam.friendData.registerTs = luaUtils.ToDateTime(nameCardRsp.nameCard.registerTs)
  options.args = nameCardParam
  self:OpenPage3(CS.Torappu.UI.UIPageNames.NAME_CARD_DISPLAY_PAGE, options)
end


function TeamQuestMainDlg:_EventOnSendFriendReq(mateId)
  if self.m_viewModel == nil or string.isNullOrEmpty(mateId) then
    return
  end

  local mateModel = self.m_viewModel.mateModelDict[mateId]
  if mateModel == nil then
    return
  end

  if mateModel.friendStatus == 1 then
    luaUtils.TextToast(I18NTextRes.ACT_TEAMQUEST_COMMON_ACT_TEAMQUEST_TOAST_FRIEND_SEND_FAIL_REPEAT)
    return
  end

  if mateModel.friendStatus == 2 then
    luaUtils.TextToast(I18NTextRes.ACT_TEAMQUEST_COMMON_ACT_TEAMQUEST_TOAST_FRIEND_ALREADY)
    return
  end

  if luaUtils.CheckCrossDaysAndResync() then
    return
  end

  UISender.me:SendRequest(CS.Torappu.Network.ServiceCode.SOCIAL_FRIEND_SEND_REQUEST,
    {
      friendId = mateModel.uid,
      afterBattle = 0,
      originType = 7
    },
    {
      onProceed = Event.Create(self, self._HandleSendFriendRsp, mateModel),
      abortIfBusy = true
    })
end



function TeamQuestMainDlg:_HandleSendFriendRsp(rsp, mateModel)
  if rsp.result == 0 or rsp.result == 2 then
    luaUtils.TextToast(I18NTextRes.ACT_TEAMQUEST_COMMON_ACT_TEAMQUEST_TOAST_FRIEND_SEND)
  elseif rsp.result == 1 then
    luaUtils.TextToast(StringRes.ALERT_FRIEND_FULL_CANNOT_SEND)
  end

  if mateModel ~= nil then
    if rsp.result == 0 then
      mateModel.friendStatus = 1
    end
    self.m_viewModel:ClearShowDetailMateInfo()
    self.m_viewModel:NotifyUpdate()
  end
end


function TeamQuestMainDlg:_EventOnTabItemClick(tabType)
  if self.m_viewModel == nil or self.m_viewModel.tabList == nil then
    return
  end

  if self.m_viewModel.selectTabType == tabType then
    return
  end

  local targetModel = nil
  for _, tabModel in ipairs(self.m_viewModel.tabList) do
    if tabModel.tabType == tabType then
      targetModel = tabModel
      break
    end
  end

  if targetModel == nil then
    return
  end

  self:_RequestData(TeamQuestServiceCode.REFRESH_INFO, Event.Create(self, function()
    local callback = Event.Create(self, function()
      self.m_viewModel.selectTabType = targetModel.tabType
      self.m_viewModel:NotifyUpdate()
    end)
    self:_TryFetchPlayerAndRefresh(callback)
  end))
end

function TeamQuestMainDlg:_EventOnBtnCopyCode()
  if self.m_viewModel == nil then
    return
  end

  local codeStr = self.m_viewModel:GetInviteFormatStr()
  if string.isNullOrEmpty(codeStr) then
    return
  end

  CS.Torappu.EventTrack.EventLogTrace.instance:EventOnInviteClicked(
  self.m_viewModel.actId,self.m_viewModel.inviteCode,#self.m_viewModel.mateIdList + 1)

  luaUtils.SetNativeClipboard(codeStr)
  luaUtils.TextToast(I18NTextRes.ACT_TEAMQUEST_COMMON_ACT_TEAMQUEST_TOAST_COPY_SUCCESS)
end


function TeamQuestMainDlg:_EventOnCodeInputValChanged(inputVal)
  if self.m_viewModel == nil then
    return
  end

  self.m_viewModel:UpdateInputInviteCode(inputVal)
  self.m_viewModel:NotifyUpdate()
end

function TeamQuestMainDlg:_EventOnBtnJoinCode()
  if self.m_viewModel == nil then
    return
  end

  if luaUtils.CheckCrossDaysAndResync() then
    return
  end

  if self.m_viewModel.inputInviteCode == string.lower(self.m_viewModel.inviteCode) then
    luaUtils.TextToast(I18NTextRes.ACT_TEAMQUEST_COMMON_ACT_TEAMQUEST_TOAST_JOIN_FAIL_MYSELF)
    return
  end

  if not luaUtils.CheckIfInviteCodeValid(self.m_viewModel.inputInviteCode) then
    luaUtils.TextToast(I18NTextRes.ACT_TEAMQUEST_COMMON_ACT_TEAMQUEST_TOAST_JOIN_FAIL_ILLEGAL)
    return
  end

  UISender.me:SendRequest(TeamQuestServiceCode.JOIN_TEAM, 
    {
      activityId = self.m_viewModel.actId,
      teamId = self.m_viewModel.inputInviteCode
    },
    {
      onProceed = Event.Create(self, self._HandleJoinTeamRsp),
      abortIfBusy = true
    })
end




function TeamQuestMainDlg:_HandleReceiveInvitedDialog(valueBundle)
  
  local output = valueBundle.objVal
  if output == nil or output.msg == nil or output.msg.Count <= 0 then
    
    self:_RefreshPlayerData()
    return nil
  end
  local dlgLock = KeepWaiting.new()
  local teamId = output.msg[0]
  UISender.me:SendRequest(TeamQuestServiceCode.JOIN_TEAM, 
    {
      activityId = self.m_viewModel.actId,
      teamId = teamId
    },
    {
      onProceed = Event.Create(self, self._HandleJoinTeamRsp),
      awaiter = dlgLock
    })
  return dlgLock
end

function TeamQuestMainDlg:_EventOnBtnInviteFriend()
  if luaUtils.CheckCrossDaysAndResync() or self.m_viewModel == nil then
    return
  end
  self.m_tabPager:SelectTab(TAB_DIALOG_INVITE)
end

function TeamQuestMainDlg:_EventOnBtnReceiveInvited()
  if luaUtils.CheckCrossDaysAndResync() or self.m_viewModel == nil then
    return
  end
  self.m_tabPager:SelectTab(TAB_DIALOG_RECEIVE_INVITED)
end

function TeamQuestMainDlg:_EventOnBtnQuitTeamClick()
  if self.m_viewModel == nil or not self.m_viewModel:IsInTeam() then
    return
  end

  if self.m_viewModel:HasPendingLeave() then
    self:_SendQuitTeamRequest()
  else
    
    local judgeConfig = {}
    judgeConfig.descText = I18NTextRes.ACT_TEAMQUEST_COMMON_ACT_TEAMQUEST_TOAST_LEAVE_CONFIRM
    judgeConfig.positiveText = I18NTextRes.ACT_TEAMQUEST_COMMON_CONFIRM
    judgeConfig.negativeText = I18NTextRes.ACT_TEAMQUEST_COMMON_CANCEL
    judgeConfig.onPositive = Event.Create(self, self._SendQuitTeamRequest)
    self.m_judgeDialog:ShowDialog(judgeConfig)
  end
end

function TeamQuestMainDlg:_SendQuitTeamRequest()
  if luaUtils.CheckCrossDaysAndResync() then
    return
  end

  UISender.me:SendRequest(TeamQuestServiceCode.QUIT_TEAM,
    {
      activityId = self.m_viewModel.actId,
      operate = self.m_viewModel:HasPendingLeave() and 0 or 1
    },
    {
      onProceed = Event.Create(self, self._HandleQuitTeamRsp)
  })
end


function TeamQuestMainDlg:_HandleQuitTeamRsp(rsp)
  if rsp.result == 1 then
    luaUtils.TextToast(I18NTextRes.ACT_TEAMQUEST_COMMON_ACT_TEAMQUEST_TOAST_FREQUENT_BAN, false)
  elseif rsp.result == 2 then 
    luaUtils.TextToast(I18NTextRes.ACT_TEAMQUEST_COMMON_ACT_TEAMQUEST_TOAST_LEAVE_ILLEGAL, false)
  end

  self.m_viewModel:RefreshPlayerData()
  self.m_viewModel:NotifyUpdate()
end
function TeamQuestMainDlg:_EventOnGetAllMission()
  if luaUtils.CheckCrossDaysAndResync() then
    return
  end

  if self.m_viewModel == nil then
    return
  end

  if not self.m_viewModel:HasMissionAvail() then
    return
  end

  local missionIdList = {}

  local funcRec = function()
    self:_SendConfirmMissionReq(self.m_viewModel.actId, missionIdList)
  end

  for _, missionModel in ipairs(self.m_viewModel.missionList) do
    if missionModel.statusType == TeamQuestMissionStatusType.AVAIL then
      table.insert(missionIdList, missionModel.id)
    end
  end

  if (#self.m_viewModel.mateIdList <= 1) then
    CS.Torappu.UI.UIJudgeDialogWrapper.OpenSimpleNoNextTimeCheckJudgeDialog(I18NTextRes.ACT_TEAMQUEST_COMMON_ACT_TEAMQUEST_QUEST_GET_HINT,
     funcRec , self:GetHintId())
  else
    funcRec()
  end
end


function TeamQuestMainDlg:_EventOnMissionItemClick(missionId)
  if luaUtils.CheckCrossDaysAndResync() then
    return
  end

  if string.isNullOrEmpty(missionId) then
    return
  end

  if self.m_viewModel == nil or self.m_viewModel.missionList == nil then
    return
  end

  local targetMissionModel = nil
  for _, missionModel in ipairs(self.m_viewModel.missionList) do
    if missionModel.id == missionId then
      targetMissionModel = missionModel
      break
    end
  end

  if targetMissionModel == nil then
    return
  end

  local missionIdList = {}
  table.insert(missionIdList, missionId)
  
  local funcRec = function()
    self:_SendConfirmMissionReq(self.m_viewModel.actId, missionIdList)
  end

  if (#self.m_viewModel.mateIdList <= 1) then
    CS.Torappu.UI.UIJudgeDialogWrapper.OpenSimpleNoNextTimeCheckJudgeDialog(I18NTextRes.ACT_TEAMQUEST_COMMON_ACT_TEAMQUEST_QUEST_GET_HINT
    , funcRec ,self:GetHintId())
  else
    funcRec()
  end
end

function TeamQuestMainDlg:GetHintId()
  return luaUtils.Format("{0}_{1}",self.m_viewModel.actId , "requestHint")
end



function TeamQuestMainDlg:_SendConfirmMissionReq(actId, missionIdList)
  if string.isNullOrEmpty(actId) then
    return
  end

  if missionIdList == nil or #missionIdList == 0 then
    return
  end

  UISender.me:SendRequest(TeamQuestServiceCode.CONFIRM_MISSION_LIST, 
    {
      activityId = self.m_viewModel.actId,
      missionIds = missionIdList
    },
    {
      onProceed = Event.Create(self, self._HandleGetItemsRsp),
      abortIfBusy = true
    })
end


function TeamQuestMainDlg:_SendRefreshInfoService(callback)
  
  UISender.me:SendRequest(TeamQuestServiceCode.REFRESH_INFO,
    {
      activityId = self.m_viewModel.actId
    },
    {
      onProceed = callback
    })
end

function TeamQuestMainDlg:_EventOnGetAllMilestone()
  if luaUtils.CheckCrossDaysAndResync() then
    return
  end

  if self.m_viewModel == nil or string.isNullOrEmpty(self.m_viewModel.actId) then
    return
  end

  if not self.m_viewModel:HasMilestoneAvail() then
    return
  end

  UISender.me:SendRequest(TeamQuestServiceCode.GET_ALL_MILESTONE,
  {
    activityId = self.m_viewModel.actId,
  },
  {
    onProceed = Event.Create(self, self._HandleGetItemsRsp),
    abortIfBusy = true
  })
end


function TeamQuestMainDlg:_EventOnMilestoneItemClick(milestoneId)
  if luaUtils.CheckCrossDaysAndResync() then
    return
  end

  if string.isNullOrEmpty(milestoneId) then
    return
  end

  if self.m_viewModel == nil or self.m_viewModel.milestoneList == nil then
    return
  end

  local targetModel = nil
  for _, milestoneModel in ipairs(self.m_viewModel.milestoneList) do
    if milestoneModel.id == milestoneId then
      targetModel = milestoneModel
      break
    end
  end

  if targetModel == nil then
    return
  end

  UISender.me:SendRequest(TeamQuestServiceCode.GET_MILESTONE,
  {
    activityId = self.m_viewModel.actId,
    milestoneId = milestoneId
  },
  {
    onProceed = Event.Create(self, self._HandleGetItemsRsp),
    abortIfBusy = true
  })
end


function TeamQuestMainDlg:_HandleGetItemsRsp(response)
  print(#response.items)
  local handler = CS.Torappu.UI.LuaUIMisc.ShowGainedItems(response.items,
    CS.Torappu.UI.UIGainItemFloatPanel.Style.DEFAULT,
    function()
      self:_RefreshPlayerData()
    end)
    self:_AddDisposableObj(handler)
end


function TeamQuestMainDlg:_HandleJoinTeamRsp(rsp)
  local result = rsp and rsp.result
  if result == 1 then
    luaUtils.TextToast(I18NTextRes.ACT_TEAMQUEST_COMMON_ACT_TEAMQUEST_TOAST_FREQUENT_BAN, false)
  elseif result == 2 then
    luaUtils.TextToast(I18NTextRes.ACT_TEAMQUEST_COMMON_ACT_TEAMQUEST_TOAST_SEARCH_BAN, false)
  elseif result == 3 then
    luaUtils.TextToast(I18NTextRes.ACT_TEAMQUEST_COMMON_ACT_TEAMQUEST_TOAST_JOIN_FAIL_MYSELF, false)
  elseif result == 4 then
    luaUtils.TextToast(I18NTextRes.ACT_TEAMQUEST_COMMON_ACT_TEAMQUEST_TOAST_JOIN_FAIL_ILLEGAL, false)
  elseif result == 5 then
    luaUtils.TextToast(I18NTextRes.ACT_TEAMQUEST_COMMON_ACT_TEAMQUEST_TOAST_JOIN_FAIL_FULL, false)
  elseif result == 6 then
    luaUtils.TextToast(I18NTextRes.ACT_TEAMQUEST_COMMON_ACT_TEAMQUEST_TOAST_JOIN_FAIL_INTEAM, false)
  end
  self:_TryFetchPlayerAndRefresh(nil)
end


function TeamQuestMainDlg:_TryFetchPlayerAndRefresh(callback)
  self.m_viewModel:RefreshPlayerData()

  if self.m_viewModel:CheckIfMateChanged() then
    local onRsp = Event.Create(self, self._OnSearchPlayerRsp, callback)
    self:_SendSearchPlayerService(onRsp)
  else
    self.m_viewModel:NotifyUpdate()
    if callback ~= nil then
      callback:Call()
    end
  end
end


function TeamQuestMainDlg:_SendSearchPlayerService(callback)
  if luaUtils.CheckCrossDaysAndResync() then
    return
  end

  if self.m_viewModel == nil or self.m_viewModel.mateIdList == nil then
    return
  end

  UISender.me:SendRequest(CS.Torappu.Network.ServiceCode.SOCIAL_FRIEND_SEARCH_FRIEND,
    {
      idList = self.m_viewModel.mateIdList
    },
    {
      onProceed = callback
    })
end



function TeamQuestMainDlg:_OnSearchPlayerRsp(rsp, callback)
  if self.m_viewModel == nil then
    return
  end
  self.m_viewModel:RefreshTeammateList(rsp)
  self.m_viewModel:NotifyUpdate()
  if callback ~= nil then
    callback:Call()
  end
end

function TeamQuestMainDlg:_RefreshPlayerData()
  if self.m_viewModel == nil then
    return
  end

  self.m_viewModel:RefreshPlayerData()
  self.m_viewModel:NotifyUpdate()
end


function TeamQuestMainDlg:_InviteDialogInput()
  
  local input = self:_CreateBasicInviteDialogInput(true)
  return input
end


function TeamQuestMainDlg:_ReceiveInvitedDialogInput()
  
  local input = self:_CreateBasicInviteDialogInput(false)
  return input
end



function TeamQuestMainDlg:_CreateBasicInviteDialogInput(isInvite)
  
  local input = CS.Torappu.Activity.TeamQuest.TeamQuestLuaUtils.CreateBasicInviteDialogInput(isInvite)
  input.targetId = self.m_viewModel.actId
  input.excludePlayers = ToCSArray(self.m_viewModel.mateIdList, typeof(CS.System.String))
  
  local textConfig = CLS_TEXT_CONFIG()
  textConfig.inviteSendToast = I18NTextRes.ACT_TEAMQUEST_COMMON_ACT_TEAMQUEST_TOAST_INVITE_SEND
  textConfig.afterInviteSendToast = I18NTextRes.ACT_TEAMQUEST_COMMON_ACT_TEAMQUEST_TOAST_INVITE_FAIL_REPEAT
  textConfig.inviteFullToast = I18NTextRes.ACT_TEAMQUEST_COMMON_ACT_TEAMQUEST_TOAST_INVITE_FAIL_FULL
  textConfig.startReceiveInviteToast = I18NTextRes.ACT_TEAMQUEST_COMMON_ACT_TEAMQUEST_TOAST_ALLOWINVITE_ACTIVE
  textConfig.stopReceiveInviteToast = I18NTextRes.ACT_TEAMQUEST_COMMON_ACT_TEAMQUEST_TOAST_ALLOWINVITE_INACTIVE
  textConfig.tooFastToast = I18NTextRes.ACT_TEAMQUEST_COMMON_ACT_TEAMQUEST_TOAST_FREQUENT_BAN
  textConfig.inviteTitle = I18NTextRes.ACT_TEAMQUEST_COMMON_INVITE_DIALOG_TITLE
  textConfig.inviteInvalidToast = I18NTextRes.ACT_TEAMQUEST_COMMON_INVITE_INVALID_TOAST
  textConfig.receiveTitle = I18NTextRes.ACT_TEAMQUEST_COMMON_RECEIVE_INVITE_TITLE
  textConfig.receiveSetting = I18NTextRes.ACT_TEAMQUEST_COMMON_INVITE_DIALOG_SETTING
  textConfig.inviteEmpty = I18NTextRes.ACT_TEAMQUEST_COMMON_INVITE_DIALOG_EMPTY 
  textConfig.receiveEmpty = I18NTextRes.ACT_TEAMQUEST_COMMON_RECEIVE_INVITE_EMPTY
  textConfig.alreadyInRoom = I18NTextRes.ACT_TEAMQUEST_COMMON_INVITE_ALREADY_IN_TEAM
  input.textConfig = textConfig
  return input
end

function TeamQuestMainDlg:_EventOnSendRecord()
  local actId = self.m_parent:GetData("actId")
  local playerData = TeamQuestUtil.GetPlayerData(actId)

  UISender.me:SendRequest("/social/searchPlayer", 
  {idList =playerData.team.member
  }, 
  {
    onProceed = Event.Create(self, self._OpenRecordPanel);
  }
)
end

function TeamQuestMainDlg:_EventOnToAct()
  local actId = self.m_parent:GetData("actId")
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
  CS.Torappu.UI.UIRouteUtil.RouteToStageActivity(actData.constData.targetId)
end

function TeamQuestMainDlg:_OpenRecordPanel(rsp)
  local actId = self.m_parent:GetData("actId")
  local dlg = self:GetGroup():AddChildDlg(TeamQuestRecordView);
  dlg:Flush(actId,rsp);
end