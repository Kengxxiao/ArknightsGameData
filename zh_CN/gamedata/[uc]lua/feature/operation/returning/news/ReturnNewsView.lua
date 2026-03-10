local BackflowNewsJumpType = CS.Torappu.EventTrack.EventLogTrace.EventLogBackflowTraceContext.BackflowNewsJumpType;



















local ReturnNewsView = Class("ReturnNewsView", UIPanel);
local ReturnNewsItemView = require("Feature/Operation/Returning/News/ReturnNewsItemView");
local ReturnNewsStoneRewardView = require("Feature/Operation/Returning/News/ReturnNewsStoneRewardView");
local ReturnNewsItemRewardView = require("Feature/Operation/Returning/News/ReturnNewsItemRewardView");

function ReturnNewsView:OnInit()
  self:AddButtonClickListener(self._btnJump, function()
    if (self.m_viewModel == nil or self.m_viewModel.selectedModel == nil) then
      return;
    end
    local selectedModel = self.m_viewModel.selectedModel;
    if (selectedModel.jumpType == ReturnNewsJumpType.ZONE) then
      self:_JumpToStage();
    elseif(selectedModel.jumpType == ReturnNewsJumpType.ACTIVITY) then
      self:_JumpToAct();
    elseif(selectedModel.jumpType == ReturnNewsJumpType.ROGUE) then
      self:_JumpToRogue();
    elseif(selectedModel.jumpType == ReturnNewsJumpType.SANDBOX) then
      self:_JumpToSandbox();
    end
  end);
  self.m_stoneRewardView = self:CreateWidgetByGO(ReturnNewsStoneRewardView, self._stoneRewardsView);
  self.m_itemRewardView = self:CreateWidgetByGO(ReturnNewsItemRewardView, self._itemRewardsView);
  self.m_adapter = self:CreateCustomComponent(
      UISimpleLayoutAdapter, self, self._contentNewsItem, self._CreateNewsItemView,
      self._GetNewsItemCount, self._UpdateNewsItemView);
end

function ReturnNewsView:_CreateNewsItemView(gameObj)
  local itemView = self:CreateWidgetByGO(ReturnNewsItemView, gameObj);
  itemView.onItemClick = Event.Create(self, self._OnItemClicked);
  return itemView;
end

function ReturnNewsView:_GetNewsItemCount()
  if self.m_viewModel == nil then
    return 0;
  end
  return #self.m_viewModel.newsList;
end



function ReturnNewsView:_UpdateNewsItemView(index, item)
  item:Render(self.m_viewModel.newsList[index + 1]);
end


function ReturnNewsView:_OnItemClicked(id)
  if (self.eventOnClicked == nil) then
    return;
  end
  self.eventOnClicked:Call(id);
end


function ReturnNewsView:OnViewModelUpdate(model)
  if (model == nil or model.newsViewModel == nil) then
    return;
  end
  local newsModel = model.newsViewModel;
  self.m_viewModel = newsModel;
  self._textTitle.text = newsModel.selectedModel.title;
  self._textDesc.text = newsModel.selectedModel.desc;
  self._imgTitle.sprite = self:LoadSpriteFromAutoPackHub(CS.Torappu.ResourceUrls.GetReturnNewsTitleHubPath(), newsModel.selectedModel.imgId);
  self._imgBkg.sprite = self:LoadSpriteFromAutoPackHub(CS.Torappu.ResourceUrls.GetReturnNewsBkgHubPath(), newsModel.selectedModel.imgId);
  self._imgTypeIcon.sprite = self:LoadSpriteFromAutoPackHub(CS.Torappu.ResourceUrls.GetReturnNewsTypeIconHubPath(), newsModel.selectedModel.typeIconId);
  
  if (newsModel.selectedModel.newsType == CS.Torappu.ReturnNewsType.MAIN_SS) then
    self:_RenderMainSS();
  elseif(newsModel.selectedModel.newsType == CS.Torappu.ReturnNewsType.ROGUE) then
    self:_RenderRogue();
  elseif(newsModel.selectedModel.newsType == CS.Torappu.ReturnNewsType.SANDBOX) then
    self:_RenderSandbox();
  end
  self.m_adapter:NotifyDataSetChanged();
end

function ReturnNewsView:_RenderMainSS()
  SetGameObjectActive(self._objStoneRewardView, true);
  SetGameObjectActive(self._objItemRewardView, false);
  self.m_stoneRewardView:Render(self.m_viewModel.selectedModel.stoneTotal);
end

function ReturnNewsView:_RenderRogue()
  SetGameObjectActive(self._objStoneRewardView, false);
  local rewardItems = self.m_viewModel.selectedModel.rewardItems;
  SetGameObjectActive(self._objItemRewardView, #rewardItems > 0);
  self.m_itemRewardView:Render(rewardItems);
end

function ReturnNewsView:_RenderSandbox()
  SetGameObjectActive(self._objStoneRewardView, false);
  local rewardItems = self.m_viewModel.selectedModel.rewardItems;
  SetGameObjectActive(self._objItemRewardView, #rewardItems > 0);
  self.m_itemRewardView:Render(rewardItems);
end

function ReturnNewsView:_JumpToAct()
  local unlocked, alert = CS.Torappu.UI.ActivityUtil.CheckIfActivityUnlocked(self.m_viewModel.selectedModel.jumpDestination);
  local groupId = ReturnModel.me:GetCurrentGroupId();
  CS.Torappu.GameAnalytics.RecordBackflowNewsClicked(groupId, 
      BackflowNewsJumpType.MAIN, unlocked);
  if (unlocked) then
    CS.Torappu.UI.UIRouteUtil.RouteToStageActivity(self.m_viewModel.selectedModel.jumpDestination);
  else
    CS.Torappu.Lua.Util.ToastAlert(alert);
  end
end

function ReturnNewsView:_JumpToStage()
  CS.Torappu.GameAnalytics.RecordBackflowNewsClicked(ReturnModel.me:GetCurrentGroupId(), 
      BackflowNewsJumpType.MAIN, true);
  CS.Torappu.UI.UIRouteUtil.RouteToStage(self.m_viewModel.selectedModel.jumpDestination, nil);
end

function ReturnNewsView:_JumpToRogue()
  local unlocked = _ToastIfLocked(CS.Torappu.UI.UILockTarget.PERM_MODE);
  CS.Torappu.GameAnalytics.RecordBackflowNewsClicked(ReturnModel.me:GetCurrentGroupId(), 
      BackflowNewsJumpType.ROGUE, unlocked);
  if not unlocked then
    return;
  end
  CS.Torappu.UI.UIRouteUtil.RouteToRoguelikeTopic(self.m_viewModel.selectedModel.jumpDestination);
end

function ReturnNewsView:_JumpToSandbox()
  local unlocked = _ToastIfLocked(CS.Torappu.UI.UILockTarget.PERM_MODE);
  CS.Torappu.GameAnalytics.RecordBackflowNewsClicked(ReturnModel.me:GetCurrentGroupId(), 
      BackflowNewsJumpType.SANDBOX, unlocked);
  if not unlocked then
    return;
  end
  CS.Torappu.UI.UIRouteUtil.RouteToSandboxPerm(self.m_viewModel.selectedModel.jumpDestination);
end

function _ToastIfLocked(lockTarget)
  local isUnlocked = CS.Torappu.UI.UIGuideController.CheckIfUnlocked(lockTarget);
  if not isUnlocked then
    CS.Torappu.UI.UIGuideController.ToastOnLockedItemClicked(lockTarget);
  end
  return isUnlocked;
end
return ReturnNewsView;