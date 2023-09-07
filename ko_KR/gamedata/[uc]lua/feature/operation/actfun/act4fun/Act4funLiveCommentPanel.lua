local luaUtils = CS.Torappu.Lua.Util;
local Act4funLiveSidePanel = require "Feature/Operation/ActFun/Act4fun/Act4funLiveSidePanel";















local Act4funLiveCommentPanel = Class("Act4funLiveCommentPanel", Act4funLiveSidePanel)

local Act4funLiveCommentScView = require("Feature/Operation/ActFun/Act4fun/LiveComment/Act4funLiveCommentScView");
local Act4funLiveCommentItemView = require("Feature/Operation/ActFun/Act4fun/LiveComment/Act4funLiveCommentItemView");

Act4funLiveCommentPanel.COMMENT_ITEM_TYPE = 100;
local ITEM_SIZE = 57;


function Act4funLiveCommentPanel:OnInit()
  self:MoveInOut(true, true);
  self.m_scView = self:CreateWidgetByGO(Act4funLiveCommentScView, self._panelSc);
  self.m_scView.onScClicked = Event.Create(self, self._OnScClicked);

  local host = self;
  local layout = self._layout;
  local viewDefineTable = {};
  viewDefineTable[Act4funLiveCommentPanel.COMMENT_ITEM_TYPE] = {
    prefab = self._itemPrefab,
    cls = Act4funLiveCommentItemView
  };
  local updateViewFunc = self._RefreshCommentItem;
  self.m_adapter = self:CreateCustomComponent(UIVirtualViewAdapter, host, layout, viewDefineTable, updateViewFunc);
  self.m_dataList = {};

  self.m_dimCallback = self:CreateCustomComponent(UILayoutDimensionAdapter, self._dimensionListener);
  self.m_eventTweenScroll = Event.Create(self, self._TweenScrollToZero);
end


function Act4funLiveCommentPanel:OnViewModelUpdate(data)
  self.m_cachedData = data;
  if data == nil then
    return;
  end
  local inPhotoSelect = data:NeedShowPhotoPanel();
  self:MoveInOut(not inPhotoSelect);
  if inPhotoSelect then
    return;
  end
  self.m_scView:Render(data.currSc);

  if not self:_CheckIfNeedShowComment() then
    TimerModel.me:Destroy(self.m_timer);
    self.m_timer = nil;
  elseif self.m_timer == nil then
    self:_TryShowComment();
  end
end

function Act4funLiveCommentPanel:_TryShowComment()
  if self.m_cachedData == nil then
    return;
  end
  local commentGroupModel = self:_GetCommentGroupModel();
  if not self:_CheckIfNeedShowComment() or commentGroupModel == nil then
    self.m_timer = nil;
    return;
  end
  local nextComment = commentGroupModel:NextComment();
  if nextComment == nil then
    self.m_timer = nil;
    return;
  end
  table.insert(self.m_dataList, nextComment);
  self.m_adapter:AddView({
    viewType = Act4funLiveCommentPanel.COMMENT_ITEM_TYPE,
    data = nextComment,
    size = ITEM_SIZE
  });
  self.m_dimCallback:DoOnceOnPostLayout(self.m_eventTweenScroll);

  local delayTime = RandomUtil.RangeFloat(commentGroupModel.minDelayTime, commentGroupModel.maxDelayTime);
  if CS.Torappu.MathUtil.LE(delayTime, 0) then
    return;
  end
  self.m_timer = self:Delay(delayTime, function()
    self:_TryShowComment();
  end);
  self:SetScaled(self.m_timer);
end


function Act4funLiveCommentPanel:_CheckIfNeedShowComment()
  local commentModel = self:_GetCommentGroupModel();
  if commentModel == nil then
    return false;
  end
  return commentModel.playing;
end


function Act4funLiveCommentPanel:_GetCommentGroupModel()
  if self.m_cachedData == nil then
    return nil;
  end
  local currPerform = self.m_cachedData.currPerform;
  if currPerform == nil then
    return nil;
  end
  return currPerform.commentModel;
end

function Act4funLiveCommentPanel:_OnScClicked()
  if self.m_cachedData == nil or self.m_cachedData.currSc == nil then
    return;
  end
  self.m_cachedData.currSc.isClicked = true;
end




function Act4funLiveCommentPanel:_RefreshCommentItem(viewType, widget, model)
  if viewType ~= Act4funLiveCommentPanel.COMMENT_ITEM_TYPE then
    return;
  end
  widget:Render(model, function(name)
    return self:LoadSpriteFromAutoPackHub(
        CS.Torappu.ResourceUrls.GetAct4funCommentIconHubPath(), name);
  end);
end

function Act4funLiveCommentPanel:_TweenScrollToZero()
  self._scrollRect:DOKill();
  self._scrollRect:DoScrollVertTo(0, 1);
end

return Act4funLiveCommentPanel;