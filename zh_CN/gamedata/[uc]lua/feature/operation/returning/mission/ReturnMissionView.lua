























local ReturnMissionView = Class("ReturnMissionView", UIPanel);

local ReturnMissionGroupView = require("Feature/Operation/Returning/Mission/ReturnMissionGroupView");
local ReturnMissionClaimAllView = require("Feature/Operation/Returning/Mission/ReturnMissionClaimAllView");
local ReturnMissionTitleView = require("Feature/Operation/Returning/Mission/ReturnMissionTitleView");
local ReturnMissionPointItemView = require("Feature/Operation/Returning/Mission/ReturnMissionPointItemView");

ReturnMissionView.MISSION_ITEM_TYPE = 10;
ReturnMissionView.TITLE_ITEM_TYPE = 20;
ReturnMissionView.CLAIM_ALL_ITEM_TYPE = 30;

local CLAIM_ALL_SIZE = 72;
local TITLE_SIZE = 39;
local MISSION_SIZE = 115;

function ReturnMissionView:OnInit()
  self.m_seqNum = -1;
  local viewDefineTable = {};
  viewDefineTable[ReturnMissionView.MISSION_ITEM_TYPE] = {
    prefab = self._missionPrefab,
    cls = ReturnMissionGroupView,
  };
  viewDefineTable[ReturnMissionView.TITLE_ITEM_TYPE] = {
    prefab = self._titlePrefab,
    cls = ReturnMissionTitleView,
  };
  viewDefineTable[ReturnMissionView.CLAIM_ALL_ITEM_TYPE] = {
    prefab = self._claimAllPrefab,
    cls = ReturnMissionClaimAllView,
  };
  self.m_adapter = self:CreateCustomComponent(UIVirtualViewAdapter, self, self._layout, viewDefineTable, self._RefreshItem);

  self.AddButtonClickListener(self, self._btnPointDetail, self._EventOnPointDetailClicked);
  self.AddButtonClickListener(self, self._btnPointReward, self._EventOnPointClaimClicked);

  self.m_pointRewardView = {};
  table.insert(self.m_pointRewardView, self:_CreatePointRewardView(self._pointRewardView1));
  table.insert(self.m_pointRewardView, self:_CreatePointRewardView(self._pointRewardView2));
  table.insert(self.m_pointRewardView, self:_CreatePointRewardView(self._pointRewardView3));
end



function ReturnMissionView:_CreatePointRewardView(layout)
  local pointRewardView = self:CreateWidgetByGO(ReturnMissionPointItemView, layout);
  if pointRewardView ~= nil then
    pointRewardView.createWidgetByPrefab = function(widgetCls, layout, container)
      return self:CreateWidgetByPrefab(widgetCls, layout, container);
    end;
  end
  return pointRewardView;
end


function ReturnMissionView:OnViewModelUpdate(data)
  if data == nil or data.missionViewModel == nil then
    return;
  end
  local missionModel = data.missionViewModel;

  if self.m_seqNum < missionModel.seqNum then
    self._scrollRect.verticalNormalizedPosition = 1;
  end
  self.m_seqNum = missionModel.seqNum;

  self._textEndTime.text = missionModel.endTimeDesc;

  self._textPoint.text = missionModel.currentPoint;
  for index, pointView in ipairs(self.m_pointRewardView) do
    if pointView ~= nil then
      pointView:Render(missionModel.pointList[index]);
    end
  end
  SetGameObjectActive(self._panelPointRewardCanClaim, missionModel.hasPointRewardCanClaim);

  self.m_adapter:RemoveAllViews();
  for index, model in ipairs(missionModel.missionList) do
    if model.groupType == ReturnMissionGroupType.CLAIM_ALL then
      self.m_adapter:AddView({
        viewType = ReturnMissionView.CLAIM_ALL_ITEM_TYPE,
        data = model,
        size = CLAIM_ALL_SIZE,
      });
    elseif model.groupType == ReturnMissionGroupType.MISSION then
      self.m_adapter:AddView({
        viewType = ReturnMissionView.MISSION_ITEM_TYPE,
        data = model,
        size = MISSION_SIZE,
      });
    else
      self.m_adapter:AddView({
        viewType = ReturnMissionView.TITLE_ITEM_TYPE,
        data = model,
        size = TITLE_SIZE,
      });
    end
  end
  self.m_adapter:NotifyRebuildAll();
end




function ReturnMissionView:_RefreshItem(viewType, widget, model)
  widget.loadFunc = function(hubPath, spriteName)
      return self:LoadSpriteFromAutoPackHub(hubPath, spriteName);
    end;
  widget.createWidgetByGO = function(widgetCls, layout)
      return self:CreateWidgetByGO(widgetCls, layout);
    end;
  widget.createWidgetByPrefab = function(widgetCls, layout, parent)
      return self:CreateWidgetByPrefab(widgetCls, layout, parent);
    end;
  if viewType == ReturnMissionView.MISSION_ITEM_TYPE then
    widget.eventOnClicked = Event.Create(self, self._EventOnMissionGroupClicked);
  elseif viewType == ReturnMissionView.CLAIM_ALL_ITEM_TYPE then
    widget.eventOnClicked = Event.Create(self, self._EventOnClaimAllClicked);
  end
  widget:Render(model);
end



function ReturnMissionView:_EventOnMissionGroupClicked(index)
  if self.eventOnMissionClicked == nil then
    return;
  end
  self.eventOnMissionClicked:Call(index);
end


function ReturnMissionView:_EventOnClaimAllClicked()
  if self.eventOnClaimAllClicked == nil then
    return;
  end
  self.eventOnClaimAllClicked:Call();
end

function ReturnMissionView:_EventOnPointDetailClicked()
  if self.eventOnPointDetailClicked == nil then
    return;
  end
  self.eventOnPointDetailClicked:Call();
end

function ReturnMissionView:_EventOnPointClaimClicked()
  if self.eventOnPointRewardClicked == nil then
    return;
  end
  self.eventOnPointRewardClicked:Call();
end

return ReturnMissionView;