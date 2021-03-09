local luaUtils = CS.Torappu.Lua.Util;





































Act17D7MainDlg = Class("Act17D7MainDlg", DlgBase)

local ANIM_KEY_IN = "anim_in"

local function _SetActive(gameObj, isActive)
  luaUtils.SetActiveIfNecessary(gameObj, isActive)
end


function Act17D7MainDlg:OnInit()
  local actId = self.m_parent:GetData("actId")
  self:_InitFromGameData(actId)
  self:_InitBGM()

  self:AddButtonClickListener(self._btnClose, self.EventOnCloseClick)
  self:AddButtonClickListener(self._btnAvg1, self.EventOnAvg1BtnClick)
  self:AddButtonClickListener(self._btnAvg2, self.EventOnAvg2BtnClick)
  self:AddButtonClickListener(self._btnStartBattle, self.EventOnStartBattleClick)
  
  self:_RefreshContent()
end


function Act17D7MainDlg:OnClose()
  self:_ClearBGM()
end

function Act17D7MainDlg:_InitFromGameData(actId)
  self.m_actId = actId
  self:_InitFromDynActs(actId)
  self:_InitFromStageData()
  self:_InitFromPlayerData()
end

function Act17D7MainDlg:_InitFromDynActs(actId)
  local dynActs = CS.Torappu.ActivityDB.data.dynActs;
  if actId == nil or dynActs == nil then
    return
  end
  local suc, jObject = dynActs:TryGetValue(actId)
  if not suc then
    luaUtils.LogError("Activity not found in dynActs : "..actId)
    return
  end
  local data = luaUtils.ConvertJObjectToLuaTable(jObject)
  self.m_battleFinishWord = data.battleFinishCharWord
end

function Act17D7MainDlg:_InitFromStageData()
  local suc, stageData = CS.Torappu.StageDB.instance:TryGetStage(self._stageId)
  if not suc then
    return;
  end
  local displayDetailRewards = stageData.stageDropInfo.displayDetailRewards;
  for i = 0, displayDetailRewards.Count-1 do
    local reward = displayDetailRewards[i]
    if reward.dropType == CS.Torappu.StageDropType.ONCE then
      self.m_reward1Item = reward
    end
    if reward.dropType == CS.Torappu.StageDropType.COMPLETE then
      self.m_reward2Item = reward
    end
  end
  self.m_battleDesc = stageData.description
end

function Act17D7MainDlg:_InitFromPlayerData()
  local suc, stageStatus = CS.Torappu.PlayerData.instance.data.dungeon.stages:TryGetValue(self._stageId)
  self.m_rank = 0
  if not suc or stageStatus == nil then
    return;
  end
  self.m_rank = stageStatus.state.value__
end

function Act17D7MainDlg:_InitBGM()
  local config = CS.Torappu.UI.UIMusicManager.ChunkConfig()
  config.signal = CS.Torappu.Battle.AudioSignals.ON_GAME_READY
  config.subSignal = self._subsignal
  config.playModule = CS.Torappu.UI.UIMusicManager.PlayModuleType.MODULE_BATTLE
  CS.Torappu.UI.UIMusicManager.ModifyMusicChunk(self:_GetInstanceID(), config)
  CS.Torappu.UI.UIMusicManager.SyncPlayingMusic()
end

function Act17D7MainDlg:_GetInstanceID()
  return self:GetLuaLayout():GetInstanceID()
end

function Act17D7MainDlg:_RefreshContent()
  self._textDesc.text = self.m_battleDesc
  self:_RefreshRewards(self.m_rank)
  self:_RefreshRankView(self.m_rank)
  self:_RefreshStartBtn()
end


