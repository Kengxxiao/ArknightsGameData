local luaUtils = CS.Torappu.Lua.Util;






































Act6FunBattleFinishDlg = DlgMgr.DefineDialog("Act6FunBattleFinishDlg", "Activity/ActFun/Actfun6/BattleFinish/actfun6_battle_finish", DlgBase)
local Act6funBattleFinishViewModel = require("Feature/Operation/ActFun/Act6fun/BattleFinish/Act6funBattleFinishViewModel")
local Act6funBattleFinishStarItemView = require("Feature/Operation/ActFun/Act6fun/BattleFinish/Act6funBattleFinishStarItemView")
local Act6funBattleFinishAchieveItemView = require("Feature/Operation/ActFun/Act6fun/BattleFinish/Act6funBattleFinishAchieveItemView")
local ANIM_KEY_SUC_IN = "act6fun_settlement_success";
local ANIM_KEY_FAIL_IN = "act6fun_settlement_fail";

local function _SetActive(gameObj, isActive)
  luaUtils.SetActiveIfNecessary(gameObj, isActive);
end


function Act6FunBattleFinishDlg:OnInit()
  self.m_isAnimEnd = false;
  self.m_isSuc = false;
  self.m_animAnim = '';
  self.m_animDur = 0.0;
  self.m_viewModel = Act6funBattleFinishViewModel.new();
  self.m_viewModel:InitData();

  self.m_isSuc = self.m_viewModel.isSuc;
  if self.m_isSuc then
    self.m_animAnim = ANIM_KEY_SUC_IN;
    self.m_animDur = self._sucEnterAnimDuration;
  else
    self.m_animAnim = ANIM_KEY_FAIL_IN;
    self.m_animDur = self._failEnterAnimDuration;
  end
  self._animWrapper:InitIfNot();
  self._animWrapper:SampleClipAtBegin(self.m_animAnim);

  self:AddButtonClickListener(self._btnClose, self.EventOnExitClick);
  self:_InitBGM();
  self:_OnRenderPanel();
end


function Act6FunBattleFinishDlg:OnClose()
end


function Act6FunBattleFinishDlg:ShowEnterEffect()
  self:_PlayEnterAnim();
end

function Act6FunBattleFinishDlg:_OnRenderPanel()
  self:AddButtonClickListener(self._btnExit, self.EventOnExitClick);
  local charPicId = self.m_viewModel.previewCharPicId;
  local hubCharImgPath = CS.Torappu.ResourceUrls.GetAct6funCharBigPicHubPath(charPicId);
  local charSprite = self:LoadSpriteFromAutoPackHub(hubCharImgPath, charPicId);
  local maxArchiveFormat = CS.Torappu.I18N.StringMap.Get("APRIL_FOOL_FUN_6_BATTLE_FINISH_ARCHIEVEMENT_TOTAL_FORMAT");
  local maxArchiveStr = luaUtils.Format(maxArchiveFormat, self.m_viewModel.achievementMaxCount);
  if self.m_isSuc then
    self:_OnRenderSucView(charSprite, maxArchiveStr);
  else
    self:_OnRenderFailView(charSprite, maxArchiveStr);
  end
end

function Act6FunBattleFinishDlg:_OnRenderSucView(charSprite, maxArchiveStr)
  CS.Torappu.TorappuAudio.PlayUI(CS.Torappu.Audio.Consts.ACT6FUN_WINSETTLEMENT);
  self._imgSucChar.sprite = charSprite;
  self._txtSucCoinCount.text = tostring(self.m_viewModel.curStageGetCoinCnt);
  self._txtSucTime.text = CS.Torappu.FormatUtil.ParseTimemmSS(self.m_viewModel.passTime);
  self._txtSucStageName.text = self.m_viewModel.name;
  self._txtSucStageCode.text = self.m_viewModel.code;
  self._txtSucCurAchieveCnt.text = tostring(self.m_viewModel.curAchivePoint);
  self._txtSucAchieveMaxCnt.text = maxArchiveStr;
  _SetActive(self._objSucNewRecord, self.m_viewModel.isNewRecord);
  local archieveItemGOs = {self._sucAchieveItem1, self._sucAchieveItem2, self._sucAchieveItem3};
  self:_OnRenderArchiveListPart(archieveItemGOs);
  local starItemGOs = {self._sucStarItem1, self._sucStarItem2, self._sucStarItem3};
  self:_OnRenderStarsPart(starItemGOs);
