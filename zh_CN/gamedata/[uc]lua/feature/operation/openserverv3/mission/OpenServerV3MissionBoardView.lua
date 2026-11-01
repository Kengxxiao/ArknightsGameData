















local OpenServerV3MissionBoardView = Class("OpenServerV3MissionBoardView", UIWidget);

local OpenServerV3MissionStageItemView = require("Feature/Operation/OpenServerV3/Mission/OpenServerV3MissionStageItemView");
local OpenServerV3MissionTaskListAdapter = require("Feature/Operation/OpenServerV3/Mission/OpenServerV3MissionTaskListAdapter");

function OpenServerV3MissionBoardView:OnInitialize()
  self.m_eventOnStageClicked = Event.Create(self, self._EventOnStageClicked);
  self.m_eventOnTaskClicked = Event.Create(self, self._EventOnTaskClicked);
  self.m_eventOnTaskJumpClicked = Event.Create(self, self._EventOnTaskJumpClicked);
  if self._btnClaimAll ~= nil then
    self:AddButtonClickListener(self._btnClaimAll, self._EventOnClaimAllClicked);
  end
  if self._stageContent ~= nil then
    self.m_stageAdapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._stageContent,
        self._CreateStageItemView, self._GetStageItemCount, self._UpdateStageItemView);
  end
  if self._layout ~= nil then
    self.m_taskAdapter = self:CreateCustomComponent(OpenServerV3MissionTaskListAdapter, self._layout, self);
    self.m_taskAdapter.onTaskClicked = self.m_eventOnTaskClicked;
    self.m_taskAdapter.onTaskJumpClicked = self.m_eventOnTaskJumpClicked;
  end
end


function OpenServerV3MissionBoardView:Render(viewModel)
  if viewModel == nil then
    return;
  end
  self.m_viewModel = viewModel;
  SetGameObjectActive(self._panelClaimAll, viewModel.hasRewardCanClaim);
  if self.m_stageAdapter ~= nil then
    self.m_stageAdapter:NotifyDataSetChanged();
  end
  if self.m_taskAdapter ~= nil then
    self.m_taskAdapter.createWidgetByGO = self.createWidgetByGO;
    self.m_taskAdapter.missionList = viewModel.missionList;
    self.m_taskAdapter:NotifyDataSourceChanged();
  end
end



function OpenServerV3MissionBoardView:_CreateStageItemView(gameObj)
  local itemView = self:_CreateWidgetByGO(OpenServerV3MissionStageItemView, gameObj);
  if itemView ~= nil then
    itemView.onClicked = self.m_eventOnStageClicked;
  end
  return itemView;
end






function OpenServerV3MissionBoardView:_CreateWidgetByGO(widgetCls, layout)
  if self.createWidgetByGO == nil then
    return nil;
  end
  return self.createWidgetByGO(widgetCls, layout);
end



function OpenServerV3MissionBoardView:_GetStageItemCount()
  if self.m_viewModel == nil or self.m_viewModel.stageList == nil then
    return 0;
  end
  return #self.m_viewModel.stageList;
end




function OpenServerV3MissionBoardView:_UpdateStageItemView(index, view)
  if self.m_viewModel == nil or view == nil then
    return;
  end
  local luaIndex = index + 1;
  local stageModel = self.m_viewModel.stageList[luaIndex];
  if stageModel == nil then
    return;
  end
  view:BindTrackPoint(stageModel.trackPointType); 
  view:Render(stageModel, luaIndex == #self.m_viewModel.stageList);
end



function OpenServerV3MissionBoardView:_EventOnStageClicked(index)
  if self.onStageClicked ~= nil then
    self.onStageClicked:Call(index);
  end
end



function OpenServerV3MissionBoardView:_EventOnTaskClicked(missionId)
  if self.onTaskClicked ~= nil then
    self.onTaskClicked:Call(missionId);
  end
end



function OpenServerV3MissionBoardView:_EventOnTaskJumpClicked(missionId)
  if self.onTaskJumpClicked ~= nil then
    self.onTaskJumpClicked:Call(missionId);
  end
end


function OpenServerV3MissionBoardView:_EventOnClaimAllClicked()
  if self.onClaimAllClicked ~= nil then
    self.onClaimAllClicked:Call();
  end
end

return OpenServerV3MissionBoardView;
