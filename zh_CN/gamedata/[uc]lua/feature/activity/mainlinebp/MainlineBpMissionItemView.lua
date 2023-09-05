local luaUtils = CS.Torappu.Lua.Util;
local UICommonItemCard = require("Feature/Supportor/UI/UICommonItemCard")


































local MainlineBpMissionItemView = Class("MainlineBpMissionItemView", UIPanel);

function MainlineBpMissionItemView:OnInit()
  self:AddButtonClickListener(self._btnConfirmMission, self._OnMissionClicked);
  self:AddButtonClickListener(self._btnJumpToZone, self._OnJumpToZoneClicked);
  self.m_adapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._contentMissionReward, 
      self._CreateRewardItem, self._GetRewardCount, self._UpdateRewardItemCard);
end



function MainlineBpMissionItemView:Render(viewModel, actId)
  self.m_cacheRewardList = nil;
  self.m_cachedFocusZoneId = "";
  self.m_cachedMissionId = "";
  if viewModel == nil then
    return;
  end

  local type = viewModel.itemType;
  luaUtils.SetActiveIfNecessary(self._panelMissionItem, type == MainlineBpMissionItemType.MISSION);
  luaUtils.SetActiveIfNecessary(self._panelMissionGroup, type == MainlineBpMissionItemType.MISSION_GROUP);
  luaUtils.SetActiveIfNecessary(self._panelBanner, type == MainlineBpMissionItemType.BANNER);

  if type == MainlineBpMissionItemType.MISSION then
    self:_RenderMissionItem(viewModel);
  elseif type == MainlineBpMissionItemType.MISSION_GROUP then
    self:_RenderMissionGroup(viewModel, actId);
  elseif type == MainlineBpMissionItemType.BANNER then
    self:_RenderBanner(viewModel, actId);
  end
end



function MainlineBpMissionItemView:_RenderMissionItem(viewModel)
  if viewModel == nil then
    return;
  end

  self.m_cachedMissionId = viewModel.missionId;
  local state = viewModel.missionState;
  luaUtils.SetActiveIfNecessary(self._panelMissionUncomplete, 
      state == MainlineBpMissionState.UNCOMPLETE);
  luaUtils.SetActiveIfNecessary(self._panelMissionCompleteOrConfirm, 
      state == MainlineBpMissionState.COMPLETE or state == MainlineBpMissionState.CONFIRMED);
  luaUtils.SetActiveIfNecessary(self._panelMissionComplete,
      state == MainlineBpMissionState.COMPLETE);
  luaUtils.SetActiveIfNecessary(self._panelMissionConfirm,
      state == MainlineBpMissionState.CONFIRMED);
      self._btnConfirmMission.interactable = state == MainlineBpMissionState.COMPLETE;
  self._textMissionDesc1.text = viewModel.missionDesc;
  self._textMissionDesc2.text = viewModel.missionDesc;
  self._sliderProgressMission1.value = viewModel.progressPercent;
  self._sliderProgressMission2.value = viewModel.progressPercent;
  self._textCompleteProgressDesc.text = luaUtils.Format(self._formatProgressComplete, 
      viewModel.progressCurr, viewModel.progressTarget);
  self._textUncompleteProgressDesc.text = luaUtils.Format(self._formatProgressUncomplete, 
      viewModel.progressCurr, viewModel.progressTarget);
  self.m_cacheRewardList = viewModel.rewardList;
  self.m_adapter:NotifyDataSetChanged();
end




function MainlineBpMissionItemView:_RenderMissionGroup(viewModel, actId)
  if viewModel == nil then
    return;
  end

  self._textApEndDesc.text = viewModel.apEndDesc;
  self.m_cachedFocusZoneId = viewModel.zoneId;
  local bannerId = viewModel.bannerId;
  if bannerId == nil or bannerId == "" or self.loadDynImage == nil then
    return;
  end
  self._imgGroupTitle.sprite = self.loadDynImage(actId, bannerId);
end




function MainlineBpMissionItemView:_RenderBanner(viewModel, actId)
  if viewModel == nil then
    return;
  end
  local bannerId = viewModel.bannerId;
  if bannerId == nil or bannerId == "" or self.loadDynImage == nil then
    return;
  end
  self._imgBanner.sprite = self.loadDynImage(actId, bannerId);
end



function MainlineBpMissionItemView:_CreateRewardItem(gameObj)
  local itemView = self:CreateWidgetByGO(UICommonItemCard, gameObj);
  return itemView;
end



function MainlineBpMissionItemView:_GetRewardCount()
  if self.m_cacheRewardList == nil then
    return 0;
  end
  return self.m_cacheRewardList.Count;
end




function MainlineBpMissionItemView:_UpdateRewardItemCard(index, itemView)
  itemView:Render(self.m_cacheRewardList[index], {
    itemScale = tonumber(self._itemCardScale),
    isCardClickable = true,
    showItemName = false,
    showItemNum = true,
    showBackground = true,
  });
end


function MainlineBpMissionItemView:_OnMissionClicked()
  if self.m_cachedMissionId == nil or self.m_cachedMissionId == "" or self.onMissionClicked == nil then
    return;
  end
  Event.Call(self.onMissionClicked, self.m_cachedMissionId);
end


function MainlineBpMissionItemView:_OnJumpToZoneClicked()
  if self.m_cachedFocusZoneId == nil or self.m_cachedFocusZoneId == "" or self.onJumpToZoneClicked == nil then
    return;
  end
  Event.Call(self.onJumpToZoneClicked, self.m_cachedFocusZoneId);
end

return MainlineBpMissionItemView;