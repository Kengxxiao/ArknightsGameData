


ReturnNoticeDlg = DlgMgr.DefineDialog("ReturnNoticeDlg", "Operation/[UC]Returning/return_notice_dlg");

function ReturnNoticeDlg:OnInit()
  self:AddButtonClickListener(self._btnClose, self._EventOnCloseClicked);
  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnClose);
end


function ReturnNoticeDlg:_EventOnCloseClicked()
  self:Close();
end