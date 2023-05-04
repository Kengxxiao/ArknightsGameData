local luaUtils = CS.Torappu.Lua.Util;































ActFun3BattleFinishDlg = DlgMgr.DefineDialog("ActFun3BattleFinishDlg", "Activity/ActFun/Actfun3/BattleFinish/actfun3_battle_finish", DlgBase);
local ActFun3BattleFinishViewModel = require("Feature/Operation/ActFun/ActFun3BattleFinishViewModel");

local ANIM_KEY_WIN = "anim_win"
local ANIM_KEY_LOSE = "anim_lose"
local ANIM_KEY_RANK = "anim_rank"

local SOUND_SIGNAL_WIN = "ON_ACT3FUN_WIN";
local SOUND_SIGNAL_EXWIN = "ON_ACT3FUN_EXWIN";
local SOUND_SIGNAL_FAIL = "ON_ACT3FUN_FAIL";
local SOUND_SIGNAL_EXFAIL = "ON_ACT3FUN_EXFAIL";
local DELAY_BGM = 4
local MAX_RANK_COUNT = 20

function ActFun3BattleFinishDlg:OnInit()
  self.m_viewModel = ActFun3BattleFinishViewModel.new();
  self.m_viewModel:InitData();
  self:OnRenderPanel();
end


function ActFun3BattleFinishDlg:OnClose()
  self:_ClearBGM()
end

function ActFun3BattleFinishDlg:OnRenderPanel()
  local isWin = self.m_viewModel.m_isWin
  local isBoss = self.m_viewModel.m_stageId == self._bossStageId
  SetGameObjectActive(self._panelResult.gameObject, true)
  SetGameObjectActive(self._panelRanking.gameObject, false)
  SetGameObjectActive(self._panelWinBoss.gameObject,isBoss)
  SetGameObjectActive(self._panelLoseBoss.gameObject,isBoss)
  SetGameObjectActive(self._panelWin.gameObject,self.m_viewModel.m_isWin)
  SetGameObjectActive(self._panelLose.gameObject,not self.m_viewModel.m_isWin)
  self:_PlaySoundAndBGM()
  if isWin then
    self:_PlayWinAnim()
  else
    self:_PlayLoseAnim()
  end
  local titleConst = self._textRankTitle.text
  local titleString = string.format(self.m_viewModel.m_stageCode .. titleConst)
  self._textRankTitle.text = titleString
  self._textEnemyCnt.text = self.m_viewModel.m_enemyCnt
  self._textEnemyScore.text = self.m_viewModel.m_enemyScore
  self._textBossCnt.text = self.m_viewModel.m_bossCnt
  self._textBossScore.text = self.m_viewModel.m_boosScore
  local sec = tonumber(self.m_viewModel.m_time)
  local timeStamp = ""
  if sec ~= nil then
    local days = math.floor(sec / 86400)
    sec = sec - days * 86400
    local hours = math.floor(sec / 3600 )
    sec = sec - hours * 3600
    local minutes = math.floor(sec / 60) 
    sec = sec - minutes * 60
    timeStamp = string.format("%02d:%02d", minutes, sec)
  end
  self._textTime.text = timeStamp
  self._textTimeScore.text = self.m_viewModel.m_timeScore 
  self:_TweenTotalScore(self.m_viewModel.m_score)

  if isWin then
    self:AddButtonClickListener(self._btnNext, self.EventOnRankBtnClick)
  else
    self:AddButtonClickListener(self._btnNext, self.EventOnExitClick)
  end
end

function ActFun3BattleFinishDlg:_TweenTotalScore(targetScore)
  local targetText = self._textScoreTotal
  TweenModel:Play({
    setFunc = function(lerp)
      local curScore = math.floor(targetScore * lerp)
      if targetText ~= nil then
        targetText.text = ""..curScore
      end
    end,
    duration = 1,
    delay = 0.5
  })
end

function ActFun3BattleFinishDlg:_Render(stageId, scoreRank)
  self:_GenScoreDataList(stageId, scoreRank)
  self:_RenderRankList()
end

function ActFun3BattleFinishDlg:_RenderRankList()
  local currentIdx = -1
    for idx = 1, #self.m_rankScore do
      local scoreData = self.m_rankScore[idx]
      if scoreData.playerScore == self.m_viewModel.m_score and currentIdx < 0 then
        currentIdx = idx
      end
      if idx <= MAX_RANK_COUNT then
        local item = nil
          if currentIdx > 0 and currentIdx == idx then
            item = self:CreateWidgetByPrefab(ActFun3BattleRankItem, self._selectedItemPrefab, self._itemContainer)
          else
            item = self:CreateWidgetByPrefab(ActFun3BattleRankItem, self._itemPrefab, self._itemContainer)
          end
        item:Render(idx, scoreData.playerName, scoreData.playerScore)
      end
    end
  
  local currentRank
  if currentIdx < 10 then
    currentRank = string.format("0%s", currentIdx)
  elseif currentIdx <= 20 then
    currentRank = string.format("%s", currentIdx)
  else
    currentRank = "N/A"
  end
  self._textRankNum.text = currentRank
  self._textRankName.text = self.m_viewModel.m_playerName
  self._textRankScore.text = self.m_viewModel.m_score

  if currentIdx <= 20 then
    self:_HandleScrollTo(currentIdx)
  end
