local ReturnMissionGroupViewBase = require("Feature/Operation/Returning/Mission/ReturnMissionGroupViewBase");













local ReturnMissionGroupView = Class("ReturnMissionGroupView", ReturnMissionGroupViewBase);

local ReturnMissionListItemView = require("Feature/Operation/Returning/Mission/ReturnMissionListItemView");

function ReturnMissionGroupView:OnInit()
  self:AddButtonClickListener(self._btnClaim, self.EventOnClicked);
  self:AddButtonClickListener(self._btnOpenPage, self.EventOnOpenPageClicked);
end


function ReturnMissionGroupView:OnRender(viewModel)
  if viewModel == nil then
    return;
  end

  local displayMission = viewModel.displayMission;
  if displayMission == nil then
    return;
  end

  self.m_cachedIndex = viewModel.index;

  local isGroupClickable = viewModel.isMultiMission or displayMission.state == ReturnMissionItemState.COMPLETE;
  SetGameObjectActive(self._panelBtn, isGroupClickable);

  SetGameObjectActive(self._panelMulti, viewModel.isMultiMission);

  SetGameObjectActive(self._objBtnOpenPage, displayMission.state == ReturnMissionItemState.UNCOMPLETE and displayMission.jumpType ~= CS.Torappu.ReturnJumpType.NONE);

  if self.m_missionView == nil then
    self.m_missionView = self:CreateWidgetByPrefab(ReturnMissionListItemView, self._prefabMission, self._container);
    if self.m_missionView == nil then
      return;
    end
    self.m_missionView.createWidgetByGO = function(widgetCls, layout)
        return self:CreateWidgetByGO(widgetCls, layout);
      end;
    self.m_missionView.loadFunc = function(hubPath, spriteName)
        return self:LoadSprite(hubPath, spriteName);
      end;
    local graphic = self.m_missionView:GetGraphic();
    if graphic ~= nil then
      self._hotSpotImg:AttachGraphic(graphic);
    end
  end
  self.m_missionView:Render(displayMission);
end


function ReturnMissionGroupView:EventOnClicked()
  if self.eventOnClicked ~= nil then
    self.eventOnClicked:Call(self.m_cachedIndex);
  end
end


function ReturnMissionGroupView:EventOnOpenPageClicked()
  ReturnMainDlg.JumpToTarget(self.m_missionView.m_viewModel.jumpType, self.m_missionView.m_viewModel.jumpDestination);
end

return ReturnMissionGroupView;