function Act17D7MainDlg:_RefreshRewards(rank)
  local itemCardPrefab = CS.Torappu.UI.UIAssetLoader.instance.itemCardPrefab
  if (self.m_reward1ItemCard == nil) then
    self.m_reward1ItemCard = CS.UnityEngine.GameObject.Instantiate(itemCardPrefab, self._reward1Container):GetComponent("Torappu.UI.UIItemCard")
    local scaler = self.m_reward1ItemCard:GetComponent("Torappu.UI.UIScaler");
    if scaler then
      scaler.scale = 0.5;
    end
  end
  if (self.m_reward2ItemCard == nil) then
    self.m_reward2ItemCard = CS.UnityEngine.GameObject.Instantiate(itemCardPrefab, self._reward2Container):GetComponent("Torappu.UI.UIItemCard")
    local scaler = self.m_reward2ItemCard:GetComponent("Torappu.UI.UIScaler");
    if scaler then
      scaler.scale = 0.5;
    end
  end

  if self.m_reward1Item ~= nil then
    local rewardData1 = CS.Torappu.UI.UIItemViewModel();
    rewardData1:LoadGameData(self.m_reward1Item.id, self.m_reward1Item.type);
    self.m_reward1ItemCard:Render(0, rewardData1);
    self:AsignDelegate(self.m_reward1ItemCard, "onItemClick", function(this, index)
      CS.Torappu.UI.UIItemDescFloatController.ShowItemDesc(self.m_reward1ItemCard.gameObject, rewardData1);
    end);
    local isNotGot = rank <= 1
    self.m_reward1ItemCard.isCardClickable = isNotGot
    _SetActive(self._reward1Panel, true)
    _SetActive(self._imgReward1Desc, isNotGot);
    _SetActive(self._imgReward1Got, not isNotGot);
    if isNotGot then
      self.m_reward1ItemCard.mainColor = CS.Torappu.ColorRes.TweenHtmlStringToColor('#FFFFFFFF')
    else
      self.m_reward1ItemCard.mainColor = CS.Torappu.ColorRes.TweenHtmlStringToColor('#FFFFFF80')
    end
  else
    _SetActive(self._reward1Panel, false)
  end

  if self.m_reward2Item ~= nil then
    local rewardData2 = CS.Torappu.UI.UIItemViewModel();
    rewardData2:LoadGameData(self.m_reward2Item.id, self.m_reward2Item.type);
    self.m_reward2ItemCard:Render(0, rewardData2);
    self:AsignDelegate(self.m_reward2ItemCard, "onItemClick", function(this, index)
      CS.Torappu.UI.UIItemDescFloatController.ShowItemDesc(self.m_reward2ItemCard.gameObject, rewardData2);
    end);
    local isNotGot = rank <= 2
    self.m_reward2ItemCard.isCardClickable = isNotGot
    _SetActive(self._reward2Panel, true)
    _SetActive(self._imgReward2Desc, isNotGot);
    _SetActive(self._imgReward2Got, not isNotGot);
    if isNotGot then
      self.m_reward2ItemCard.mainColor = CS.Torappu.ColorRes.TweenHtmlStringToColor('#FFFFFFFF')
    else
      self.m_reward2ItemCard.mainColor = CS.Torappu.ColorRes.TweenHtmlStringToColor('#FFFFFF80')
    end
  else
    _SetActive(self._reward2Panel, false)
  end
end


function Act17D7MainDlg:_RefreshRankView(rank)
  if rank > 1 then
    self._rankItem1.state = CS.Torappu.UI.TwoStateToggle.State.SELECT
  else
    self._rankItem1.state = CS.Torappu.UI.TwoStateToggle.State.UNSELECT
  end
  if rank > 1 then
    self._rankItem2.state = CS.Torappu.UI.TwoStateToggle.State.SELECT
  else
    self._rankItem2.state = CS.Torappu.UI.TwoStateToggle.State.UNSELECT
  end
  if rank > 2 then
    self._rankItem3.state = CS.Torappu.UI.TwoStateToggle.State.SELECT
  else
    self._rankItem3.state = CS.Torappu.UI.TwoStateToggle.State.UNSELECT
  end
end

function Act17D7MainDlg:_RefreshStartBtn()
  self._animWrapper:InitIfNot()
  self._animWrapper:SampleClipAtBegin(ANIM_KEY_IN)
  local tweenHandler = self._animWrapper:PlayWithTween(ANIM_KEY_IN)
  tweenHandler:SetDelay(0.3)
end

function Act17D7MainDlg:EventOnCloseClick()
  self:Close()
end

function Act17D7MainDlg:EventOnAvg1BtnClick()
  CS.Torappu.Lua.LuaActivityEntry.StartStoryWithSyncMusic(self._avg1StoryId)
end

function Act17D7MainDlg:EventOnAvg2BtnClick()
  CS.Torappu.Lua.LuaActivityEntry.StartStoryWithSyncMusic(self._avg2StoryId)
end

function Act17D7MainDlg:EventOnStartBattleClick()
  local param = CS.Torappu.BattleStartController.Param()
  param.stageId = self._stageId;
  param.isPractise = false
  param.isAutoBattle = false
  param.assistIsFriend = false
  param.squadForRequest = nil
  param.assistFriend = nil
  param.squadLocal = nil
  param.sysMenuStyle = CS.Torappu.Battle.UI.BattleSysMenuStyle.NO_REWARD
  param.bundleToJumpBack = nil

  local stageIdStruct = CS.Torappu.UI.StageId(self._stageId, nil, false)
  param.overrideStageIdStruct = stageIdStruct

  local illust = CS.Torappu.Battle.BattleFinishIllust()
  local skin = CS.Torappu.CharUISkinStruct()
  skin.charId = self._battleFinishCharId
  skin.skinId = self._battleFinishSkinId
  illust.overrideSkin = skin
  local charWord = CS.Torappu.CharWordData()
  charWord.voiceText = self.m_battleFinishWord
  illust.overrideCharWord = charWord
  param.finishIllust = illust

  local actMeta = CS.Torappu.Battle.BattleActivityMeta()
  actMeta.activityId = self.m_actId
  actMeta.backAsHomeAct = true
  param.actMeta = actMeta
  CS.Torappu.BattleStartController.StartBattle(param)
end

function Act17D7MainDlg:_ClearBGM()
  CS.Torappu.UI.UIMusicManager.RemoveMusicChunk(self:_GetInstanceID())
  CS.Torappu.UI.UIMusicManager.SyncPlayingMusic()
end