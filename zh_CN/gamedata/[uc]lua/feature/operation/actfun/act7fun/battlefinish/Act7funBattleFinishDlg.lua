local luaUtils = CS.Torappu.Lua.Util;
















Act7FunBattleFinishDlg = DlgMgr.DefineDialog("Act7FunBattleFinishDlg", "Activity/ActFun/Actfun7/BattleFinish/actfun7_battle_finish", DlgBase)
local Act7FunBattleFinishViewModel = require("Feature/Operation/ActFun/Act7fun/BattleFinish/Act7funBattleFinishViewModel")
local Act7FunBattleFinishNewsView = require("Feature/Operation/ActFun/Act7fun/BattleFinish/Act7FunBattleFinishNewsView")

local ANIM_KEY_NORM_SUC_IN = "act7fun_battle_finish_normal_win";
local ANIM_KEY_TOTAL_SUC_IN = "act7fun_battle_finish_total_win";
local ANIM_KEY_TOTAL_SUC_END = "act7fun_battle_finish_total_win_end";
local ANIM_KEY_FAIL_IN = "act7fun_battle_finish_fail";

local ANIM_STATE = {
  FAIL = 0,
  NORM_SUC = 1,
  TOTAL_SUC_STAGE_ONE = 2,
  EGG = 3,
  TOTAL_SUC_STAGE_TWO = 4,
  END = 5;
}

function Act7FunBattleFinishDlg:OnInit()
  self:_InitGameData();

  
  self.m_stateHandlers = {
    [ANIM_STATE.FAIL] = self._HandleFailState,
    [ANIM_STATE.NORM_SUC] = self._HandleNormSucState,
    [ANIM_STATE.TOTAL_SUC_STAGE_ONE] = self._HandleTotalSucStageOneState,
    [ANIM_STATE.EGG] = self._HandleEggState,
    [ANIM_STATE.TOTAL_SUC_STAGE_TWO] = self._HandleTotalSucStageTwoState,
    [ANIM_STATE.END] = self._HandleEndState,
  }

  self:AddButtonClickListener(self._btnInteractable, self._HandleStateChange);
  self.m_newsView = self:CreateWidgetByGO(Act7FunBattleFinishNewsView, self._panelNews);
  self.m_newsView:OnInit(self, self.m_viewModel);

  self:_InitBGM();
  self:_OnRenderPanel();
end

function Act7FunBattleFinishDlg:OnClose()
end

function Act7FunBattleFinishDlg:ShowEnterEffect()
  self:_HandleStateChange();
end

function Act7FunBattleFinishDlg:_InitGameData()
  self.m_viewModel = self:CreateViewModel(Act7FunBattleFinishViewModel)
  self.m_viewModel:InitData();
  self:_InitState();
end

function Act7FunBattleFinishDlg:_InitState()
  if self.m_viewModel.isFailed then 
    self.m_currState = ANIM_STATE.FAIL;
  elseif self.m_viewModel.isNormalSuc then
    self.m_currState = ANIM_STATE.NORM_SUC;
  else
    self.m_currState = ANIM_STATE.TOTAL_SUC_STAGE_ONE;
  end
end

function Act7FunBattleFinishDlg:_InitBGM()
  local config = CS.Torappu.UI.UIMusicManager.ChunkConfig();
  config.signal = CS.Torappu.Audio.Consts.ACTIVITY_LOADED;
  config.subSignal = self._subsignal;
  CS.Torappu.UI.UIMusicManager.ModifyMusicChunk(self.m_root:GetInstanceID(), config);
  CS.Torappu.UI.UIMusicManager.SyncPlayingMusic();
end

function Act7FunBattleFinishDlg:_OnRenderPanel()
  self._txtTrapCnt.text = self.m_viewModel.trapCnt;
  self._txtCardUsedCnt.text = self.m_viewModel.cardUsedCnt;
  self._txtDefeatedCnt.text = self.m_viewModel.defeatedCnt;

  self._spineDisplayPanel:Render(self.m_viewModel.spineGroupId, self.m_viewModel.isFailed);
end

