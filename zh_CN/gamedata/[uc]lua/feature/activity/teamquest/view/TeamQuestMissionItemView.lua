local luaUtils = CS.Torappu.Lua.Util


































local TeamQuestMissionItemView = Class("TeamQuestMissionItemView", UIWidget)

function TeamQuestMissionItemView:_InitIfNot()
  if self.m_hasInited then
    return
  end
  self.m_hasInited = true

  self:AddButtonClickListener(self._btnClick, self._EventOnItemClick)
end




function TeamQuestMissionItemView:Render(missionModel, themeColor, isInTeam)
  if missionModel == nil then
    return
  end
  self.m_missionId = missionModel.id
  self:_InitIfNot()

  local statusType = missionModel.statusType
  SetGameObjectActive(self._uncompletePartGO, statusType == TeamQuestMissionStatusType.UNCOMPLETE)
  SetGameObjectActive(self._availPartGO, statusType ~= TeamQuestMissionStatusType.UNCOMPLETE)
  SetGameObjectActive(self._completeMaskGO, statusType == TeamQuestMissionStatusType.COMPLETE)
  SetGameObjectActive(self._imgUncompleteTeamLock.gameObject, statusType == TeamQuestMissionStatusType.UNCOMPLETE and not isInTeam)
  SetGameObjectActive(self._imgAvailTeamLock.gameObject, statusType == TeamQuestMissionStatusType.AVAIL and not isInTeam)
  self._btnClick.enabled = statusType == TeamQuestMissionStatusType.AVAIL

  self:_SetGraphicColor(missionModel, themeColor)
  self._textDesc.text = missionModel.desc
  self._textBasicPointCnt.text = tostring(missionModel.normalRewardCnt)
  self._textTeamPointCnt.text = tostring(missionModel.teamRewardCnt)
  self._textProgressCurr.text = missionModel.progressCurr
  self._textProgressMax.text = missionModel.progressMax

  local progressVal = 0
  if missionModel.progressCurr ~= nil and missionModel.progressMax ~= nil and missionModel.progressMax ~= 0 then
    progressVal = missionModel.progressCurr / missionModel.progressMax
  end
  self._sliderProgress.value = progressVal
end



function TeamQuestMissionItemView:_SetGraphicColor(missionModel, themeColorStr)
  local isAvailOrComplete = missionModel.statusType ~= TeamQuestMissionStatusType.UNCOMPLETE
  local colorCaptionBgStr = isAvailOrComplete and self._colorAvailCaptionBg or self._colorUncompleteCaptionBg
  local colorCaptionBg = luaUtils.FormatColorFromData(colorCaptionBgStr)
  self._bgBasicPointCaption.color = colorCaptionBg
  self._bgTeamPointCaption.color = colorCaptionBg
  local colorCaptionTextStr = isAvailOrComplete and themeColorStr or self._colorUncompleteCaptionText
  local colorCaptionText = luaUtils.FormatColorFromData(colorCaptionTextStr)
  self._textBasicPointCaption.color = colorCaptionText
  self._textTeamPointCaption.color = colorCaptionText
  self._imgTeamCaptionIcon.color = colorCaptionText
  local colorPointStr = isAvailOrComplete and self._colorAvailPoint or themeColorStr
  local colorPoint = luaUtils.FormatColorFromData(colorPointStr)
  self._imgBasicPointIcon.color = colorPoint
  self._textBasicPointCnt.color = colorPoint
  self._imgTeamPointIcon.color = colorPoint
  self._textTeamPointCnt.color = colorPoint

  local themeColor = luaUtils.FormatColorFromData(themeColorStr)
  self._bgAvailPoint.color = themeColor
  self._imgSliderVal.color = themeColor
  self._bgThemeColor.color = themeColor
  self._imgAvailTeamLock.color = themeColor

  local colorPlusIconStr = isAvailOrComplete and self._colorPlusIconComplete or self._colorPlusIconUncomplete
  local colorPlusIcon = luaUtils.FormatColorFromData(colorPlusIconStr)
  self._imgPlusIcon.color = colorPlusIcon
end

function TeamQuestMissionItemView:_EventOnItemClick()
  if self.onItemClick == nil then
    return
  end
  self.onItemClick:Call(self.m_missionId)
end

return TeamQuestMissionItemView