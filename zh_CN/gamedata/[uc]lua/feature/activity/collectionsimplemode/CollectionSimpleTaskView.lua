local luaUtils = CS.Torappu.Lua.Util
























local CollectionSimpleTaskView = Class("CollectionSimpleTaskView", UIWidget)

function CollectionSimpleTaskView:OnInitialize()
  self:AddButtonClickListener(self._claimRewardBtn, self._EventClaimReward)
end



function CollectionSimpleTaskView:Render(missionModel, isAllRewardClaimed)
  if missionModel == nil then
    return
  end
  self.m_missionId = missionModel.missionId
  self:_RenderThemeColor(missionModel.themeColor)
  self._desc.text = missionModel.desc
  self:_RenderRewardPanel(missionModel, isAllRewardClaimed)
end



function CollectionSimpleTaskView:_RenderRewardPanel(missionModel, isAllRewardClaimed)
  if missionModel == nil then
    return
  end
  self._rewardToggle.selected = missionModel.hasMissionCompleted
  self._hotspotClaimBtn.raycastTarget = not isAllRewardClaimed
  self._rewardCompletePoint.text = tostring(missionModel.rewardPointCount)
  self._rewardUncompletePoint.text = tostring(missionModel.rewardPointCount)
  self._rewardProgressCurr.text = tostring(missionModel.missionProgressCurr)
  self._rewardProgressTarget.text = tostring(missionModel.missionProgressTarget)
  if missionModel.missionProgressTarget <= 0 then
    self._rewardProgressBar.fillAmount = 0
  else
    self._rewardProgressBar.fillAmount = missionModel.missionProgressCurr / missionModel.missionProgressTarget
  end
  luaUtils.SetActiveIfNecessary(self._panelClaimed, missionModel.isMissionClaimed)
  if isAllRewardClaimed or missionModel.isMissionClaimed then
    self._rootCanvas.alpha = tonumber(self._claimedStateAlpha)
  else
    self._rootCanvas.alpha = tonumber(self._normalStateAlpha)
  end
end


function CollectionSimpleTaskView:_RenderThemeColor(themeColor)
  self._themeBgDecor.color = themeColor
  self._themeRewardCompleteBg.color = themeColor
  self._themeRewardUncompleteIcon.color = themeColor
  self._themeRewardUncompletePoint.color = themeColor
  self._themeRewardProgressBar.color = themeColor
end

function CollectionSimpleTaskView:_EventClaimReward()
  if not self.onMissionClaimed or not self.m_missionId then
    return
  end
  self.onMissionClaimed:Call(self.m_missionId)
end

return CollectionSimpleTaskView