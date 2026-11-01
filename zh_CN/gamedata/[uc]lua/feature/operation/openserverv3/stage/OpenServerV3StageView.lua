














local OpenServerV3StageView = Class("OpenServerV3StageView", UIPanel);

local OpenServerV3StageStoryView = require("Feature/Operation/OpenServerV3/Stage/OpenServerV3StageStoryView");
local OpenServerV3StageCampaignView = require("Feature/Operation/OpenServerV3/Stage/OpenServerV3StageCampaignView");
local OpenServerV3StageResourceView = require("Feature/Operation/OpenServerV3/Stage/OpenServerV3StageResourceView");
local OpenServerV3StagePermModeView = require("Feature/Operation/OpenServerV3/Stage/OpenServerV3StagePermModeView");

function OpenServerV3StageView:OnInit()
  self:_CreateSubViews();
end


function OpenServerV3StageView:OnViewModelUpdate(data)
  if data == nil or data.stageViewModel == nil then
    return;
  end
  local model = data.stageViewModel;
  if self.m_storyView ~= nil then
    self.m_storyView:Render(model);
  end
  if self.m_campaignView ~= nil then
    self.m_campaignView:Render(model);
  end
  if self.m_resourceView ~= nil then
    self.m_resourceView:Render(model);
  end
  if self.m_permModeView ~= nil then
    self.m_permModeView:Render(model);
  end
end


function OpenServerV3StageView:_CreateSubViews()
  if self._storyLayout ~= nil then
    self.m_storyView = self:CreateWidgetByGO(OpenServerV3StageStoryView, self._storyLayout);
    if self.m_storyView ~= nil then
      self.m_storyView.onMainClicked = Event.Create(self, self._EventOnStoryMainClicked);
      self.m_storyView.onExtraClicked = Event.Create(self, self._EventOnStoryExtraClicked);
    end
  end
  if self._campaignLayout ~= nil then
    self.m_campaignView = self:CreateWidgetByGO(OpenServerV3StageCampaignView, self._campaignLayout);
    if self.m_campaignView ~= nil then
      self.m_campaignView.onMainClicked = Event.Create(self, self._EventOnCampaignMainClicked);
      self.m_campaignView.onDetailClicked = Event.Create(self, self._EventOnCampaignDetailClicked);
    end
  end
  if self._resourceLayout ~= nil then
    self.m_resourceView = self:CreateWidgetByGO(OpenServerV3StageResourceView, self._resourceLayout);
    if self.m_resourceView ~= nil then
      self.m_resourceView.onMainClicked = Event.Create(self, self._EventOnResourceClicked);
    end
  end
  if self._permModeLayout ~= nil then
    self.m_permModeView = self:CreateWidgetByGO(OpenServerV3StagePermModeView, self._permModeLayout);
    if self.m_permModeView ~= nil then
      self.m_permModeView.onMainClicked = Event.Create(self, self._EventOnPermModeClicked);
    end
  end
end


function OpenServerV3StageView:_EventOnStoryMainClicked()
  if self.onStoryMainClicked ~= nil then
    self.onStoryMainClicked:Call();
  end
end


function OpenServerV3StageView:_EventOnStoryExtraClicked()
  if self.onStoryExtraClicked ~= nil then
    self.onStoryExtraClicked:Call();
  end
end


function OpenServerV3StageView:_EventOnCampaignMainClicked()
  if self.onCampaignMainClicked ~= nil then
    self.onCampaignMainClicked:Call();
  end
end


function OpenServerV3StageView:_EventOnCampaignDetailClicked()
  if self.onStageCampaignClicked ~= nil then
    self.onStageCampaignClicked:Call();
  end
end


function OpenServerV3StageView:_EventOnResourceClicked()
  if self.onResourceClicked ~= nil then
    self.onResourceClicked:Call();
  end
end


function OpenServerV3StageView:_EventOnPermModeClicked()
  if self.onPermModeClicked ~= nil then
    self.onPermModeClicked:Call();
  end
end

return OpenServerV3StageView;