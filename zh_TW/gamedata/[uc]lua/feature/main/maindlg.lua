---@class MainDlg : DlgBase
---@field _testBtn Button
---@field _closeBtn Button
---@field _pageBtn Button
MainDlg = DlgMgr.DefineDialog("MainDlg", "Main/MainDlg");
MainDlg._cn = 0;
MainDlg._timer = 0;

function MainDlg:OnInit()
  -- local label = self:GetText("Text")
  -- label.text = "lua ui修改测试";

  self:AddButtonClickListener(self._testBtn, self._HandleClick);
  self:AddButtonClickListener(self._closeBtn, self._HandleClose);
  self:AddButtonClickListener(self._pageBtn, self._HandleOpenPage);
  -- self._timer = self:Interval(2, -1, self._Update );
end

function MainDlg:_HandleClick(label)
  -- self._cn = self._cn + 1;
  -- label.text = "点了".. self._cn .."下";
  -- self:DestroyTimer(self._timer);
  DlgMgr.FetchDlg(TestDlg);
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