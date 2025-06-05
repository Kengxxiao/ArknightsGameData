local luaUtils = CS.Torappu.Lua.Util











local CollectionSimpleMainView = Class("CollectionSimpleMainView", UIPanel)
local CollectionSimpleTaskListView = require("Feature/Activity/CollectionSimpleMode/CollectionSimpleTaskListView")
local CollectionSimpleRewardView = require("Feature/Activity/CollectionSimpleMode/CollectionSimpleRewardView")
local CollectionSimpleJumpBtnView = require("Feature/Activity/CollectionSimpleMode/CollectionSimpleJumpBtnView")

function CollectionSimpleMainView:OnInit()
  if self._rewardView then
    self.m_rewardView = self:CreateWidgetByGO(CollectionSimpleRewardView, self._rewardView)
  end
  if self._jumpBtnView then
    self.m_jumpBtnView = self:CreateWidgetByGO(CollectionSimpleJumpBtnView, self._jumpBtnView)
  end
  if self._missionListView then
    self.m_missionListView = self:CreateWidgetByGO(CollectionSimpleTaskListView, self._missionListView)
  end
end

function CollectionSimpleMainView:InitEventFunc()
  if self.m_jumpBtnView then
    self.m_jumpBtnView.onJumpBtnClicked = self.onJumpBtnClicked
  end
  if self.m_missionListView then
    self.m_missionListView.onMissionItemClaimed = self.onMissionItemClaimed
    self.m_missionListView.onClaimAllClicked = self.onClaimAllClicked
    self.m_missionListView:InitEventFunc()
  end
end


function CollectionSimpleMainView:OnViewModelUpdate(data)
  if data == nil or not data.isSimpleMode or data.simpleMainModel == nil then
    return
  end
  local model = data.simpleMainModel

  self:_RenderMissionList(model)
  self:_RenderRewardView(model)
  self:_RenderJumpBtnView(model)
  self:_RenderActEndTimeText(model.actEndTimeStr)
end


function CollectionSimpleMainView:_RenderMissionList(model)
  if not model or not self.m_missionListView then
    return
  end

  self.m_missionListView:Render(model)
end


function CollectionSimpleMainView:_RenderRewardView(model)
  if not model or not model.rewardViewModel or not self.m_rewardView then
    return
  end

  self.m_rewardView:Render(model.rewardViewModel)
end


function CollectionSimpleMainView:_RenderJumpBtnView(model)
  if not self.m_jumpBtnView or not model or not model.rewardViewModel then
    return
  end

  local themeColor = model.rewardViewModel.themeColor
  self.m_jumpBtnView:Render(model.canJumpToFunc, themeColor)
end


function CollectionSimpleMainView:_RenderActEndTimeText(endTimeStr)
  if not self._actEndText then
    return
  end

  self._actEndText.text = endTimeStr
end

return CollectionSimpleMainView