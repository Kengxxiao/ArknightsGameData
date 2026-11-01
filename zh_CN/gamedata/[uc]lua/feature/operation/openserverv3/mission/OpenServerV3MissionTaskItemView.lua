
























local OpenServerV3MissionTaskItemView = Class("OpenServerV3MissionTaskItemView", UIWidget);

local OpenServerV3MissionTaskPartView = require("Feature/Operation/OpenServerV3/Mission/OpenServerV3MissionTaskPartView");
local OpenServerV3MissionRewardItemView = require("Feature/Operation/OpenServerV3/Mission/OpenServerV3MissionRewardItemView");



local REWARD_SLOT_COUNT = 2;

function OpenServerV3MissionTaskItemView:OnInitialize()
  if self._btnClaimNormal ~= nil then
    self:AddButtonClickListener(self._btnClaimNormal, self._EventOnClaimClicked);
  end
  if self._btnClaimBonus ~= nil then
    self:AddButtonClickListener(self._btnClaimBonus, self._EventOnClaimClicked);
  end
  if self._btnJump ~= nil then
    self:AddButtonClickListener(self._btnJump, self._EventOnJumpClicked);
  end
end


function OpenServerV3MissionTaskItemView:Render(viewModel)
  if viewModel == nil then
    return;
  end
  self.m_viewModel = viewModel;
  self:_EnsurePartViews();
  local partView = self:_GetPartView(viewModel);
  self:_SetOnlyPartActive(partView);
  if partView ~= nil then
    partView:Render(viewModel);
  end
  self:_InitIfNot();
  self:_RefreshAction(viewModel);
  if self.m_rewardAdapter ~= nil then
    self.m_rewardAdapter:NotifyDataSetChanged();
  end
end


function OpenServerV3MissionTaskItemView:_EnsurePartViews()
  if self.m_partNormalUncomplete == nil then
    self.m_partNormalUncomplete = self:_CreatePartView(self._partNormalUncomplete);
  end
  if self.m_partNormalComplete == nil then
    self.m_partNormalComplete = self:_CreatePartView(self._partNormalComplete);
  end
  if self.m_partBonusUncomplete == nil then
    self.m_partBonusUncomplete = self:_CreatePartView(self._partBonusUncomplete);
  end
  if self.m_partBonusComplete == nil then
    self.m_partBonusComplete = self:_CreatePartView(self._partBonusComplete);
  end
  if self.m_partConfirmed == nil then
    self.m_partConfirmed = self:_CreatePartView(self._partConfirmed);
  end
end




function OpenServerV3MissionTaskItemView:_CreatePartView(layout)
  if layout == nil then
    return nil;
  end
  local view = self:_CreateWidgetByGO(OpenServerV3MissionTaskPartView, layout);
  return view;
end




function OpenServerV3MissionTaskItemView:_GetPartView(viewModel)
  if viewModel.state == OpenServerV3MissionItemState.CONFIRMED then
    return self.m_partConfirmed;
  end
  local isBonus = self:_CheckIfBonusMission(viewModel);
  if viewModel.state == OpenServerV3MissionItemState.COMPLETE then
    if isBonus then
      return self.m_partBonusComplete;
    end
    return self.m_partNormalComplete;
  end
  if isBonus then
    return self.m_partBonusUncomplete;
  end
  return self.m_partNormalUncomplete;
end



function OpenServerV3MissionTaskItemView:_SetOnlyPartActive(activePart)
  self:_SetPartActive(self.m_partNormalUncomplete, activePart);
  self:_SetPartActive(self.m_partNormalComplete, activePart);
  self:_SetPartActive(self.m_partBonusUncomplete, activePart);
  self:_SetPartActive(self.m_partBonusComplete, activePart);
  self:_SetPartActive(self.m_partConfirmed, activePart);
end




function OpenServerV3MissionTaskItemView:_SetPartActive(partView, activePart)
  if partView == nil then
    return;
  end
  SetGameObjectActive(partView:RootGameObject(), partView == activePart);
end



function OpenServerV3MissionTaskItemView:_RefreshAction(viewModel)
  local isComplete = viewModel.state == OpenServerV3MissionItemState.COMPLETE;
  local isBonus = self:_CheckIfBonusMission(viewModel);
  local showJump = viewModel.state == OpenServerV3MissionItemState.UNCOMPLETE and
      viewModel.jumpType ~= OperationJumpType.NONE;
  SetGameObjectActive(self._panelClaimNormal, isComplete and not isBonus);
  SetGameObjectActive(self._panelClaimBonus, isComplete and isBonus);
  SetGameObjectActive(self._panelJump, showJump);
  SetGameObjectActive(self._panelConfirmedOverlay, viewModel.state == OpenServerV3MissionItemState.CONFIRMED);
end


function OpenServerV3MissionTaskItemView:_InitIfNot()
  if self.m_rewardAdapter ~= nil or self._rewardContent == nil or self.createWidgetByGO == nil then
    return;
  end
  self.m_rewardAdapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._rewardContent,
      self._CreateRewardItemView, self._GetRewardItemCount, self._UpdateRewardItemView);
end




function OpenServerV3MissionTaskItemView:_CheckIfBonusMission(viewModel)
  return viewModel ~= nil and viewModel.missionType == CS.Torappu.OpenServerMissionType.BONUS;
end



function OpenServerV3MissionTaskItemView:_CreateRewardItemView(gameObj)
  local itemView = self:_CreateWidgetByGO(OpenServerV3MissionRewardItemView, gameObj);
  if itemView ~= nil then
    itemView.createWidgetByGO = self.createWidgetByGO;
  end
  return itemView;
end






function OpenServerV3MissionTaskItemView:_CreateWidgetByGO(widgetCls, layout)
  if self.createWidgetByGO == nil or layout == nil then
    return nil;
  end
  return self.createWidgetByGO(widgetCls, layout);
end



function OpenServerV3MissionTaskItemView:_GetRewardItemCount()
  if self.m_viewModel == nil then
    return 0;
  end
  return REWARD_SLOT_COUNT;
end




function OpenServerV3MissionTaskItemView:_UpdateRewardItemView(index, view)
  if view == nil then
    return;
  end
  view:Render(self:_GetRewardItemModel(index), tonumber(self._itemCardScale));
end




function OpenServerV3MissionTaskItemView:_GetRewardItemModel(index)
  if self.m_viewModel == nil or self.m_viewModel.rewardList == nil then
    return nil;
  end
  local rewardIndex = index + 1;
  if rewardIndex > REWARD_SLOT_COUNT then
    return nil;
  end
  return self.m_viewModel.rewardList[rewardIndex];
end


function OpenServerV3MissionTaskItemView:_EventOnClaimClicked()
  if self.m_viewModel == nil or self.onTaskClicked == nil then
    return;
  end
  self.onTaskClicked:Call(self.m_viewModel.missionId);
end


function OpenServerV3MissionTaskItemView:_EventOnJumpClicked()
  if self.m_viewModel == nil or self.onTaskJumpClicked == nil then
    return;
  end
  self.onTaskJumpClicked:Call(self.m_viewModel.missionId);
end

return OpenServerV3MissionTaskItemView;
