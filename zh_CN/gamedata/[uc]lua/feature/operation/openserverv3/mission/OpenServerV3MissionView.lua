

























local OpenServerV3MissionView = Class("OpenServerV3MissionView", UIPanel);

local OpenServerV3MissionPageTabView = require("Feature/Operation/OpenServerV3/Mission/OpenServerV3MissionPageTabView");
local OpenServerV3MissionBoardView = require("Feature/Operation/OpenServerV3/Mission/OpenServerV3MissionBoardView");
local OpenServerV3MilestoneView = require("Feature/Operation/OpenServerV3/Mission/Milestone/OpenServerV3MilestoneView");

function OpenServerV3MissionView:OnInit()
  self:_CreateBoardEvents();
  self:_CreateTabViews();
  self:_CreateSubViews();
end

function OpenServerV3MissionView:ResetMilestoneFocus()
  if self.m_milestoneView ~= nil then
    self.m_milestoneView:ResetFocus();
  end
end


function OpenServerV3MissionView:OnViewModelUpdate(data)
  if data == nil or data.missionViewModel == nil then
    return;
  end
  self.m_viewModel = data.missionViewModel;
  local showTask = self.m_viewModel.pageState == OpenServerV3MissionPageState.TASK;
  local pageChanged = self.m_lastPageState ~= self.m_viewModel.pageState;
  self.m_lastPageState = self.m_viewModel.pageState;
  self:_RefreshTabViews(self.m_viewModel.pageState);
  if self.m_boardView ~= nil then
    SetGameObjectActive(self.m_boardView:RootGameObject(), showTask);
  end
  if self.m_milestoneView ~= nil then
    SetGameObjectActive(self.m_milestoneView:RootGameObject(), not showTask);
  end
  if showTask and self.m_boardView ~= nil then
    self.m_boardView:Render(self.m_viewModel);
  end
  if not showTask and self.m_milestoneView ~= nil then
    if pageChanged then
      self:ResetMilestoneFocus();
    end
    self.m_milestoneView:Render(self.m_viewModel);
  end
end


function OpenServerV3MissionView:_CreateBoardEvents()
  self.m_eventOnStageClicked = Event.Create(self, self._EventOnStageClicked);
  self.m_eventOnTaskClicked = Event.Create(self, self._EventOnTaskClicked);
  self.m_eventOnTaskJumpClicked = Event.Create(self, self._EventOnTaskJumpClicked);
  self.m_eventOnClaimAllClicked = Event.Create(self, self._EventOnClaimAllClicked);
  self.m_eventOnMilestoneItemClicked = Event.Create(self, self._EventOnMilestoneItemClicked);
  self.m_eventOnMilestoneClaimAllClicked = Event.Create(self, self._EventOnMilestoneClaimAllClicked);
  self.m_eventOnMilestonePreviewCharClicked = Event.Create(self, self._EventOnMilestonePreviewCharClicked);
end


function OpenServerV3MissionView:_CreateTabViews()
  local onClicked = Event.Create(self, self._EventOnPageTabClicked);
  if self._taskTabLayout ~= nil then
    self.m_taskTabView = self:CreateWidgetByGO(OpenServerV3MissionPageTabView, self._taskTabLayout);
    if self.m_taskTabView ~= nil then
      self.m_taskTabView:Init(OpenServerV3MissionPageState.TASK, onClicked);
      self.m_taskTabView:BindTrackPoint(OpenServerV3MissionTaskTrackPoint);
    end
  end
  if self._milestoneTabLayout ~= nil then
    self.m_milestoneTabView = self:CreateWidgetByGO(OpenServerV3MissionPageTabView, self._milestoneTabLayout);
    if self.m_milestoneTabView ~= nil then
      self.m_milestoneTabView:Init(OpenServerV3MissionPageState.MILESTONE, onClicked);
      self.m_milestoneTabView:BindTrackPoint(OpenServerV3MilestoneTrackPoint);
    end
  end
end


function OpenServerV3MissionView:_CreateSubViews()
  if self._taskViewLayout ~= nil then
    self.m_boardView = self:CreateWidgetByGO(OpenServerV3MissionBoardView, self._taskViewLayout);
    if self.m_boardView ~= nil then
      self.m_boardView.createWidgetByGO = function(widgetCls, layout)
          return self:CreateWidgetByGO(widgetCls, layout);
        end;
    end
    self:_BindBoardEvents();
  end
  if self._milestoneViewLayout ~= nil then
    self.m_milestoneView = self:CreateWidgetByGO(OpenServerV3MilestoneView, self._milestoneViewLayout);
    if self.m_milestoneView ~= nil then
      self.m_milestoneView.createWidgetByGO = function(widgetCls, layout)
          return self:CreateWidgetByGO(widgetCls, layout);
        end;
      self.m_milestoneView.onItemClicked = self.m_eventOnMilestoneItemClicked;
      self.m_milestoneView.onClaimAllClicked = self.m_eventOnMilestoneClaimAllClicked;
      self.m_milestoneView.onPreviewCharClicked = self.m_eventOnMilestonePreviewCharClicked;
    end
  end
end



function OpenServerV3MissionView:_RefreshTabViews(pageState)
  if self.m_taskTabView ~= nil then
    self.m_taskTabView:Render(
        pageState == OpenServerV3MissionPageState.TASK,
        self.m_viewModel.showTaskNewSign);
  end
  if self.m_milestoneTabView ~= nil then
    self.m_milestoneTabView:Render(
        pageState == OpenServerV3MissionPageState.MILESTONE,
        self.m_viewModel.showMilestoneNewSign);
  end
end


function OpenServerV3MissionView:_BindBoardEvents()
  if self.m_boardView == nil then
    return;
  end
  self.m_boardView.onStageClicked = self.m_eventOnStageClicked;
  self.m_boardView.onTaskClicked = self.m_eventOnTaskClicked;
  self.m_boardView.onTaskJumpClicked = self.m_eventOnTaskJumpClicked;
  self.m_boardView.onClaimAllClicked = self.m_eventOnClaimAllClicked;
end



function OpenServerV3MissionView:_EventOnPageTabClicked(pageState)
  if self.onPageTabClicked ~= nil then
    self.onPageTabClicked:Call(pageState);
  end
end



function OpenServerV3MissionView:_EventOnStageClicked(stageIndex)
  if self.onStageClicked ~= nil then
    self.onStageClicked:Call(stageIndex);
  end
end



function OpenServerV3MissionView:_EventOnTaskClicked(missionId)
  if self.onTaskClicked ~= nil then
    self.onTaskClicked:Call(missionId);
  end
end



function OpenServerV3MissionView:_EventOnTaskJumpClicked(missionId)
  if self.onTaskJumpClicked ~= nil then
    self.onTaskJumpClicked:Call(missionId);
  end
end


function OpenServerV3MissionView:_EventOnClaimAllClicked()
  if self.onClaimAllClicked ~= nil then
    self.onClaimAllClicked:Call();
  end
end



function OpenServerV3MissionView:_EventOnMilestoneItemClicked(level)
  if self.onMilestoneItemClicked ~= nil then
    self.onMilestoneItemClicked:Call(level);
  end
end


function OpenServerV3MissionView:_EventOnMilestoneClaimAllClicked()
  if self.onMilestoneClaimAllClicked ~= nil then
    self.onMilestoneClaimAllClicked:Call();
  end
end



function OpenServerV3MissionView:_EventOnMilestonePreviewCharClicked(charId)
  if self.onMilestonePreviewCharClicked ~= nil then
    self.onMilestonePreviewCharClicked:Call(charId);
  end
end

return OpenServerV3MissionView;