function Act7FunBattleFinishDlg:_PlayAnim(animName, onComplete)
  if self.m_tween ~= nil and self.m_tween:IsPlaying() then
    self.m_tween:Kill();
    self.m_tween = nil;
  end
  self._animWrapper:InitIfNot();
  self._animWrapper:SampleClipAtBegin(animName);
  self.m_tween = self._animWrapper:PlayWithTween(animName):SetEase(CS.DG.Tweening.Ease.Linear):SetAutoKill(true);
  self.m_tween:OnComplete(function()
    if onComplete then
      onComplete(self)
    end
  end)
end

function Act7FunBattleFinishDlg:_HandleStateChange()
  SetGameObjectActive(self._btnInteractable.gameObject, false);
  local handler = self.m_stateHandlers[self.m_currState];
  if handler ~= nil then
    handler(self);
  else
    CS.Torappu.UI.BattleFinish.BattleFinishSceneManager.RouteToHomeSceneDefault();
  end
end

function Act7FunBattleFinishDlg:_HandleFailState()
  CS.Torappu.TorappuAudio.PlayUI(CS.Torappu.Audio.Consts.ACT7FUN_LOSESETTLEMENT);
  self:_PlayAnim(ANIM_KEY_FAIL_IN, function(_)
    self.m_currState = ANIM_STATE.END;
    SetGameObjectActive(self._btnInteractable.gameObject, true);
  end)
end

function Act7FunBattleFinishDlg:_HandleNormSucState()
  
  CS.Torappu.TorappuAudio.PlayUI(CS.Torappu.Audio.Consts.ACT7FUN_WINSETTLEMENT);
  self:_PlayAnim(ANIM_KEY_NORM_SUC_IN, function(_)
    if self.m_viewModel.hasEasterEgg then
      self.m_currState = ANIM_STATE.EGG
    else
      self:_OnEggAnimEnd();
    end
    SetGameObjectActive(self._btnInteractable.gameObject, true);
  end)
end

function Act7FunBattleFinishDlg:_HandleTotalSucStageOneState()
  
  CS.Torappu.TorappuAudio.PlayUI(CS.Torappu.Audio.Consts.ACT7FUN_WINSETTLEMENT);
  self:_PlayAnim(ANIM_KEY_TOTAL_SUC_IN, function(_)
    if self.m_viewModel.hasEasterEgg then
      self.m_currState = ANIM_STATE.EGG;
    else
      self:_OnEggAnimEnd();
    end
    SetGameObjectActive(self._btnInteractable.gameObject, true);
  end)
end

function Act7FunBattleFinishDlg:_HandleEggState()
  CS.Torappu.TorappuAudio.PlayUI(CS.Torappu.Audio.Consts.ACT7FUN_NEWS);
  self.m_newsView:GenerateNewsSequence(function()
    self.m_tween = self.m_newsView:GetLoopSequence();
    self:_OnEggAnimEnd();
    SetGameObjectActive(self._btnInteractable.gameObject, true);
  end);
end

function Act7FunBattleFinishDlg:_OnEggAnimEnd()
  if not self.m_viewModel.isFailed and not self.m_viewModel.isNormalSuc then
    self.m_currState = ANIM_STATE.TOTAL_SUC_STAGE_TWO;
  else
    self.m_currState = ANIM_STATE.END;
  end
end

function Act7FunBattleFinishDlg:_HandleTotalSucStageTwoState()
  CS.Torappu.TorappuAudio.PlayUI(CS.Torappu.Audio.Consts.ACT7FUN_BIGWIN);
  self:_PlayAnim(ANIM_KEY_TOTAL_SUC_END);
  self.m_tween:OnComplete(function()
    self.m_currState = ANIM_STATE.END;
    self:_HandleStateChange();
    SetGameObjectActive(self._btnInteractable.gameObject, true);
  end)
end

function Act7FunBattleFinishDlg:_HandleEndState()
  if self.m_viewModel.isFailed then
    CS.Torappu.UI.BattleFinish.BattleFinishSceneManager.RouteToHomeSceneDefault(); 
  else
    luaUtils.PlayAvgBackToHomeScene(self.m_viewModel.stageId);
  end
end

return Act7FunBattleFinishDlg