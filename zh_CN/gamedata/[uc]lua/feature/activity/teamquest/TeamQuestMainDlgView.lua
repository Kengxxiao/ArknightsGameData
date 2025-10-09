local luaUtils = CS.Torappu.Lua.Util
local TeamQuestTabItemView = require("Feature/Activity/TeamQuest/View/TeamQuestTabItemView")
local TeamQuestMilestoneView = require("Feature/Activity/TeamQuest/TeamQuestMilestoneView")
local TeamQuestMissionView = require("Feature/Activity/TeamQuest/TeamQuestMissionView")
local TeamQuestTeamView = require("Feature/Activity/TeamQuest/TeamQuestTeamView")
local TeamQuestTeammateDetailView = require("Feature/Activity/TeamQuest/View/TeamQuestTeammateDetailView")














































local TeamQuestMainDlgView = Class("TeamQuestMainDlgView", UIPanel)

function TeamQuestMainDlgView:_InitIfNot()
  if self.m_hasInited == true then
    return
  end
  self.m_hasInited = true
  self.m_milestoneView = self:CreateWidgetByPrefab(TeamQuestMilestoneView, self._milestoneViewPrefab, self._milestonePanelRoot)
  self.m_milestoneView:Init(self.onMilestoneItemClick, self.onBtnAllMilestoneClick)

  self.m_missionView = self:CreateWidgetByPrefab(TeamQuestMissionView, self._missionViewPrefab, self._missionPanelRoot)
  self.m_missionView:Init(self.onMissionItemClick, self.onBtnAllMissionClick)

  self.m_teamView = self:CreateWidgetByPrefab(TeamQuestTeamView, self._teamViewPrefab, self._teamPanelRoot)
  self.m_teamView:Init(self.teamViewInput)

  self.m_teammateDetailView = self:CreateWidgetByPrefab(TeamQuestTeammateDetailView, self._mateDetailViewPrefab, self._mateDetailViewRoot)
  self.m_teammateDetailView:Init(self.mateDetailViewInput)

  self.m_tabListAdapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._tabList,
  self._CreateTabItemWidget, self._GetTabCount, self._UpdateTabItemView)

  self:AddButtonClickListener(self._toShareDlg,  function() 
    local callback = self.onRecordItemClick
    if callback then
      callback:Call()
    end
  end)

  self:AddButtonClickListener(self._toAct,  function() 
  local callback = self.onToActClick
  if callback then
    callback:Call()
  end
end)
end


function TeamQuestMainDlgView:OnViewModelUpdate(viewModel)
  self:_InitIfNot()
  if viewModel == nil or string.isNullOrEmpty(viewModel.actId) then
    return
  end

  local actId = viewModel.actId
  self.m_viewModel = viewModel

  self._imgLeftTheme:SetImage(CS.Torappu.ResourceUrls.GetActTeamQuestLeftThemeImagePath(actId))

  local milestoneItemName = luaUtils.GetItemName(viewModel.milestoneItemId)
  self._textMilestoneName.text = luaUtils.Format(I18NTextRes.ACT_TEAMQUEST_COMMON_CUR_PT, milestoneItemName)
  self._textMilestoneCnt.text = viewModel.milestoneItemCnt

  local themeColor = luaUtils.FormatColorFromData(viewModel.themeColor)
  self._imgMilestoneIcon.color = themeColor
  self._imgShareGlow.color = themeColor
  self._imgNavGlow.color = themeColor
  self._imgTeamBuffActiveBg.color = themeColor
  self._textMilestoneCnt.color = themeColor
  if self.m_tabListAdapter ~= nil then
    self.m_tabListAdapter:NotifyDataSetChanged()
  end

  local endTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(viewModel.endTime)
  self._textFinishTime.text = luaUtils.Format(I18NTextRes.ACT_TEAMQUEST_COMMON_END_TIME,
    endTime.Year, endTime.Month, endTime.Day, endTime.Hour, endTime.Minute)
  local remainTimeStr = CS.Torappu.FormatUtil.FormatTimeDeltaStrFromNow(viewModel.endTime)
  self._textRemainTime.text = luaUtils.Format(I18NTextRes.ACT_TEAMQUEST_COMMON_REMAIN, remainTimeStr)
  self._textRemainTime.color = themeColor
  SetGameObjectActive(self._teamBuffInactiveGO, not viewModel:IsInTeam())
  SetGameObjectActive(self._teamBuffActiveGO, viewModel:IsInTeam())

  SetGameObjectActive(self._milestonePanelRoot.gameObject, viewModel.selectTabType == TeamQuestTabType.MILESTONE)
  SetGameObjectActive(self._missionPanelRoot.gameObject, viewModel.selectTabType == TeamQuestTabType.MISSION)
  SetGameObjectActive(self._teamPanelRoot.gameObject, viewModel.selectTabType == TeamQuestTabType.TEAM)
  if viewModel.selectTabType == TeamQuestTabType.MILESTONE then
    self.m_milestoneView:Render(viewModel)
  elseif viewModel.selectTabType == TeamQuestTabType.MISSION then
    self.m_missionView:Render(viewModel)
  elseif viewModel.selectTabType == TeamQuestTabType.TEAM then
    self.m_teamView:Render(viewModel)
  end

  local showMateDetail = viewModel.selectTabType == TeamQuestTabType.TEAM and not string.isNullOrEmpty(viewModel.showDetailMateId)
  SetGameObjectActive(self._mateDetailViewRoot.gameObject, showMateDetail)
  self.m_teammateDetailView:Render(viewModel)
end



function TeamQuestMainDlgView:_CreateTabItemWidget(viewObj)
  local itemView = self:CreateWidgetByGO(TeamQuestTabItemView, viewObj)
  return itemView
end



function TeamQuestMainDlgView:_UpdateTabItemView(csIndex, itemView)
  local themeColor = self.m_viewModel.themeColor
  local tabModel = self.m_viewModel.tabList[csIndex+1]
  local isTabSelect = self.m_viewModel.selectTabType == tabModel.tabType
  local hasTrackPoint = tabModel:CheckHasTrackPoint(self.m_viewModel)
  itemView.onItemClick = self.onTabItemClick
  itemView.actId = self.m_viewModel.actId
  itemView:Render(tabModel, themeColor, isTabSelect, hasTrackPoint)
end


function TeamQuestMainDlgView:_GetTabCount()
  if self.m_viewModel == nil or self.m_viewModel.tabList == nil then
    return 0
  end
  return #self.m_viewModel.tabList
end

return TeamQuestMainDlgView