local luaUtils = CS.Torappu.Lua.Util;






















ActFun6MainDlg = DlgMgr.DefineDialog("ActFun6MainDlg", "Activity/ActFun/Actfun6/actfun6_dlg", DlgBase)
ActFun6MainDlg.DLG_NAME = "fun6"

function ActFun6MainDlg:OnInit()
  self:_InitBGM();
  self:_LoadGameData();
  CS.Torappu.TorappuAudio.PlayUI(CS.Torappu.Audio.Consts.InternalSounds[CS.Torappu.Audio.UiInternalSoundType.StagePush]);
  
  self._animWrapper:InitIfNot();
  self._animWrapper:SampleClipAtBegin(self._entryAnimId);
  if self.m_entryAnimTween ~= nil and self.m_entryAnimTween:IsPlaying() then
    self.m_entryAnimTween:Kill();
    self.m_entryAnimTween = nil
  end
  self.m_entryAnimTween = self._animWrapper:PlayWithTween(self._entryAnimId):SetEase(CS.DG.Tweening.Ease.Linear);
  self:AddButtonClickListener(self._btnAvg, self.EventOnAvgBtnClick);
  self:AddButtonClickListener(self._btnOpenZone, self.EventOnAct6FunZoneBtnClick);
  self:AddButtonClickListener(self._btnOpenCollection, self.EventOnCollectionBtnClick);

  self:AddButtonClickListener(self._squadBtn, self.EventOnSquadBtnClick);
  self:AddButtonClickListener(self._charBtn, self.EventOnCharBtnClick);
  self:AddButtonClickListener(self._shopBtn, self.EventOnShopBtnClick);
  self:AddButtonClickListener(self._recruitNormalBtn, self.EventOnRecruitNormalBtnClick);
  self:AddButtonClickListener(self._recruitAdvanceBtn, self.EventOnRecruitAdvanceBtnClick);
  self:AddButtonClickListener(self._missionBtn, self.EventOnMissionBtnClick);
  self:AddButtonClickListener(self._buildingBtn, self.EventOnBuildBtnClick);
  self:AddButtonClickListener(self._repoBtn, self.EventOnRepoBtnClick);

  self:_RefreshTrackPoint();
end

function ActFun6MainDlg:OnResume()
  self:_RefreshTrackPoint();
end

function ActFun6MainDlg:_RefreshTrackPoint(...)
  local haveReward = CS.Torappu.Activity.Act6fun.Act6FunUtils.CheckHaveRewardToClaim();
  luaUtils.SetActiveIfNecessary(self._rewardTrackPoint, haveReward);
end

function ActFun6MainDlg:_InitBGM()
  local config = CS.Torappu.UI.UIMusicManager.ChunkConfig();
  config.signal = CS.Torappu.Audio.Consts.ACTIVITY_LOADED;
  config.subSignal = self._subsignal;
  CS.Torappu.UI.UIMusicManager.ModifyMusicChunk(self.m_parent:GetInstanceID(), config);
  CS.Torappu.UI.UIMusicManager.SyncPlayingMusic();
end

function ActFun6MainDlg:_LoadGameData()
  local act6FunData = CS.Torappu.ActivityDB.data.actFunData.act6FunData;
  if act6FunData == nil or act6FunData.constData == nil or act6FunData.constData.functionToastList == nil then
    return;
  end
  self.m_funcToastTable = ToLuaArray(act6FunData.constData.functionToastList);
end

function ActFun6MainDlg:EventOnAvgBtnClick()
  CS.Torappu.Lua.LuaActivityEntry.StartStoryWithSyncMusic(self._avgStoryId);
end

function ActFun6MainDlg:EventOnCollectionBtnClick()
  local funMainDlg = self.m_parent;
  funMainDlg:SetRecentPlayedAct(ActFun6MainDlg.DLG_NAME);
  funMainDlg:GetGroup():SwitchChildDlg(ActFunCollectionDlg);
end

function ActFun6MainDlg:EventOnAct6FunZoneBtnClick()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  CS.Torappu.Activity.Act6fun.Act6FunUtils.OpenAct6FunZoneMapPage(self._aprilFoolId,
      self._act6FunZoneId, CS.Torappu.UI.Stage.ActivityCustomZoneMapPage.InitState.CUSTOM_ZONE_STATE);
end

function ActFun6MainDlg:EventOnSquadBtnClick()
  self:_ShowToast(self.m_funcToastTable[1]);
end

function ActFun6MainDlg:EventOnCharBtnClick()
  self:_ShowToast(self.m_funcToastTable[2]);
end

function ActFun6MainDlg:EventOnShopBtnClick()
  self:_ShowToast(self.m_funcToastTable[3]);
end

function ActFun6MainDlg:EventOnRecruitNormalBtnClick()
  self:_ShowToast(self.m_funcToastTable[4]);
end

function ActFun6MainDlg:EventOnRecruitAdvanceBtnClick()
  self:_ShowToast(self.m_funcToastTable[5]);
end

function ActFun6MainDlg:EventOnMissionBtnClick()
  self:_ShowToast(self.m_funcToastTable[6]);
end

function ActFun6MainDlg:EventOnBuildBtnClick()
  self:_ShowToast(self.m_funcToastTable[7]);
end

function ActFun6MainDlg:EventOnRepoBtnClick()
  self:_ShowToast(self.m_funcToastTable[8]);
end

function ActFun6MainDlg:_ShowToast(toastStr)
  if toastStr == nil then
    return;
  end
  luaUtils.TextToast(toastStr);
end