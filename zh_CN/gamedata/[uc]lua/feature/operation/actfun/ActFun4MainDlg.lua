local luaUtils = CS.Torappu.Lua.Util;
local ActFun4MainDigStageCard = require "Feature/Operation/ActFun/Act4fun/Entry/ActFun4MainDigStageCard";




































































ActFun4MainDlg = DlgMgr.DefineDialog("ActFun4MainDlg", "Activity/ActFun/Actfun4/actfun4_dlg", DlgBase)

ActFun4MainDlg.DLG_NAME = "fun4"

local ANIM_KEY_IN = "actfun4_entry"
local ANIM_KEY_SWITCH = "actfun4_entry_switch"
local TOKEN_TRACK_TYPE = "ACT4FUN_TOKEN_LEVEL_UP"
local KEY_TRACK_TOKEN_LEVEL_UP = "key_track_token_level_up"
local REWARD_CARD_SCALE = 0.38


function ActFun4MainDlg:OnInit()
  self:_InitFromGameData()
  self:_InitBGM()

  self.m_stageAdapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._stageLayout, 
      self._CreateCard, self._GetCardCount, self._UpdateCard);
  
  self._animWrapper:InitIfNot()
  self._animWrapper:SampleClipAtBegin(ANIM_KEY_SWITCH)
  local location = CS.Torappu.UI.UIAnimationLocation();
  location.animationWrapper = self._animWrapper;
  location.animationName = ANIM_KEY_SWITCH;
  local builder = CS.Torappu.UI.AnimationSwitchTween.Builder(location);
  builder.ease = CS.DG.Tweening.Ease.OutQuint;
  builder.inactivateTargetIfHide = false;
  builder.tweenFromStart = false;
  self.m_switchTween = builder:Build();
  self.m_switchTween:Reset(false);

  self:AddButtonClickListener(self._btnAvg, self.EventOnAvgBtnClick)
  self:AddButtonClickListener(self._btnList, self.EventOnCollectionBtnClick)
  self:AddButtonClickListener(self._btnToken, self.EventOnTokenBtnClick)
  self:AddButtonClickListener(self._btnNormMission, self.EventOnNormMissionBtnClick)
  self:AddButtonClickListener(self._btnRewardMission, self.EventOnRewardMissionBtnClick)
  self:AddButtonClickListener(self._btnFinishedMission, self.EventOnNormMissionBtnClick)
  self:AddButtonClickListener(self._btnSwitch, self.EventOnSwitchBtnClick)
  self:AddButtonClickListener(self._btnStudyStage, self.EventOnStudyStageBtnClick)

  self:_RefreshContent()
  self:_PlayEnterAnim()
end

function ActFun4MainDlg:OnResume()
  self.m_viewModel:RefreshData()
  self:_RefreshContent()
end

function ActFun4MainDlg:_CreateCard(gameObj)
  local card = self:CreateWidgetByGO(ActFun4MainDigStageCard, gameObj)
  card.evtClick = Event.Create(self, self._SelectStage)
  return card;
end

function ActFun4MainDlg:_GetCardCount()
  if self.m_viewModel == nil or self.m_viewModel.stageModels == nil then
    return 0;
  end
  return #self.m_viewModel.stageModels;
end

function ActFun4MainDlg:_UpdateCard(index, card)
  local idx = index + 1;
  card:Update(idx, self.m_viewModel.stageModels[idx])
end

function ActFun4MainDlg:_InitFromGameData()
  self.m_isShowPanelStage = false
  self.m_viewModel = self:CreateViewModel(ActFun4MainDlgViewModel)
  local stageIds = {}
  table.insert(stageIds, self._stageId1)
  table.insert(stageIds, self._stageId2)
  table.insert(stageIds, self._stageId3)
  self.m_viewModel:LoadData(self._charId, stageIds)
  
end

function ActFun4MainDlg:_InitBGM()
  local config = CS.Torappu.UI.UIMusicManager.ChunkConfig()
  config.signal = CS.Torappu.Audio.Consts.ACTIVITY_LOADED
  config.subSignal = self._subsignal
  CS.Torappu.UI.UIMusicManager.ModifyMusicChunk(self.m_parent:GetInstanceID(), config) 
  CS.Torappu.UI.UIMusicManager.SyncPlayingMusic()
end

