local TeamQuestTeammateItemView = require("Feature/Activity/TeamQuest/View/TeamQuestTeammateItemView")












local luaUtils = CS.Torappu.Lua.Util






































local TeamQuestTeamView = Class("TeamQuestTeamView", UIPanel)


function TeamQuestTeamView:Init(input)
  self.m_input = input

  self:AddButtonClickListener(self._btnCopyCode, function()
    local callback = self.m_input.onBtnCopyClick
    if callback then
      callback:Call()
    end
  end)

  self:AddButtonClickListener(self._btnJoinCode, function()
    local callback = self.m_input.onBtnJoinCodeClick
    if callback then
      callback:Call()
    end
  end)

  self:AddButtonClickListener(self._btnInviteFriend, function() 
    local callback = self.m_input.onBtnInviteFriend
    if callback then
      callback:Call()
    end
  end)
  
  self:AddButtonClickListener(self._btnCopyTeamCode, function()
    local callback = self.m_input.onBtnCopyClick
    if callback then
      callback:Call()
    end
  end)

  self:AddButtonClickListener(self._btnQuitTeam, function()
    local callback = self.m_input.onBtnQuitTeamClick
    if callback then
      callback:Call()
    end
  end)

  self:AddButtonClickListener(self._btnReceiveInvited, function()
    local callback = self.m_input.onBtnReceiveClick
    if callback then
      callback:Call()
    end
  end)
  
  self:AddInputFieldListener(self._inviteCodeInput, self._EventOnInputCodeChanged)

  self.m_teammateListAdapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, 
    self._teammateList, self._CreateTeammateItem, self._GetTeamSize, self._UpdateTeammateItemView)
end


function TeamQuestTeamView:Render(viewModel)
  if viewModel == nil then
    return
  end
  self.m_viewModel = viewModel

  local isInTeam = viewModel:IsInTeam()
  SetGameObjectActive(self._joinTeamPanelGO, not isInTeam)
  SetGameObjectActive(self._inTeamPanelGO, isInTeam)
  if isInTeam then
    self:_RenderInTeamPanel(viewModel)
  else
    self:_RenderJoinTeamPanel(viewModel)
  end
end


function TeamQuestTeamView:_RenderInTeamPanel(viewModel)
  self:_SetTeamPanelColor(viewModel)
  self._textTeamInviteCode.text = viewModel.inviteCode
  self._btnQuitTeam.interactable = not viewModel:HasPendingLeave()

  if self.m_teammateListAdapter ~= nil then
    self.m_teammateListAdapter:NotifyDataSetChanged()
  end
end


function TeamQuestTeamView:_RenderJoinTeamPanel(viewModel)
  self:_SetJoinPanelColor(viewModel)
  self._textInviteCode.text = viewModel.inviteCode
  self._inviteCodeInput.text = viewModel.inputInviteCode

  local isBtnJoinCodeDisable = string.isNullOrEmpty(viewModel.inputInviteCode)
  self._btnJoinCode.enabled = not isBtnJoinCodeDisable
  SetGameObjectActive(self._btnJoinCodeDisableMask, isBtnJoinCodeDisable)
  luaUtils.SetActiveIfNecessary(self._goTrackInvited, viewModel.isNewInvite)
end


function TeamQuestTeamView:_SetJoinPanelColor(viewModel)
  local colorTheme = luaUtils.FormatColorFromData(viewModel.themeColor)
  luaUtils.SetColorWithoutAlpha(self._bgThemeInvite, colorTheme)
  luaUtils.SetColorWithoutAlpha(self._bgThemeJoin, colorTheme)
  self._textInviteCaption.color = colorTheme
  self._textJoinCaption.color = colorTheme
  self._iconInviteCode.color = colorTheme
  self._iconInviteFriend.color = colorTheme
  self._iconJoinCode.color = colorTheme
  self._iconJoinFriend.color = colorTheme
  self._bgBtnInviteCode.color = colorTheme
  self._bgBtnInviteFriend.color = colorTheme
  self._bgBtnJoinCode.color = colorTheme
  self._bgBtnJoinFriend.color = colorTheme
end


function TeamQuestTeamView:_SetTeamPanelColor(viewModel)
  local colorTheme = luaUtils.FormatColorFromData(viewModel.themeColor)
  luaUtils.SetColorWithoutAlpha(self._iconTeam, colorTheme)
  luaUtils.SetColorWithoutAlpha(self._bgThemeTeam, colorTheme)
  self._bgBtnCopyTeamCode.color = colorTheme
end

function TeamQuestTeamView:_EventOnBtnCopyCode()
  if self.m_onBtnCopyCodeClick == nil then
    return
  end
  self.m_onBtnCopyCodeClick:Call()
end


function TeamQuestTeamView:_EventOnInputCodeChanged(inputStr)
  local callback = self.m_input.onCodeInputValChanged
  if callback then
    callback:Call(inputStr)
  end
end



function TeamQuestTeamView:_CreateTeammateItem(viewObj)
  local itemView = self:CreateWidgetByGO(TeamQuestTeammateItemView, viewObj)
  return itemView
end


function TeamQuestTeamView:_GetTeamSize()
  if self.m_viewModel == nil then
    return 0
  end
  return self.m_viewModel.teamSlotCnt
end



function TeamQuestTeamView:_UpdateTeammateItemView(csIndex, itemView)
  local mateId = self.m_viewModel.mateIdList[csIndex+1]
  
  local mateModel = nil
  if mateId ~= nil then
    mateModel = self.m_viewModel.mateModelDict[mateId]
  end
  itemView.onBtnRevertQuitClick = self.m_input.onBtnQuitTeamClick
  itemView.onBtnDetailClick = self.m_input.onMateDetailClick
  itemView.onBtnInviteFriendClick = self.m_input.onBtnInviteFriend
  itemView:Render(mateModel, self.m_viewModel)
end

return TeamQuestTeamView