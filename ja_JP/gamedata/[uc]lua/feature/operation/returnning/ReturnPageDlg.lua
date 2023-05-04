

ReturnPageDlg = DlgMgr.DefineDialog("ReturnPageDlg", "Operation/Returnning/return_page_dlg", BridgeDlgBase);

function ReturnPageDlg:OnInit()
  self:SetPureGroup();
  self:AddButtonClickListener(self._btnClose, self._EventOnClose);

  local initDlgStack = {ReturnMainDlg};
  local hasOnceReward = ReturnModel.me:HasOnceReward();
  if hasOnceReward then
    table.insert(initDlgStack, ReturnWelcomeDlg);
  end
  self:GetGroup():InitList(initDlgStack);
  
  if not hasOnceReward and ReturnModel.me:CheckIfNeedReadIntro() then
    ReturnModel.me:ShowGuide(true);
  end
end

function ReturnPageDlg:OnResume()
  ReturnModel.me:SetAlreadyPopup();
end

function ReturnPageDlg:_EventOnClose()
  print("xxxxxx");
  self:Close();
end