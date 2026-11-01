

OpenServerV3PageDlg = DlgMgr.DefineDialog("OpenServerV3PageDlg", "Operation/[UC]OpenServerV3/open_server_v3_page_dlg", BridgeDlgBase);

function OpenServerV3PageDlg:OnInit()
  self:SetPureGroup();
  self:AddButtonClickListener(self._btnClose, self._EventOnClose);

  local initDlgStack = { OpenServerV3MainDlg };
  self:GetGroup():InitList(initDlgStack);
end

function OpenServerV3PageDlg:OnResume()
  OpenServerV3Model.me:SetAlreadyPopup();
  local topDlg = self:GetGroup():GetTopDlg();
  if topDlg ~= nil and topDlg.class == OpenServerV3MainDlg then
    topDlg:OnResume();
  end
end

function OpenServerV3PageDlg:_EventOnClose()
  self:Close();
end