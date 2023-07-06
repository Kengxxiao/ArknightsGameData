


ReturnPageDlg = DlgMgr.DefineDialog("ReturnPageDlg", "Operation/Returnning/return_page_dlg", BridgeDlgBase);

function ReturnPageDlg:OnInit()
  self:SetPureGroup();
  self:AddButtonClickListener(self._btnClose, self._EventOnClose);

  self.m_useOld = ReturnModel.me:GetReturnVersion()

  if self.m_useOld then
    local initDlgStack = {ReturnMainDlg};
    local hasOnceReward = ReturnModel.me:HasOnceReward();
    if hasOnceReward then
      table.insert(initDlgStack, ReturnWelcomeDlg);
    end
    self:GetGroup():InitList(initDlgStack);
    
    if not hasOnceReward and ReturnModel.me:CheckIfNeedReadIntro() then
      ReturnModel.me:ShowGuide(true);
    end
  else
    local initDlgStack = { ReturnV2MainDlg };
    local hasOnceReward = ReturnV2Model.me:HasOnceReward();
    if hasOnceReward then
      table.insert(initDlgStack, ReturnV2WelcomeDlg);
    end
    self:GetGroup():InitList(initDlgStack);
  end
end

function ReturnPageDlg:OnResume()
  if self.m_useOld then
    ReturnModel.me:SetAlreadyPopup()
  else
    ReturnV2Model.me:SetAlreadyPopup()
  end
end

function ReturnPageDlg:_EventOnClose()
  self:Close();
end