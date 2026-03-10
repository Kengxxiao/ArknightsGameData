





ReturnMissionListDlg = DlgMgr.DefineDialog("ReturnMissionListDlg", "Operation/[UC]Returning/return_mission_dlg");

local ReturnMissionListAdapter = require("Feature/Operation/Returning/Mission/ReturnMissionListAdapter");

function ReturnMissionListDlg:OnInit()
  self:_InitIfNot();
  self:AddButtonClickListener(self._btnClose, self._EventOnCloseClicked);
  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnClose);
end


function ReturnMissionListDlg:Render(groupModel)
  self:_InitIfNot();
  if groupModel == nil then
    return;
  end
  self.m_adapter.missionList = groupModel.missionList;
  self.m_adapter:NotifyRebuild();
end


function ReturnMissionListDlg:_InitIfNot()
  if self.m_hasInited then
    return;
  end
  self.m_hasInited = true;
  self.m_adapter = self:CreateCustomComponent(ReturnMissionListAdapter, self._panelContent, self);
  self.m_adapter.createWidgetByGO = function(widgetCls, layout)
      return self:CreateWidgetByGO(widgetCls, layout);
    end;
  self.m_adapter.loadFunc = function(hubPath, spriteName)
      return self:LoadSpriteFromAutoPackHub(hubPath, spriteName);
    end;
end


function ReturnMissionListDlg:_EventOnCloseClicked()
  self:Close();
end