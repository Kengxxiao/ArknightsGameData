local luaUtils = CS.Torappu.Lua.Util;











ActFun7MainDlg = DlgMgr.DefineDialog("ActFun7MainDlg", "Activity/ActFun/Actfun7/actfun7_dlg", DlgBase)
ActFun7MainDlg.DLG_NAME = "fun7"

local Act7FunMainView = require("Feature/Operation/ActFun/Act7fun/Entry/Act7FunMainView")
local Act7FunMainViewModel = require("Feature/Operation/ActFun/Act7fun/Entry/Act7FunMainViewModel")

function ActFun7MainDlg:OnInit()
  self:_InitGameData();
  self:_InitBGM();
  self:_InitMainView();
end

function ActFun7MainDlg:OnResume()
  self:_Refresh();
end

function ActFun7MainDlg:_InitBGM()
  local config = CS.Torappu.UI.UIMusicManager.ChunkConfig();
  config.signal = CS.Torappu.Audio.Consts.ACTIVITY_LOADED;
  config.subSignal = self._subsignal;
  CS.Torappu.UI.UIMusicManager.ModifyMusicChunk(self.m_parent:GetInstanceID(), config);
  CS.Torappu.UI.UIMusicManager.SyncPlayingMusic();
end

function ActFun7MainDlg:_InitGameData()
  self.m_viewModel = self:CreateViewModel(Act7FunMainViewModel)
  self.m_viewModel:InitData();
end

function ActFun7MainDlg:_Refresh()
  if self.m_viewModel == nil then
    return;
  end
  self.m_viewModel:RefreshData();

  if self.m_activeView == nil then
    return;
  end
  self.m_activeView:RefreshView();
end

function ActFun7MainDlg:_InitMainView()
  if self.m_viewModel == nil then 
    return;
  end
  if self.m_activeView ~= nil then
    return;
  end
  if self.m_viewModel.useWinStyle then
    self.m_activeView = self:CreateWidgetByPrefab(Act7FunMainView, self._winStyleView, self._viewContainer);
  else
    self.m_activeView = self:CreateWidgetByPrefab(Act7FunMainView, self._unityStyleView, self._viewContainer);
  end
  self.m_activeView:OnInitWithDlg(self, self.m_viewModel);
end

function ActFun7MainDlg:EventOnAvgBtnClick()
  CS.Torappu.Lua.LuaActivityEntry.StartStoryWithSyncMusic(self._avgStoryId);
end

function ActFun7MainDlg:EventOnCollectionBtnClick()
  local funMainDlg = self.m_parent;
  funMainDlg:SetRecentPlayedAct(ActFun7MainDlg.DLG_NAME);
  funMainDlg:GetGroup():SwitchChildDlg(ActFunCollectionDlg);
end

function ActFun7MainDlg:EventOnCloseClick()
  self:Close();
end

function ActFun7MainDlg:EventOnStageClick(stageId)
  if self.m_viewModel == nil then
    return;
  end
  local stageModel = self.m_viewModel.stageModels[stageId];
  if not stageModel.isUnlocked then
    local toastText = CS.Torappu.I18N.I18nUtils.GetText(CS.Torappu.TextRes.COMMON_MISSION_LOCKED_TOAST);
    luaUtils.TextToast(toastText);
    return;
  end
  CS.Torappu.LocalTrackStore.instance:ConsumeTrack(CS.Torappu.Activity.Act7fun.Act7FunUtils.ACT7FUN_NEW_STAGE_TRACK_TYPE, stageId);
  self:_StartAct7FunBattle(self._aprilFoolId, stageId);
end


function ActFun7MainDlg:_StartAct7FunBattle(actId, stageId)
  local startServiceConfig = CS.Torappu.Activity.Act7fun.Act7FunBattleStartConfig(stageId)
  local finishServiceConfig = CS.Torappu.Activity.Act7fun.Act7FunBattleFinishServerConfig(
      CS.Torappu.Activity.Act7fun.Act7FunService.FUN_BATTLE_FINISH)
  local suc, stageData = CS.Torappu.ActivityDB.data.actFunData.stages:TryGetValue(stageId)
  if not suc then
    return
  end
  local battleInfo = CS.Torappu.Battle.BattleStageInfo.CreateWithAprilFoolStage(stageData)
  if battleInfo == nil then
    return
  end

  local actMeta = CS.Torappu.Battle.BattleActivityMeta()
  actMeta.activityId = actId 
  actMeta.backAsHomeAct = true
  actMeta.overrideBattleFinish = true
  
  local bundle = CS.Torappu.DataBundle()
  bundle:SetString(ActFunMainDlgGroup.KEY_INITDLG, ActFun7MainDlg.DLG_NAME)
  actMeta.meta = bundle
  
  local gameModeMeta = {
    isDeterministic = false,
    modeType = CS.Torappu.Battle.GameModeMeta.GameModeType.ACT_7_FUN
  }
  local gameTagMeta = {
    gameTag = CS.Torappu.Battle.GameTagMeta.ACTFUN
  }
  
  local param = {
    stageId = stageId,
    isPractise = false,
    isAutoBattle = false,
    assistIsFriend = false,
    assistIsPredefined = true,
    squadForRequest = nil,
    assistFriend = nil,
    squadLocal = nil,
    isHandBookStage = false,
    runeList = nil,
    customizeStartService = startServiceConfig,
    customizedFinishService = finishServiceConfig,
    sysMenuStyle = CS.Torappu.Battle.UI.BattleSysMenuStyle.NO_REWARD,
    overrideStageInfo = battleInfo,
    actMeta = actMeta,
    gameModeMeta = gameModeMeta,
    isOverrideBGM = true,
    gameTagMeta = gameTagMeta,
  }
  CS.Torappu.BattleStartController.StartBattle(param)
end