function ActFun4MainDlg:_RefreshContent()
  if self.m_viewModel.playerData == nil then
    return
  end
  if self.m_viewModel.playerData.actFun4 == nil then
    return
  end

  self:_SwitchViews(false)
  
  self._txtActInfo.text = self.m_viewModel.gameData.constant.mainPageEventDes
  self._txtTokenLevel.text =  self.m_viewModel.tokenModel.level
  SetGameObjectActive(self._panelTokenMax, self.m_viewModel.tokenModel:IsLevelMax())
  self:_RefreshTokenTrack()
  
  self:_RefreshCharInfo()
  
  self:_RefreshMissionPart()
  
  self:_RefreshStages()
end

function ActFun4MainDlg:_SwitchViews(needAnim)
  self.m_switchTween.isShow = needAnim;
end

function ActFun4MainDlg:_RefreshTokenTrack()
  local needTrack = self.CheckTokenLevelUp()
  SetGameObjectActive(self._panelTokenTrackPoint, needTrack)
end

function ActFun4MainDlg:_RefreshCharInfo()
  local needShowV = self.m_viewModel:CheckNeedShowV()
  SetGameObjectActive(self._panelV, needShowV)
  self._txtVideos.text = self.m_viewModel.playerData.actFun4.posts
  self._txtFans.text = self.m_viewModel.playerData.actFun4.fansNum
  self._txtNickName.text = self.m_viewModel.gameData.constant.mainPagePersonal
  self._txtLegion.text = self.m_viewModel.gameData.constant.mainPageJobDes
  local gotDiamond = self.m_viewModel:CheckDiamondGot()
  SetGameObjectActive(self._panelDiamondNotGet, not gotDiamond)
  SetGameObjectActive(self._panelDiamondGot, gotDiamond)
  local gotChar = self.m_viewModel:CheckGotChar()
  SetGameObjectActive(self._panelCharEmpty, not gotChar)
  SetGameObjectActive(self._panelCharStatus, gotChar)
  if gotChar then
    local playerChar = self.m_viewModel.playerChar
    self._imgCharPotential.sprite = CS.Torappu.DataConvertUtil.GetPotentialIcon(playerChar.potentialRank, false)
    local favorData = CS.Torappu.FavorDB.instance:GetFavorData(playerChar.favorPoint)
    if favorData ~= nil then
      local favorPercent = favorData.percent;
      self._txtFavor.text = luaUtils.Format("{0}%", favorPercent);
      local anchorMax = self._transformFavor.anchorMax
      anchorMax.x = favorPercent / CS.Torappu.DataConvertUtil.GetMaxFavorPercent()
      self._transformFavor.anchorMax = anchorMax
    else
      self._txtFavor.text = ''
      self._transformFavor.anchorMax.x = 0
    end
  end
end

function ActFun4MainDlg:_RefreshMissionPart()
  local missionFinished = self.m_viewModel.finishedMissionCount == self.m_viewModel.totalMissionCount
  local hasRward = self.m_viewModel.curRewardMissionModel ~= nil
  SetGameObjectActive(self._panelMissionComp, missionFinished)
  SetGameObjectActive(self._panelMissionReward, not missionFinished and hasRward)
  SetGameObjectActive(self._panelMissionNorm, not missionFinished and not hasRward)
  if not missionFinished and hasRward then
    self._txtRewardMission.text = self.m_viewModel.curRewardMissionModel.missionData.missionDes
    local rewards = self.m_viewModel.curRewardMissionModel.missionData.rewards
    self:_RefreshMissionRewards(rewards)
  elseif not missionFinished and not hasRward then
    self._txtNormMission.text = string.format("%d/%d", self.m_viewModel.finishedMissionCount, self.m_viewModel.totalMissionCount)
  end
end

