local luaUtils = CS.Torappu.Lua.Util;














































ActFun3MainDlg = DlgMgr.DefineDialog("ActFun3MainDlg", "Activity/ActFun/Actfun3/actfun3_dlg", DlgBase)

ActFun3MainDlg.DLG_NAME = "fun3"

ActFun3MainDlg.s_enterEffectMarkKey = ""

local ANIM_KEY_IN = "anim_actfun3_in"
local ANIM_KEY_FEEDBACK = "anim_actfun3_feedback"

local SATAGE1_NAME = "BF-1"
local SATAGE2_NAME = "BF-2"


function ActFun3MainDlg:OnInit()
  self:_InitFromGameData(self._aprilFoolId)
  self:_InitBGM()

  self:AddButtonClickListener(self._btnAvg, self.EventOnAvgBtnClick)
  self:AddButtonClickListener(self._btnList, self.EventOnCollectionBtnClick)
  self:AddButtonClickListener(self._btnNegative, self.EventOnNegativeBtnClick)
  self:AddButtonClickListener(self._btnStage1, self.EventOnStage1StartBattleClick)
  self:AddButtonClickListener(self._btnStage2, self.EventOnStage2StartBattleClick)
  self:AddButtonClickListener(self._btnStage3, self.EventOnStage3StartBattleClick)
  
  self:_RefreshContent()
end

function ActFun3MainDlg:_InitFromGameData(aprilFoolId)
  self.m_isStage1Completed, self.m_isStage2Completed, self.m_isStage3Completed = false, false, false
  self.m_stage1Score, self.m_stage2Score, self.m_stage3Score = -1, -1, -1

  local playerAprilFool = CS.Torappu.PlayerData.instance.data.playerAprilFool
  if playerAprilFool ~= nil then
    local aprilFool2022data = playerAprilFool.actFun3
    if aprilFool2022data ~= nil then
      local stageStatusDict = aprilFool2022data.stages
      if stageStatusDict ~= nil then
        self.m_isStage1Completed, self.m_stage1Score = self:_GetStageStatus(stageStatusDict, self._stageId1)
        self.m_isStage2Completed, self.m_stage2Score = self:_GetStageStatus(stageStatusDict, self._stageId2)
        self.m_isStage3Completed, self.m_stage3Score = self:_GetStageStatus(stageStatusDict, self._stageId3)
      end
    end
  end
end

function ActFun3MainDlg:_GetStageStatus(dict, stageId)
  local isStageCompleted = false
  local stageMaxScore = -1
  local success1, stageData = dict:TryGetValue(stageId);
  
  if success1 and stageData ~= nil and stageData.state.value__ > 1 then
    isStageCompleted = true
    if (stageData.scores ~= nil and stageData.scores.Count > 0) then
      local scores = stageData.scores
      for idx = 0,scores.Count-1 do
        if stageMaxScore < scores[idx] then
          stageMaxScore = scores[idx]
        end
      end
    end
  end
  return isStageCompleted, stageMaxScore
end

function ActFun3MainDlg:_InitBGM()
  local config = CS.Torappu.UI.UIMusicManager.ChunkConfig()
  config.signal = CS.Torappu.Audio.Consts.ACTIVITY_LOADED
  config.subSignal = self._subsignal
  CS.Torappu.UI.UIMusicManager.ModifyMusicChunk(self.m_parent:GetInstanceID(), config) 
  CS.Torappu.UI.UIMusicManager.SyncPlayingMusic()
end

