



MainDlg = DlgMgr.DefineDialog("MainDlg", "Main/MainDlg");
MainDlg._cn = 0;
MainDlg._timer = 0;

function MainDlg:OnInit()
  
  

  self:AddButtonClickListener(self._testBtn, self._HandleClick);
  self:AddButtonClickListener(self._closeBtn, self._HandleClose);
  self:AddButtonClickListener(self._pageBtn, self._HandleOpenPage);
  
end

function MainDlg:_HandleClick(label)
  
  
  
  self:GetGroup():AddChildDlg(TestDlg);
end

function MainDlg:_HandleClose()
  self:Close();
end

function MainDlg:_HandleOpenPage()
  CS.Torappu.UI.UIPageController.OpenPage("character_repo");
end

function MainDlg._Update()
  print("xxxxx");
end