end

function ActFun3BattleFinishDlg:_GenScoreDataList(stageId, scoreRank)
  local suc, itemsInCfg = CS.Torappu.ActivityDB.data.actFunData.scoreDict:TryGetValue(stageId);
  if not suc then
    return;
  end
  self.m_rankScore = {}
  if scoreRank ~= nil and scoreRank.Length > 0 then
    for idx = 0, scoreRank.Length - 1 do
      local scoreData = CS.Torappu.AprilFoolScoreData()
      local score = scoreRank[idx]
      scoreData.stageId = stageId
      scoreData.sortId = 0
      scoreData.playerName = self.m_viewModel.m_playerName
      scoreData.playerScore = score
      table.insert(self.m_rankScore, scoreData)
    end
  end

  for idx = 0, itemsInCfg.Count - 1 do
    local cfgData = itemsInCfg[idx]
    if cfgData ~= nil then
      table.insert(self.m_rankScore, cfgData)
    end
  end

  table.sort(self.m_rankScore, function(a, b)
    return a.playerScore > b.playerScore
  end)

  for idx = 1, #table do
    local info = table[idx];
  end
end

function ActFun3BattleFinishDlg:_PlayWinAnim()
  self._animWrapper:InitIfNot()
  self._animWrapper:SampleClipAtBegin(ANIM_KEY_WIN)
  self._animWrapper:PlayWithTween(ANIM_KEY_WIN)
end

function ActFun3BattleFinishDlg:_PlayLoseAnim()
  self._animWrapper:InitIfNot()
  self._animWrapper:SampleClipAtBegin(ANIM_KEY_LOSE)
  self._animWrapper:PlayWithTween(ANIM_KEY_LOSE)
end

function ActFun3BattleFinishDlg:_PlayRankAnim()
  self._animWrapper:InitIfNot()
  self._animWrapper:SampleClipAtBegin(ANIM_KEY_RANK)
  self._animWrapper:PlayWithTween(ANIM_KEY_RANK)
end

function ActFun3BattleFinishDlg:_PlaySoundAndBGM()
  self:_PlaySound()
  self:Delay(DELAY_BGM, self._InitBGM)
end

function ActFun3BattleFinishDlg:_PlaySound()
  local isWin = self.m_viewModel.m_isWin
  local isBoss = self.m_viewModel.m_stageId == self._bossStageId
  local signal = ""
  if isWin then
    if isBoss then
      signal = SOUND_SIGNAL_EXWIN
    else
      signal = SOUND_SIGNAL_WIN
    end
  else
    if isBoss then
      signal = SOUND_SIGNAL_EXFAIL
    else
      signal = SOUND_SIGNAL_FAIL
    end
  end
  CS.Torappu.TorappuAudio.PlayBattle(signal);
end

function ActFun3BattleFinishDlg:_InitBGM()
  local config = CS.Torappu.UI.UIMusicManager.ChunkConfig()
  config.signal = CS.Torappu.Audio.Consts.ACTIVITY_LOADED
  config.subSignal = self._subsignal
  CS.Torappu.UI.UIMusicManager.ModifyMusicChunk(self:_GetInstanceID(), config)
  CS.Torappu.UI.UIMusicManager.SyncPlayingMusic()
end

function ActFun3BattleFinishDlg:_ClearBGM()
  CS.Torappu.UI.UIMusicManager.RemoveMusicChunk(self:_GetInstanceID())
  CS.Torappu.UI.UIMusicManager.SyncPlayingMusic()
end

function ActFun3BattleFinishDlg:_GetInstanceID()
  return self:GetLuaLayout():GetInstanceID() 
end

function ActFun3BattleFinishDlg:_HandleScrollTo(idx)
  local target = math.max(0, 1 - self:_CalculateItemScrollPrg(idx, MAX_RANK_COUNT))
  self._scrollView:DoScrollVertTo(target, 0.3)
end



function ActFun3BattleFinishDlg:_CalculateItemScrollPrg(itemIdx, totalCount)
  local realIdx = itemIdx - 1
  local realMaxIdx = totalCount - 1
  if realMaxIdx <= 0 then
    return 1
  end
  if realIdx < 0 then
    return 1
  end
  local to = realIdx / realMaxIdx
  if to >= 1 then
    return 1
  else
    return to
  end
end

function ActFun3BattleFinishDlg:EventOnRankBtnClick()
  SetGameObjectActive(self._panelResult.gameObject, false)
  SetGameObjectActive(self._panelRanking.gameObject, true)
  self:_Render(self.m_viewModel.m_stageId, self.m_viewModel.m_rank)
  self:_PlayRankAnim()
  self:AddButtonClickListener(self._btnNext, self.EventOnRankClose)
end

function ActFun3BattleFinishDlg:EventOnRankClose()
  self:EventOnExitClick()
end

function ActFun3BattleFinishDlg:EventOnExitClick()
  CS.Torappu.UI.BattleFinish.BattleFinishSceneManager.RouteToHomeSceneDefault()
end