function ActFun3MainDlg:_RefreshContent()
  SetGameObjectActive(self._imgStage2.gameObject, self.m_isStage1Completed);
  SetGameObjectActive(self._imgStage2Locked.gameObject, not self.m_isStage1Completed);
  SetGameObjectActive(self._imgStage3.gameObject, self.m_isStage2Completed);
  SetGameObjectActive(self._imgStage3Locked.gameObject, not self.m_isStage2Completed);
  SetGameObjectActive(self._textStage1Score.gameObject, self.m_stage1Score >= 0);
  SetGameObjectActive(self._textStage1Default.gameObject, self.m_stage1Score < 0);
  self._textStage1Score.text = self.m_stage1Score;
  SetGameObjectActive(self._textStage2Score.gameObject, self.m_stage2Score >= 0);
  SetGameObjectActive(self._textStage2Default.gameObject, self.m_stage2Score < 0);
  self._textStage2Score.text = self.m_stage2Score;
  SetGameObjectActive(self._textStage3Score.gameObject, self.m_stage3Score >= 0);
  SetGameObjectActive(self._textStage3Default.gameObject, self.m_stage3Score < 0);
  self._textStage3Score.text = self.m_stage3Score;
  SetGameObjectActive(self._panelReward1Got.gameObject, self.m_isStage2Completed);
  SetGameObjectActive(self._panelReward1NotGet.gameObject, not self.m_isStage2Completed);
  SetGameObjectActive(self._panelReward2Got.gameObject, self.m_isStage3Completed);
  SetGameObjectActive(self._panelReward2NotGet.gameObject, not self.m_isStage3Completed);
  if not self.m_isStage2Completed then
    self._imgReward1.color = CS.Torappu.ColorRes.TweenHtmlStringToColor(self._rewardDefaultColor)
  else
    self._imgReward1.color = CS.Torappu.ColorRes.TweenHtmlStringToColor(self._rewardGotColor)
  end
  if not self.m_isStage3Completed then
    self._imgReward2.color = CS.Torappu.ColorRes.TweenHtmlStringToColor(self._rewardDefaultColor)
  else
    self._imgReward2.color = CS.Torappu.ColorRes.TweenHtmlStringToColor(self._rewardGotColor)
  end

  self:_PlayEnterAnim()
end

function ActFun3MainDlg:_PlayEnterAnim()
  local key = CS.Torappu.Lua.Util.GetLoginInfoHash()
  if self:_CheckIfEnterEffectWatched(key) then
    return
  end
  ActFun3MainDlg.s_enterEffectMarkKey = key
  self._animWrapper:InitIfNot()
  self._animWrapper:SampleClipAtBegin(ANIM_KEY_IN)
  self._animWrapper:PlayWithTween(ANIM_KEY_IN)
end

function ActFun3MainDlg:_CheckIfEnterEffectWatched(key)
  
  if ActFun3MainDlg.s_enterEffectMarkKey == key then
    return true
  end
  return false
end

function ActFun3MainDlg:EventOnAvgBtnClick()
  CS.Torappu.Lua.LuaActivityEntry.StartStoryWithSyncMusic(self._avgStoryId)
end

function ActFun3MainDlg:EventOnCollectionBtnClick()
  local parent = self.m_parent
  parent:SetRecentPlayedAct(ActFun3MainDlg.DLG_NAME)
  parent:GetGroup():SwitchChildDlg(ActFunCollectionDlg)
end

function ActFun3MainDlg:EventOnNegativeBtnClick()
  self._animWrapper:InitIfNot()
  if (self._animWrapper:IsPlaying(ANIM_KEY_FEEDBACK)) then
    return
  end
  self._animWrapper:SampleClipAtBegin(ANIM_KEY_FEEDBACK)
  self._animWrapper:PlayWithTween(ANIM_KEY_FEEDBACK)
end

function ActFun3MainDlg:EventOnStage1StartBattleClick()
  ActFun3MainDlg:StartAct3FunBattle(self._aprilFoolId, self._stageId1)
end

function ActFun3MainDlg:EventOnStage2StartBattleClick()
  if not self.m_isStage1Completed then
    local toastText = CS.Torappu.Lua.Util.Format(luaUtils.GetStringRes("ACTFUN_STAGE_LOCKED_TOAST"), SATAGE1_NAME)
    luaUtils.TextToast(toastText)
    return
  end
  ActFun3MainDlg:StartAct3FunBattle(self._aprilFoolId, self._stageId2)
end

function ActFun3MainDlg:EventOnStage3StartBattleClick()
  if not self.m_isStage2Completed then
    local toastText = CS.Torappu.Lua.Util.Format(luaUtils.GetStringRes("ACTFUN_STAGE_LOCKED_TOAST"), SATAGE2_NAME)
    luaUtils.TextToast(toastText)
    return
  end
  ActFun3MainDlg:StartAct3FunBattle(self._aprilFoolId,self._stageId3)
end

function ActFun3MainDlg:StartAct3FunBattle(actId, stageId)
  local startServiceConfig = CS.Torappu.Activity.Act3fun.Act3FunBattleStartConfig(stageId)
  local finishServiceConfig = CS.Torappu.Activity.Act3fun.Act3BattleFinishServerConfig(
      CS.Torappu.Activity.Act3fun.Act3FunService.FUN_BATTLE_FINISH)
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
  bundle:SetString(ActFunMainDlgGroup.KEY_INITDLG, ActFun3MainDlg.DLG_NAME)
  actMeta.meta = bundle
  
  local gameModeMeta = {
    isDeterministic = false,
    modeType = CS.Torappu.Battle.GameModeMeta.GameModeType.DANMAKU
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
