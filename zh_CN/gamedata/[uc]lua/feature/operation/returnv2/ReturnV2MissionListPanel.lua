local luaUtil = CS.Torappu.Lua.Util
local FadeSwitchTween = CS.Torappu.UI.FadeSwitchTween;









local ReturnV2MissionListPanel = Class("ReturnV2MissionListPanel", UIPanel)
local ReturnV2MissionAdapter = require("Feature/Operation/ReturnV2/ReturnV2MissionAdapter")

function ReturnV2MissionListPanel:OnInit()
  self.m_adapter = self:CreateCustomComponent(ReturnV2MissionAdapter, self._objAdapter, self)
  self.m_adapter.missionList = {};
  self:AddButtonClickListener(self._btnBackPress, self._ClosePanel)
  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnBackPress)
  self.m_switchTween = FadeSwitchTween(self._canvasSelf, tonumber(self._floatTweenDur));
  self.m_switchTween:Reset(false);
end


function ReturnV2MissionListPanel:OnViewModelUpdate(data)
  if data == nil or data.tabState ~= ReturnV2StateTabStatus.STATE_TAB_TASK then
    return
  end

  local showPanel = data.showMissionListPanel
  self.m_switchTween.isShow = showPanel
  if showPanel then
    local activeGroupModel = data:GetMissionGroup(data.activeMissionGroupId)
    self.m_adapter.missionList = activeGroupModel.missionList
    self.m_adapter:NotifyDataSourceChanged()
    self.m_adapter:NotifyRebuildWithIndex(0)
  end
end

function ReturnV2MissionListPanel:_ClosePanel()
  if self.closePanelEvent then
    self.closePanelEvent:Call()
  end
end

return ReturnV2MissionListPanel