end

function Act6FunBattleFinishDlg:_OnRenderFailView(charSprite, maxArchiveStr)
  CS.Torappu.TorappuAudio.PlayUI(CS.Torappu.Audio.Consts.ACT6FUN_LOSESETTLEMENT);
  self._imgFailChar.sprite = charSprite;
  self._txtFailCoinCount.text = tostring(self.m_viewModel.curStageGetCoinCnt);
  self._txtFailTime.text = CS.Torappu.I18N.StringMap.Get("APRIL_FOOL_FUN_6_STAGE_HAS_NO_PASS_TIME_FORMAT");
  self._txtFailStageName.text = self.m_viewModel.name;
  self._txtFailStageName.text = self.m_viewModel.name;
  self._txtFailStageCode.text = self.m_viewModel.code;
  self._txtFailCurAchieveCnt.text = tostring(self.m_viewModel.curAchivePoint);
  self._txtFailAchieveMaxCnt.text = maxArchiveStr;
  local archieveItemGOs = {self._failAchieveItem1, self._failAchieveItem2, self._failAchieveItem3};
  self:_OnRenderArchiveListPart(archieveItemGOs);
  local starItemGOs = {self._failStarItem1, self._failStarItem2, self._failStarItem3};
  self:_OnRenderStarsPart(starItemGOs);
end

function Act6FunBattleFinishDlg:_OnRenderArchiveListPart(archieveItemGOs)
  local archieveInfoCount = #self.m_viewModel.achieveItemViewModelList;
  for idx, prefab in ipairs(archieveItemGOs) do
    local archieveItem = self:CreateWidgetByGO(Act6funBattleFinishAchieveItemView, prefab);
    if idx <= archieveInfoCount then
      _SetActive(prefab.gameObject, true)
      local archieveItemData = self.m_viewModel.achieveItemViewModelList[idx]
      archieveItem:Render(archieveItemData);
    else
      _SetActive(prefab.gameObject, false)
    end
  end
end

function Act6FunBattleFinishDlg:_OnRenderStarsPart(starItemGOs)
  local starMaxCount = self.m_viewModel.curStageStarMaxCount;
  for idx, prefab in ipairs(starItemGOs) do
    local starItem = self:CreateWidgetByGO(Act6funBattleFinishStarItemView, prefab);
    if idx <= starMaxCount then
      _SetActive(prefab.gameObject, true)
      local hasGet = idx <= self.m_viewModel.curStageGetStarCount;
      starItem:Render(hasGet);
    else
      _SetActive(prefab.gameObject, false)
    end
  end
end

function Act6FunBattleFinishDlg:_PlayEnterAnim()
  local enterTween = self._animWrapper:PlayWithTween(self.m_animAnim);
  enterTween:SetEase(CS.DG.Tweening.Ease.Linear);
  self:Delay(tonumber(self.m_animDur), function()
    self.m_isAnimEnd = true
  end)
end

function Act6FunBattleFinishDlg:_InitBGM()
  local config = CS.Torappu.UI.UIMusicManager.ChunkConfig();
  config.signal = CS.Torappu.Audio.Consts.ACTIVITY_LOADED;
  config.subSignal = self._subsignal;
  CS.Torappu.UI.UIMusicManager.ModifyMusicChunk(self.m_root:GetInstanceID(), config); 
  CS.Torappu.UI.UIMusicManager.SyncPlayingMusic();
end

function Act6FunBattleFinishDlg:EventOnExitClick()
  CS.Torappu.UI.BattleFinish.BattleFinishSceneManager.JumpToAct6fun();
end