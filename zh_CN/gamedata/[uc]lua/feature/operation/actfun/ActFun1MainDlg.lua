local luaUtils = CS.Torappu.Lua.Util;








ActFun1MainDlg = DlgMgr.DefineDialog("ActFun1MainDlg", "Activity/ActFun/actfun1_dlg", DlgBase)

ActFun1MainDlg.DLG_NAME = "fun1"

function ActFun1MainDlg:OnInit()
  self:_InitBGM()
  self:AddButtonClickListener(self._btnAvg, self.EventOnAvgBtnClick)
  self:AddButtonClickListener(self._btnList, self.EventOnCollectionBtnClick)
end

function ActFun1MainDlg:_InitBGM()
  
  CS.Torappu.UI.UIMusicManager.RemoveMusicChunk(self.m_parent:GetInstanceID())
  CS.Torappu.UI.UIMusicManager.SyncPlayingMusic()
end

function ActFun1MainDlg:EventOnAvgBtnClick()
  CS.Torappu.Lua.LuaActivityEntry.StartStoryWithSyncMusic(self._avgStoryId)
end

function ActFun1MainDlg:EventOnCollectionBtnClick()
  local parent = self.m_parent
  parent:SetRecentPlayedAct(ActFun1MainDlg.DLG_NAME)
  parent:GetGroup():SwitchChildDlg(ActFunCollectionDlg)
end

