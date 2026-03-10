

ReturnPageDlg = DlgMgr.DefineDialog("ReturnPageDlg", "Operation/[UC]Returning/return_page_dlg", BridgeDlgBase);

function ReturnPageDlg:OnInit()
  self:SetPureGroup();
  self:AddButtonClickListener(self._btnClose, self._EventOnClose);

  ReturnModel.me:CheckLocalTrack();
  local initDlgStack = { ReturnMainDlg };
  local hasOnceReward = ReturnModel.me:HasOnceReward();
  if hasOnceReward then
    table.insert(initDlgStack, ReturnWelcomeDlg);
  end
  self:GetGroup():InitList(initDlgStack);
end

function ReturnPageDlg:OnResume()
  ReturnModel.me:SetAlreadyPopup();
end

function ReturnPageDlg:_EventOnClose()
  self:Close();
end