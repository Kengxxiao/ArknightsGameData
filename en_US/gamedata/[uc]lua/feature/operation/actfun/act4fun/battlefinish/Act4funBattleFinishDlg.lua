local luaUtils = CS.Torappu.Lua.Util;















Act4FunBattleFinishDlg = DlgMgr.DefineDialog("Act4FunBattleFinishDlg", "Activity/ActFun/Actfun4/BattleFinish/act4fun_battle_finish", DlgBase);
local Act4funBattleFinishViewModel = require("Feature/Operation/ActFun/Act4fun/BattleFinish/Act4funBattleFinishViewModel");
local Act4funLivePhotoCard = require "Feature/Operation/ActFun/Act4fun/Photo/Act4funLivePhotoCard";


function Act4FunBattleFinishDlg:OnInit()
  self.m_viewModel = Act4funBattleFinishViewModel.new();
  self.m_viewModel:InitData();
  self:OnRenderPanel();
end


function Act4FunBattleFinishDlg:OnClose()
end

function Act4FunBattleFinishDlg:OnRenderPanel()
  self.m_judgeDialogHandle = self:CreateCustomComponent(CSJudgeDialogHandle);

  local bkg = CS.Torappu.Battle.BattleInOut.instance.output.bkg;
  local bkgSprite = CS.Torappu.UI.BattleFinish.BattleFinishSceneManager.LoadBattleFinishBkg(bkg);
  self._backImg.image.sprite = bkgSprite;
  self._backImg:UpdateSize();
  self._nickText.text = self.m_viewModel.nickText;
  self._detailText.text = self.m_viewModel.detailText;
  self._countText.text =  tostring(self.m_viewModel.totalCount);
  luaUtils.SetActiveIfNecessary(self._noDataPart, self.m_viewModel.totalCount == 0);
  luaUtils.SetActiveIfNecessary(self._unableBtn.gameObject, not self.m_viewModel.ableToLive);
  luaUtils.SetActiveIfNecessary(self._startBtn.gameObject, self.m_viewModel.ableToLive);
  luaUtils.SetActiveIfNecessary(self._grandIcon, self.m_viewModel.grandFlag);


  self:AddButtonClickListener(self._startBtn, self.EventOnToLiveClick)
  self:AddButtonClickListener(self._leaveBtn, self.EventOnExitClick)
  self:AddButtonClickListener(self._unableBtn, self.EventOnToLiveUnableClick)
  self.m_cardListAdapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._cardAdapter, 
      self._CreateCard, self._GetCardCount, self._UpdateCard);
  self.m_cardListAdapter:NotifyDataSetChanged();

  local hubPath = CS.Torappu.ResourceUrls.GetAct4funCommentIconHubPath();

  for headIconIdx = 1, Act4funBattleFinishViewModel.HEADICON_COUNT do
    local headIcon = CS.UnityEngine.GameObject.Instantiate(self._headIconImg, self._headIconContainer)
    headIcon.sprite = self:LoadSpriteFromAutoPackHub(hubPath,self.m_viewModel.headiconList[headIconIdx]);
  end

  CS.Torappu.UI.UINotification.TextToast(toastText)
  self:_InitBGM()
end

function Act4FunBattleFinishDlg:_InitBGM()
  local config = CS.Torappu.UI.UIMusicManager.ChunkConfig()
  config.signal = CS.Torappu.Audio.Consts.ACTIVITY_LOADED
  config.subSignal = self._subsignal
  CS.Torappu.UI.UIMusicManager.ModifyMusicChunk(self.m_root:GetInstanceID(), config) 
  CS.Torappu.UI.UIMusicManager.SyncPlayingMusic()
end

function Act4FunBattleFinishDlg:EventOnExitClick()
  if (self.m_viewModel.ableToLive) then
    local conifg = {
      descText = StringRes.ACTFUN_GOBACK_TO_HOME;
      onPositive = Event.Create(self, self._ToHomeScene);
      onNegative = Event.Create(self, nil);
    };
    self.m_judgeDialogHandle:ShowDialog(conifg)
  else
    self:_ToHomeScene()
  end
end

function Act4FunBattleFinishDlg:_ToHomeScene()
  CS.Torappu.UI.BattleFinish.BattleFinishSceneManager.RouteToHomeSceneDefault()
end

function Act4FunBattleFinishDlg:EventOnToLiveClick()
  CS.Torappu.UI.BattleFinish.BattleFinishSceneManager.JumpToAct4fun()
end

function Act4FunBattleFinishDlg:EventOnToLiveUnableClick()
  if (self.m_viewModel.isNewStage) then
    CS.Torappu.UI.UINotification.TextToast(StringRes.ACTFUN_GUIDE_STAGE_NOT_COMPLETE);
  else
    CS.Torappu.UI.UINotification.TextToast(StringRes.ACTFUN_PHOTO_NOT_COMPLETE);
  end
end

function Act4FunBattleFinishDlg:_CreateCard(gameObj)
  local card = self:CreateWidgetByGO(Act4funLivePhotoCard, gameObj)
  return card;
end

function Act4FunBattleFinishDlg:_GetCardCount()
  if self.m_viewModel == nil or self.m_viewModel.cardList == nil then
    return 0;
  end
  return #self.m_viewModel.cardList;
end


function Act4FunBattleFinishDlg:_UpdateCard(index, card)
  local idx = index + 1;
  card:Update(idx, self.m_viewModel.cardList[idx], self.m_slectIdx)
end
