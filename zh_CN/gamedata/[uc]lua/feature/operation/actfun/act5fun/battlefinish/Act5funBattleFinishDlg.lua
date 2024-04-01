local luaUtils = CS.Torappu.Lua.Util;


































Act5FunBattleFinishDlg = DlgMgr.DefineDialog("Act5FunBattleFinishDlg", "Activity/ActFun/Actfun5/BattleFinish/actfun5_battle_finish", DlgBase)
local Act5funBattleFinishViewModel = require("Feature/Operation/ActFun/Act5fun/BattleFinish/Act5funBattleFinishViewModel")
local Act5funBattleFinishUserItem = require("Feature/Operation/ActFun/Act5fun/BattleFinish/Act5funBattleFinishUserItem")
local ANIM_KEY_IN = "fool_battle_finish_entry"
local RECORD_TRACK_TYPE = "ACT5FUN_NEW_RECORD"
local KEY_TRACK_NEW_RECORD = "key_track_new_record"
local MASK_FADE_TIME = 0.23


function Act5FunBattleFinishDlg:OnInit()
  self.m_isAnimEnd = false
  self.m_needNewRecordTrack = false
  self.m_viewModel = Act5funBattleFinishViewModel.new()
  self.m_viewModel:InitData()

  if self.m_viewModel.needSkip then
    self:EventOnExitClick()
  else
    self:_InitBGM()
    self:_OnRenderPanel()
    self._animWrapper:InitIfNot()
    self._animWrapper:SampleClipAtBegin(ANIM_KEY_IN)
  end
end

function Act5FunBattleFinishDlg:_InitBGM()
  local config = CS.Torappu.UI.UIMusicManager.ChunkConfig()
  config.signal = CS.Torappu.Audio.Consts.ACTIVITY_LOADED
  config.subSignal = self._subsignal
  CS.Torappu.UI.UIMusicManager.ModifyMusicChunk(self.m_root:GetInstanceID(), config) 
  CS.Torappu.UI.UIMusicManager.SyncPlayingMusic()
end


function Act5FunBattleFinishDlg:OnClose()
end


function Act5FunBattleFinishDlg:ShowEnterEffect()
  self:_PlayEnterAnim()
  self:_PlayEnterAudio()
end


function Act5FunBattleFinishDlg:IsEnterEffectEnd()
  return self.m_isAnimEnd
end

function Act5FunBattleFinishDlg:_PlayEnterAnim()
  local enterTween = self._animWrapper:PlayWithTween(ANIM_KEY_IN)
  enterTween:SetEase(CS.DG.Tweening.Ease.Linear)
  self:Delay(tonumber(self._enterAnimDuration), function()
    self.m_isAnimEnd = true
  end)

  self:_TweeenCoinCount(self.m_viewModel.coinCount)
end

function Act5FunBattleFinishDlg:_PlayEnterAudio()
  local isSuperStat = self.m_viewModel.coinCount >= self.m_viewModel.thresholdCount
  if isSuperStat then
    CS.Torappu.TorappuAudio.PlayUI(AudioConsts.ACT5FUN_MONEYEXPLODE);
  else 
    if self.m_viewModel.isNewRecord then
      CS.Torappu.TorappuAudio.PlayUI(AudioConsts.ACT5FUN_SHATTERRECORD);
    else
      CS.Torappu.TorappuAudio.PlayUI(AudioConsts.ACT5FUN_FUNDSETTLEMENT);
    end
  end
end

function Act5FunBattleFinishDlg:_OnRenderPanel()
  self:AddButtonClickListener(self._btnExit, self.EventOnExitClick)

  local bkg = CS.Torappu.Battle.BattleInOut.instance.output.bkg
  local bkgSprite = CS.Torappu.UI.BattleFinish.BattleFinishSceneManager.LoadBattleFinishBkg(bkg)
  self._imgFullScreen.image.sprite = bkgSprite
  self._imgFullScreen:UpdateSize()

  self._txtName.text = self.m_viewModel.name
  self._txtCoin.text = '0'
  self._txtCountWin.text = self.m_viewModel.winCount
  self._txtCountTotal.text = self.m_viewModel.totalCount
  local winningStreakStr = self.m_viewModel.winningStreakStr
  self._txtWinningStreak.text = winningStreakStr
  local isGuideMode = self.m_viewModel.guideStageId == self._guideStageId
  self.m_needNewRecordTrack = not isGuideMode and self.m_viewModel.isNewRecord
  SetGameObjectActive(self._panelGuideRecord, isGuideMode)
  SetGameObjectActive(self._panelNewRecord, self.m_needNewRecordTrack)
  SetGameObjectActive(self._panelWinningStreak, winningStreakStr ~= nil and winningStreakStr ~= '')
  SetGameObjectActive(self._panelNormalScore, true)
  SetGameObjectActive(self._panelSuperScore, false)
  self._maskBlack.alpha = 0

  self._txtWord.text = ''
  local textTweener = self._txtWord:DOText(self.m_viewModel.wordStr, tonumber(self._txtTweenDuration))
  textTweener:SetDelay(tonumber(self._txtTweenDelay))
  textTweener:SetAutoKill(true)
  textTweener:Play()

  local hubPath = CS.Torappu.ResourceUrls.GetAct5funUserHeadIconHubPath()
  local userItemGO = {self._userItem1, self._userItem2, self._userItem3, self._userItem4, self._userItem5}
  self.m_userItems = {}
  local userInfoCount = self.m_viewModel.userInfoCount
  for idx, prefab in ipairs(userItemGO) do
    local item = self:CreateWidgetByGO(Act5funBattleFinishUserItem, prefab)
    table.insert(self.m_userItems, item);
    if idx <= userInfoCount then
      SetGameObjectActive(prefab.gameObject, true)
      local userInfoData = self.m_viewModel.userInfoList[idx]
      item:Render(hubPath, userInfoData)
    else
      SetGameObjectActive(prefab.gameObject, false)
    end
    
  end
end

function Act5FunBattleFinishDlg:_TweeenCoinCount(count)
  local tweenCount = tonumber(count)
  local isSuperStatus = false
  local thresholdCount = self.m_viewModel.thresholdCount
  if tweenCount >= thresholdCount then 
    isSuperStatus = true
    tweenCount = thresholdCount - 1
  end

  local targetText = self._txtCoin
  TweenModel:Play({
    setFunc = function(lerp)
      local curCount = math.floor(tweenCount * lerp)
      if targetText ~= nil then
        targetText.text = ""..curCount
      end
    end,
    duration = tonumber(self._coinCountTweenDuration),
    onComplete = function()
      if isSuperStatus then
        SetGameObjectActive(self._panelNormalScore, false)
        SetGameObjectActive(self._panelSuperScore, true)
      else
        targetText.text = count
      end
    end
  })
end

function Act5FunBattleFinishDlg:DoTrackNewRecord()
  CS.Torappu.LocalTrackStore.instance:DoTrackTrigger(RECORD_TRACK_TYPE, KEY_TRACK_NEW_RECORD)
end

function Act5FunBattleFinishDlg:EventOnExitClick()
  if self.m_needNewRecordTrack then
    self:DoTrackNewRecord()
  end
  local isGuideMode = self.m_viewModel.guideStageId == self._guideStageId
  if isGuideMode and self.m_viewModel.isGettingReward then
    self._maskBlack:DOFade(1, MASK_FADE_TIME)
    luaUtils.PlayAvgBackToHomeScene(self._avgEndingKey)
  else
    CS.Torappu.UI.BattleFinish.BattleFinishSceneManager.RouteToHomeSceneDefault()
  end
end