function ActFun4MainDlg:_RefreshMissionRewards(rewards)
  if rewards == nil or rewards.Count == 0 then
    SetGameObjectActive(self._rewardItem1Container.GameObject, false)
    SetGameObjectActive(self._rewardItem2Container.GameObject, false)
    return
  end
  if rewards.Count >= 1 then
    if self.m_rewardItemCard1 == nil then
      self.m_rewardItemCard1 = self:_CreateRewardCard(self._rewardItem1Container)
      self:AsignDelegate(self.m_rewardItemCard1, "onItemClick", function(this, index)
        self:_OnRewardItemCardClick(self.m_rewardItemCard1.gameObject, self.m_reward1Model)
      end)
    end
    SetGameObjectActive(self._rewardItem1Container.GameObject, true)
    self.m_reward1Model = CS.Torappu.UI.UIItemViewModel()
    self.m_reward1Model:LoadGameData(rewards[0].id, rewards[0].type)
    self.m_rewardItemCard1:Render(0, self.m_reward1Model)
  else
    SetGameObjectActive(self._rewardItem1Container.GameObject, false)
  end
  if rewards.Count >= 2 then
    if self.m_rewardItemCard2 == nil then
      self.m_rewardItemCard2 = self:_CreateRewardCard(self._rewardItem2Container)
      self:AsignDelegate(self.m_rewardItemCard2, "onItemClick", function(this, index)
        self:_OnRewardItemCardClick(self.m_rewardItemCard2.gameObject, self.m_reward2Model)
      end)
    end
    SetGameObjectActive(self._rewardItem2Container.GameObject, true)
    self.m_reward2Model = CS.Torappu.UI.UIItemViewModel()
    self.m_reward2Model:LoadGameData(rewards[1].id, rewards[1].type)
    self.m_rewardItemCard2:Render(0, self.m_reward2Model)
  else
    SetGameObjectActive(self._rewardItem2Container.GameObject, false)
  end
end

function ActFun4MainDlg:_CreateRewardCard(itemContainer)
  local itemCard = CS.Torappu.UI.UIAssetLoader.instance.staticOutlinks.uiItemCard;
  local rewardCard = CS.UnityEngine.GameObject.Instantiate(itemCard, itemContainer):GetComponent("Torappu.UI.UIItemCard");
  rewardCard.isCardClickable = true;
  rewardCard.showItemName = false;
  rewardCard.showItemNum = true;
  rewardCard.showBackground = true;
  local scaler = rewardCard:GetComponent("Torappu.UI.UIScaler");
  if scaler ~= nil then
    scaler.scale = REWARD_CARD_SCALE;
  end
  return rewardCard
end

function ActFun4MainDlg:_RefreshStages()
  local studyStageModel = self.m_viewModel.studyStageModel
  if studyStageModel == nil then
    return
  end
  local isStudyStagePlayed = self.m_viewModel:IsStagePassed(studyStageModel)
  SetGameObjectActive(self._panelStudyNormal, not isStudyStagePlayed)
  SetGameObjectActive(self._panelStudyPlayed, isStudyStagePlayed)
  local codeSprite = self._atlasObject:GetSpriteByName(studyStageModel.stageId)
  self._imgStudyCode:SetSprite(codeSprite)
  self._txtStudyName.text = studyStageModel.stageData.name
  local infoColor = self._imgStudyCode.color
  if isStudyStagePlayed then
    infoColor.a = 0.7
    self._imgStudyCode.color = infoColor
    self._txtStudyName.color = infoColor
  else
    infoColor.a = 1
    self._imgStudyCode.color = infoColor
    self._txtStudyName.color = infoColor
  end
  self.m_stageAdapter:NotifyDataSetChanged();
end

function ActFun4MainDlg:_SelectStage(index)
  local targetStageModel = self.m_viewModel.stageModels[index]
  if targetStageModel == nil or targetStageModel.stageId == nil then
    return
  end
  self:_StartActFun4Battle(self._aprilFoolId, targetStageModel.stageId)
end

function ActFun4MainDlg:_StartActFun4Battle(actId, stageId)
  local startServiceConfig = CS.Torappu.Activity.Act4fun.Act4FunBattleStartConfig(stageId)
  local finishServiceConfig = CS.Torappu.Activity.Act4fun.Act4FunBattleFinishServerConfig(
      CS.Torappu.Activity.Act4fun.Act4FunService.FUN_BATTLE_FINISH)
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
  bundle:SetString(ActFunMainDlgGroup.KEY_INITDLG, ActFun4MainDlg.DLG_NAME)
  actMeta.meta = bundle
  local funLiveInput = CS.Torappu.Battle.FunLive.FunLiveInput()
  funLiveInput.skillLevel = self.m_viewModel.tokenModel.level
  local gameModeMeta = {
    isDeterministic = false,
    modeType = CS.Torappu.Battle.GameModeMeta.GameModeType.FUNLIVE,
    extraData = funLiveInput
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
  }
  CS.Torappu.BattleStartController.StartBattle(param)
end

