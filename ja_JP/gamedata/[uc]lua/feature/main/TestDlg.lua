


TestDlg = DlgMgr.DefineDialog("TestDlg", "Main/TestDlg");
TestDlg._timeLabel = nil;
TestDlg._timer = nil;

function TestDlg:OnInit()

  self:_SynTime();
  self._timer = self:Interval(1, -1, self._SynTime);

  self:AddButtonClickListener(self._btn, self._Click, self._btn);
end

function TestDlg:_Click(btn)
  if self._timer then
    CS.Torappu.Lua.LuaUIUtil.GetText(btn.gameObject, "Text").text = "继续";
    self._timer = self:DestroyTimer(self._timer);
  else
    CS.Torappu.Lua.LuaUIUtil.GetText(btn.gameObject, "Text").text = "暂停";
    self._timer = self:Interval(1, -1, self._SynTime);
  end
end

function TestDlg:_SynTime()
  self._timeLabel.text = CS.System.DateTime.Now:ToString();
end