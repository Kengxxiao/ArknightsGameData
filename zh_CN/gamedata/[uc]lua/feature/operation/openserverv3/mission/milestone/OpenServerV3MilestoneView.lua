




















local OpenServerV3MilestoneView = Class("OpenServerV3MilestoneView", UIWidget);

local OpenServerV3MilestoneListAdapter = require(
    "Feature/Operation/OpenServerV3/Mission/Milestone/OpenServerV3MilestoneListAdapter");

local luaUtil = CS.Torappu.Lua.Util;
local POINT_TARGET_FORMAT = "/{0}";

function OpenServerV3MilestoneView:OnInitialize()
  self.m_eventOnItemClicked = Event.Create(self, self._EventOnItemClicked);
  if self._btnClaimAll ~= nil then
    self:AddButtonClickListener(self._btnClaimAll, self._EventOnClaimAllClicked);
  end
  if self._btnPreviewChar ~= nil then
    self:AddButtonClickListener(self._btnPreviewChar, self._EventOnPreviewCharClicked);
  end
  if self._layout ~= nil then
    self.m_listAdapter = self:CreateCustomComponent(OpenServerV3MilestoneListAdapter, self._layout, self);
    self.m_listAdapter.onItemClicked = self.m_eventOnItemClicked;
  end
end


function OpenServerV3MilestoneView:Render(viewModel)
  self.m_viewModel = viewModel;
  if viewModel == nil or viewModel.milestoneModel == nil then
    return;
  end
  local milestoneModel = viewModel.milestoneModel;
  self:_RefreshLevelCard(milestoneModel);
  self:_RefreshRewardImage(milestoneModel);
  self:_RefreshClaimAllButton(milestoneModel);
  self:_RefreshList(milestoneModel);
end

function OpenServerV3MilestoneView:ResetFocus()
  self.m_hasFocused = false;
end



function OpenServerV3MilestoneView:_RefreshLevelCard(milestoneModel)
  if self._textLevel ~= nil then
    self._textLevel.text = tostring(milestoneModel.currentLevel);
  end
  if self._textPointCurrent ~= nil then
    self._textPointCurrent.text = milestoneModel.isMax and "" or tostring(milestoneModel.currentStagePoint);
  end
  if self._textPointTarget ~= nil then
    self._textPointTarget.text = milestoneModel.isMax and "" or
        luaUtil.Format(POINT_TARGET_FORMAT, milestoneModel.nextStageNeedPoint);
  end
  if self._toggleMax ~= nil then
    self._toggleMax.state = milestoneModel.isMax and CS.Torappu.UI.TwoStateToggle.State.SELECT or
        CS.Torappu.UI.TwoStateToggle.State.UNSELECT;
  end
  if self._imgProgress ~= nil then
    self._imgProgress.fillAmount = milestoneModel.progress;
  end
  if self._imgPointItem ~= nil and milestoneModel.pointItemId ~= nil and milestoneModel.pointItemId ~= "" then
    self._imgPointItem.sprite = CS.Torappu.UI.ItemUtil.LoadItemIconUI(
        CS.Torappu.ItemType.NONE, milestoneModel.pointItemId, milestoneModel.pointItemId);
  end
  if self._textTargetRewardLevel ~= nil then
    self._textTargetRewardLevel.text = luaUtil.Format(
        I18NTextRes.COMMON_OPEN_SERVER_V3_MISSION_BP_AWARD_FINAL,
        milestoneModel.targetRewardLevel);
  end
end



function OpenServerV3MilestoneView:_RefreshRewardImage(milestoneModel)
  if self._imgReward == nil or milestoneModel.rewardImgId == nil or milestoneModel.rewardImgId == "" then
    return;
  end
  self._imgReward.sprite = self:LoadSpriteFromAutoPackHub(
      CS.Torappu.ResourceUrls.GetOpenServerMilestoneRewardHubPath(),
      milestoneModel.rewardImgId);
end



function OpenServerV3MilestoneView:_RefreshClaimAllButton(milestoneModel)
  if self._toggleClaimAll ~= nil then
    self._toggleClaimAll.state = milestoneModel.hasRewardCanClaim and CS.Torappu.UI.TwoStateToggle.State.SELECT or
        CS.Torappu.UI.TwoStateToggle.State.UNSELECT;
  end
end



function OpenServerV3MilestoneView:_RefreshList(milestoneModel)
  if self.m_listAdapter == nil then
    return;
  end
  self.m_listAdapter.createWidgetByGO = self.createWidgetByGO;
  self.m_listAdapter.itemList = milestoneModel.itemList;
  if not self.m_hasFocused and milestoneModel.focusIndex > 0 then
    self.m_hasFocused = true;
    self.m_listAdapter:NotifyRebuildWithIndex(milestoneModel.focusIndex - 1);
    return;
  end
  self.m_listAdapter:NotifyDataSourceChanged();
end



function OpenServerV3MilestoneView:_EventOnItemClicked(level)
  if self.onItemClicked ~= nil then
    self.onItemClicked:Call(level);
  end
end


function OpenServerV3MilestoneView:_EventOnClaimAllClicked()
  if self.m_viewModel == nil or self.m_viewModel.milestoneModel == nil or
      not self.m_viewModel.milestoneModel.hasRewardCanClaim then
    return;
  end
  if self.onClaimAllClicked ~= nil then
    self.onClaimAllClicked:Call();
  end
end


function OpenServerV3MilestoneView:_EventOnPreviewCharClicked()
  if self.m_viewModel == nil or self.m_viewModel.milestoneModel == nil then
    return;
  end
  local charId = self.m_viewModel.milestoneModel.previewCharId;
  if charId == nil or charId == "" or self.onPreviewCharClicked == nil then
    return;
  end
  self.onPreviewCharClicked:Call(charId);
end

return OpenServerV3MilestoneView;