function ActFun4MainDlg:_PlayEnterAnim()
  self._animWrapper:InitIfNot()
  self._animWrapper:SampleClipAtBegin(ANIM_KEY_IN)
  local enterTween = self._animWrapper:PlayWithTween(ANIM_KEY_IN)
  enterTween:SetEase(CS.DG.Tweening.Ease.Linear)
end

function ActFun4MainDlg:_HandleRecvMissionResponse(response) 
  UIMiscHelper.ShowGainedItems(response.items)
  self.m_viewModel:RefreshData()
  self:_RefreshContent()
end

function ActFun4MainDlg:EventOnAvgBtnClick()
  CS.Torappu.Lua.LuaActivityEntry.StartStoryWithSyncMusic(self._avgStoryId)
end

function ActFun4MainDlg:EventOnCollectionBtnClick()
  local parent = self.m_parent
  parent:SetRecentPlayedAct(ActFun4MainDlg.DLG_NAME)
  parent:GetGroup():SwitchChildDlg(ActFunCollectionDlg)
end

function ActFun4MainDlg:EventOnTokenBtnClick()
  if self.m_isShowPanelStage then
    return
  end
  if self.m_tokenPanel == nil then
    self.m_tokenPanel = self:CreateWidgetByPrefab(ActFun4MainDlgTokenPanel, self._tokenPrefab, self._tokenContainer)
    self.m_tokenPanel:Init()
  end
  self.ConsumeTokenLevelUp()
  self:_RefreshTokenTrack()
  self.m_tokenPanel:Update(self.m_viewModel.tokenModel, true)
end

function ActFun4MainDlg:EventOnNormMissionBtnClick()
  if self.m_isShowPanelStage then
    return
  end
  if self.m_missionPanel == nil then
    self.m_missionPanel = self:CreateWidgetByPrefab(ActFun4MainDlgMissionPanel, self._missionPrefab, self._missionContainer)
    self.m_missionPanel:Init()
  end
  self.m_missionPanel:Update(self.m_viewModel.missionModels, true)
end

function ActFun4MainDlg:EventOnRewardMissionBtnClick()
  if self.m_isShowPanelStage then
    return
  end

  UISender.me:SendRequest(Act4funEntryServiceCode.RECV_MISSION,
  {
  }, 
  {
    onProceed = Event.Create(self, self._HandleRecvMissionResponse)
  });
end

function ActFun4MainDlg:EventOnSwitchBtnClick()
  self.m_isShowPanelStage = not self.m_isShowPanelStage
  self:_SwitchViews(self.m_isShowPanelStage)
end

function ActFun4MainDlg:EventOnStudyStageBtnClick()
  local studyStageModel = self.m_viewModel.studyStageModel
  if studyStageModel == nil or studyStageModel.stageId == nil then
    return
  end
  self:_StartActFun4Battle(self._aprilFoolId, studyStageModel.stageId)
end

function ActFun4MainDlg:_OnRewardItemCardClick(gameObject, itemModel)
  if gameObject == nil or itemModel == nil then
    return
  end
  CS.Torappu.UI.UIItemDescFloatController.ShowItemDesc(gameObject, itemModel)
end

function ActFun4MainDlg:CheckTokenLevelUp()
  return CS.Torappu.LocalTrackStore.instance:CheckTrack(TOKEN_TRACK_TYPE, KEY_TRACK_TOKEN_LEVEL_UP)
end

function ActFun4MainDlg:LogTokenLevelUp()
  local tokenLevel = CS.Torappu.PlayerData.instance.data.playerAprilFool.actFun4.tokenLevel
  local tokenLevelMax = CS.Torappu.ActivityDB.data.actFunData.act4FunData.tokenLevelInfos.Count
  if tokenLevel == 1 or tokenLevel == tokenLevelMax then
    return
  end
  CS.Torappu.LocalTrackStore.instance:DoTrackTrigger(TOKEN_TRACK_TYPE, KEY_TRACK_TOKEN_LEVEL_UP)
end

function ActFun4MainDlg:ConsumeTokenLevelUp()
  CS.Torappu.LocalTrackStore.instance:ConsumeTrack(TOKEN_TRACK_TYPE, KEY_TRACK_TOKEN_LEVEL_UP)
end

Act4funEntryServiceCode = 
{
  RECV_MISSION = "/aprilFool/act4fun/recvMission"
}
Readonly(Act4funEntryServiceCode)
