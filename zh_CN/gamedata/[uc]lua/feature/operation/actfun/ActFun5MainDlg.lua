local luaUtils = CS.Torappu.Lua.Util;






























ActFun5MainDlg = DlgMgr.DefineDialog("ActFun5MainDlg", "Activity/ActFun/Actfun5/actfun5_dlg", DlgBase)
ActFun5MainDlg.DLG_NAME = "fun5"

local ANIM_ENTER = "fool_home_stage_entry"
local ANIM_LOOP = "fool_home_stage_entry_loop"
local ANIM_LOOP_BKG = "fool_home_stage_light_rotation_loop"
local RECORD_TRACK_TYPE = "ACT5FUN_NEW_RECORD"
local KEY_TRACK_NEW_RECORD = "key_track_new_record"
local DEFAULT_SUPER_SCORE = 999999999


function ActFun5MainDlg:OnInit()
  self:_InitFromGameData(self._aprilFoolId)
  self:_InitBGM()

  self:AddButtonClickListener(self._btnAvg, self.EventOnAvgBtnClick)
  self:AddButtonClickListener(self._btnList, self.EventOnCollectionBtnClick)
  self:AddButtonClickListener(self._btnStage1, self.EventOnStage1StartBattleClick)
  self:AddButtonClickListener(self._btnStage2, self.EventOnStage2StartBattleClick)

  self:_PlayEnterAnim()
  self:_PlayLoopAnim()
  self:_RefreshContent()
end

function ActFun5MainDlg:_InitFromGameData(aprilFoolId)
  self.m_isStage1Tried, self.m_isStage2Tried = false, false
  self.m_isStage1Completed, self.m_isStage2Completed = false, false
  self.m_stage2Score = -1
  self.m_stage2CompleteScore = -1
  self.m_superScore = DEFAULT_SUPER_SCORE
  
  local act5FunData = CS.Torappu.ActivityDB.data.actFunData.act5FunData
  if act5FunData ~= nil then
    local act5FunConstData = act5FunData.constData
    if act5FunConstData ~= nil then
      self.m_stage2CompleteScore = act5FunConstData.minFundDrop
      self.m_superScore = act5FunConstData.maxFund
    end
  end

  local playerAprilFool = CS.Torappu.PlayerData.instance.data.playerAprilFool
  if playerAprilFool ~= nil then
    local actFun5data = playerAprilFool.actFun5
    if actFun5data ~= nil then
      local actFun5dataStages = actFun5data.stageState
      if actFun5dataStages ~= nil then
        self.m_isStage1Tried, self.m_isStage1Completed = self:_GetStageStatus(actFun5dataStages, self._stageId1)
        self.m_isStage2Tried, self.m_isStage2Completed = self:_GetStageStatus(actFun5dataStages, self._stageId2)
        self.m_stage2Score = actFun5data.highScore
      end
    end
  end
end

function ActFun5MainDlg:_GetStageStatus(dict, stageId)
  local isStageTried = false
  local isStageCompleted = false
  local ok, stageState = dict:TryGetValue(stageId);
  if ok and stageState ~= nil then
    isStageTried = stageState > 1
    isStageCompleted = stageState > 2
  end
  return isStageTried, isStageCompleted
end

function ActFun5MainDlg:_RefreshContent()
  local newRecord = self:_CheckNewRecord()
  local stage2CompleteTextFormat = luaUtils.GetStringRes("ACTFUN_STAGE_BET_COMPLETE_SCORE")
  local stage2CompleteText = CS.Torappu.Lua.Util.Format(stage2CompleteTextFormat, self.m_stage2CompleteScore)
  local isNormalScore = self.m_stage2Score < self.m_superScore
  SetGameObjectActive(self._panelUnlock, self.m_isStage1Completed)
  SetGameObjectActive(self._panelStage1New, not self.m_isStage1Tried)
  SetGameObjectActive(self._panelStage2New, not self.m_isStage2Tried)
  SetGameObjectActive(self._panelScore, self.m_isStage1Completed)
  SetGameObjectActive(self._panelScore1Reward, not self.m_isStage1Completed)
  SetGameObjectActive(self._panelScore1Complete, self.m_isStage1Completed)
  SetGameObjectActive(self._panelScore2Reward, not self.m_isStage2Completed)
  SetGameObjectActive(self._panelScore2Complete, self.m_isStage2Completed)
  SetGameObjectActive(self._panelNewRecord, newRecord)
  SetGameObjectActive(self._panelNormalScore, isNormalScore)
  SetGameObjectActive(self._panelSuperScore, not isNormalScore)
  self._textStage2Complete.text = stage2CompleteText
  if isNormalScore then
    self._textScore.text = self.m_stage2Score
  end
  self:_ConsumeNewRecord()
