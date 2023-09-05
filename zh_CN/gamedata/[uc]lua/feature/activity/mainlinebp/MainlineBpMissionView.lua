local luaUtils = CS.Torappu.Lua.Util;
local FadeSwitchTween = CS.Torappu.UI.FadeSwitchTween;
















local MainlineBpMissionView = Class("MainlineBpMissionView", UIPanel);
local MainlineBpMissionAdapter = require("Feature/Activity/MainlineBp/MainlineBpMissionAdapter");

function MainlineBpMissionView:OnInit()
  self:AddButtonClickListener(self._btnConfirmAll, self._OnConfirmAllButtonClicked);

  self.m_adapter = self:CreateCustomComponent(MainlineBpMissionAdapter, self._objAdapter, self);
  self.m_adapter.missionList = {};

  self.m_switchTween = FadeSwitchTween(self._canvasSelf, tonumber(self._floatTweenDur));
  self.m_switchTween:Reset(false);

  self.m_cachedFocusCache = -1;
end

function MainlineBpMissionView:InitEventFunc()
  self.m_adapter.loadDynImage = self.loadDynImage;
  self.m_adapter.onMissionClicked = self.onMissionClicked;
  self.m_adapter.onJumpToZoneClicked = self.onJumpToZoneClicked;
end


function MainlineBpMissionView:OnViewModelUpdate(data)
  if data == nil then
    return;
  end

  luaUtils.SetActiveIfNecessary(self._panelBtnConfirmAll, data.canConfirmMission);
  self.m_switchTween.isShow = data.tabState == MainlineBpTabState.MISSION and data.showBpUpDetailPanel == false;
  self.m_adapter.m_actId = data.actId;
  self.m_adapter.missionList = data.missionGroupModelList;
  local focusPosition = data.missionListFocusPosition;
  local needFocus = focusPosition ~= nil and
      focusPosition ~= -1 and
      self.m_cachedFocusCache < data.missionFocusCache and
      data.tabState == MainlineBpTabState.MISSION;
  if needFocus then
    self.m_cachedFocusCache = data.missionFocusCache;
    self.m_adapter:NotifyRebuildWithIndex(focusPosition);
  else
    self.m_adapter:NotifyDataSourceChanged();
  end
end

function MainlineBpMissionView:_OnConfirmAllButtonClicked()
  if self.onConfirmAllMissionClicked == nil then
    return;
  end
  Event.Call(self.onConfirmAllMissionClicked);
end

return MainlineBpMissionView;