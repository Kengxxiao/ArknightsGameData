local FadeSwitchTween = CS.Torappu.UI.FadeSwitchTween
local eutil = CS.Torappu.Lua.Util
local FloatParadeRewardRuleModel = require("Feature/Activity/FloatParade/FloatParadeRewardRuleModel")
local GROUPS_PER_SCREEN = 4
local FLOAT_TWEEN_DUR = 0.23




local FloatParadeRewardGroupPool = Class("FloatParadeRewardGroupPool", UIPanel)


function FloatParadeRewardGroupPool:Render(rewardItem)
  self._textCount.text = rewardItem.count.. ""
  self._textDesc.text = rewardItem.desc
end











local FloatParadeRewardGroupView = Class("FloatParadeRewardGroupView", UIPanel)

function FloatParadeRewardGroupView:OnInit()
  self.m_groupIdCache = -1
  self.m_poolAdapter = self:_ConstructPoolAdapter()
end


function FloatParadeRewardGroupView:Render(groupModel)
  
  if self.m_groupIdCache >=0 and self.m_groupIdCache == groupModel.groupId then
    return
  end
  self.m_groupModel = groupModel

  self._textTitle.text = groupModel.name

  self._textDate.text = eutil.Format("DAY{0}-{1}", groupModel.startDay, groupModel.endDay)

  local hasExtReward = groupModel:HasExtReward()
  eutil.SetActiveIfNecessary(self._panelExtReward, hasExtReward)
  if hasExtReward then
    self._textExtDesc.text = eutil.Format(StringRes.FLOATPARADE_EXT_REWARD_DESC, groupModel.extRewardDay)
    self._textExtCount.text = groupModel.extRewardCnt
  end

   self.m_poolAdapter:NotifyDataSetChanged()
end

function FloatParadeRewardGroupView:_ConstructPoolAdapter()
  return self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._poolLayout, 
      self._CreatePoolView, self._GetPoolCount, self._UpdatePoolView)
end

function FloatParadeRewardGroupView:_GetPoolCount()
  if not self.m_groupModel or not self.m_groupModel.rewardList then
    return 0
  end
  return #self.m_groupModel.rewardList
end


function FloatParadeRewardGroupView:_CreatePoolView(gameObj)
  return self:CreateWidgetByGO(FloatParadeRewardGroupPool, gameObj)
end


function FloatParadeRewardGroupView:_UpdatePoolView(index, poolView)
  poolView:Render(self.m_groupModel.rewardList[index+1])
end










FloatParadeRewardRulePanel = Class("FloatParadeRewardRulePanel", UIPanel);

function FloatParadeRewardRulePanel:OnInit()
  self.m_switchTween = FadeSwitchTween(self._canvasGroup, FLOAT_TWEEN_DUR)
  self.m_switchTween:Reset(false)
  self:AddButtonClickListener(self._btnBlank, FloatParadeRewardRulePanel._Hide)
  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnBlank)
  self.m_model = FloatParadeRewardRuleModel.new()
  self.m_groupAdapter = self:_ConstructGroupAdapter()
end


function FloatParadeRewardRulePanel:_ConstructGroupAdapter()
  local adapter = self:CreateCustomComponent(UISimpleLayoutAdapter,
      self, self._groupContainer, self._CreateGroupView, self._GetGroupCount, self._UpdateGroupView)
  return adapter
end


function FloatParadeRewardRulePanel:_CreateGroupView(gameObj)
  return self:CreateWidgetByGO(FloatParadeRewardGroupView, gameObj)
end

function FloatParadeRewardRulePanel:_GetGroupCount()
  local list = self.m_model.groupList
  if not list then
    return 0
  end
  return #list
end


function FloatParadeRewardRulePanel:_UpdateGroupView(index, view)
  local groupModel = self.m_model.groupList[index+1]
  view:Render(groupModel)
end



function FloatParadeRewardRulePanel:Show(activityId, curDayIndex)
  if activityId == nil then
    return
  end
  if self.m_switchTween == nil then
    return
  end
  if self.m_model == nil or (not self.m_model:Init(activityId, curDayIndex)) then
    return
  end
  self.m_groupAdapter:NotifyDataSetChanged()
  self.m_switchTween:Show()
  
  local scrollAction = CS.Torappu.UI.UILayoutDimensionActions.SetScrollVertPos()
  scrollAction.scroll = self._groupScroll
  scrollAction.pos = 1 - self.m_model:CalcFocusProgress(GROUPS_PER_SCREEN)
  self._groupListener:DoOnceOnPostLayout(scrollAction)
end

function FloatParadeRewardRulePanel:_Hide()
  if self.m_switchTween ~= nil then
    self.m_switchTween:Hide()
  end
end