end

function ActFun5MainDlg:_InitBGM()
  local config = CS.Torappu.UI.UIMusicManager.ChunkConfig()
  config.signal = CS.Torappu.Audio.Consts.ACTIVITY_LOADED
  config.subSignal = self._subsignal
  CS.Torappu.UI.UIMusicManager.ModifyMusicChunk(self.m_parent:GetInstanceID(), config) 
  CS.Torappu.UI.UIMusicManager.SyncPlayingMusic()
  if self.m_isStage1Completed then
    CS.Torappu.TorappuAudio.PlayUI(AudioConsts.ACT5FUN_ENTERPRO);
  else
    CS.Torappu.TorappuAudio.PlayUI(AudioConsts.ACT5FUN_ENTER);
  end
end

function ActFun5MainDlg:_PlayEnterAnim()
  self._animWrapper:InitIfNot()
  self._animWrapper:SampleClipAtBegin(ANIM_ENTER)
  local tween = self._animWrapper:PlayWithTween(ANIM_ENTER)
  tween:SetEase(CS.DG.Tweening.Ease.Linear)
end

function ActFun5MainDlg:_PlayLoopAnim()
  self._animWrapper:InitIfNot()
  self._animWrapper:SampleClipAtBegin(ANIM_LOOP)
  self._animWrapperBkg:InitIfNot()
  self._animWrapperBkg:SampleClipAtBegin(ANIM_LOOP_BKG)
  local tween = self._animWrapper:PlayWithTween(ANIM_LOOP)
  local loopTween = self._animWrapperBkg:PlayWithTween(ANIM_LOOP_BKG)
  tween:SetEase(CS.DG.Tweening.Ease.Linear)
  tween:SetLoops(-1)
  loopTween:SetEase(CS.DG.Tweening.Ease.Linear)
  loopTween:SetLoops(-1)
end

function ActFun5MainDlg:DoTrackNewRecord()
  CS.Torappu.LocalTrackStore.instance:DoTrackTrigger(RECORD_TRACK_TYPE, KEY_TRACK_NEW_RECORD)
end

function ActFun5MainDlg:_CheckNewRecord()
  return CS.Torappu.LocalTrackStore.instance:CheckTrack(RECORD_TRACK_TYPE, KEY_TRACK_NEW_RECORD)
end

function ActFun5MainDlg:_ConsumeNewRecord()
  CS.Torappu.LocalTrackStore.instance:ConsumeTrack(RECORD_TRACK_TYPE, KEY_TRACK_NEW_RECORD)
end

function ActFun5MainDlg:EventOnAvgBtnClick()
  CS.Torappu.Lua.LuaActivityEntry.StartStoryWithSyncMusic(self._avgStoryId)
end

function ActFun5MainDlg:EventOnCollectionBtnClick()
  local parent = self.m_parent
  parent:SetRecentPlayedAct(ActFun5MainDlg.DLG_NAME)
  parent:GetGroup():SwitchChildDlg(ActFunCollectionDlg)
end

function ActFun5MainDlg:EventOnStage1StartBattleClick()
  ActFun5MainDlg:StartAct5FunBattle(self._aprilFoolId, self._stageId1)
end

function ActFun5MainDlg:EventOnStage2StartBattleClick()
  if not self.m_isStage1Completed then
    return
  end
  ActFun5MainDlg:StartAct5FunBattle(self._aprilFoolId, self._stageId2)
end

function ActFun5MainDlg:StartAct5FunBattle(actId, stageId)
  local startServiceConfig = CS.Torappu.Activity.Act5fun.Act5FunBattleStartConfig(stageId)
  local finishServiceConfig = CS.Torappu.Activity.Act5fun.Act5FunBattleFinishServerConfig(
      CS.Torappu.Activity.Act5fun.Act5FunService.FUN_BATTLE_FINISH)
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
  bundle:SetString(ActFunMainDlgGroup.KEY_INITDLG, ActFun5MainDlg.DLG_NAME)
  actMeta.meta = bundle
  
  local gameModeMeta = {
    isDeterministic = false,
    modeType = CS.Torappu.Battle.GameModeMeta.GameModeType.ACT_5_FUN
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