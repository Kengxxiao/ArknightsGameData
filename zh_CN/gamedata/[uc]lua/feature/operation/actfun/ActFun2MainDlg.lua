local luaUtils = CS.Torappu.Lua.Util;





































ActFun2MainDlg = DlgMgr.DefineDialog("ActFun2MainDlg", "Activity/ActFun/actfun2_dlg", DlgBase)

ActFun2MainDlg.DLG_NAME = "fun2"

local ANIM_KEY_IN = "anim_actfun2_in"

local function _SetActive(gameObj, isActive)
  luaUtils.SetActiveIfNecessary(gameObj, isActive)
end


function ActFun2MainDlg:OnInit()
  local realActId = self.m_parent:GetData("actId")
  self.m_realActId = realActId 

  self:_InitFromGameData(self._actId) 
  self:_InitBGM()

  self:AddButtonClickListener(self._btnClose, self.EventOnCloseClick)
  self:AddButtonClickListener(self._btnAvg, self.EventOnAvgBtnClick)
  self:AddButtonClickListener(self._btnList, self.EventOnCollectionBtnClick)
  self:AddButtonClickListener(self._btnStartBattle, self.EventOnStartBattleClick)
  
  self:_RefreshContent()
end

function ActFun2MainDlg:_InitFromGameData(actId)
  self:_InitFromDynActs(actId)
  self:_InitFromStageData()
  self:_InitFromPlayerData()
end

function ActFun2MainDlg:_InitFromDynActs(actId)
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

function ActFun2MainDlg:_InitFromStageData()
  local stageData = CS.Torappu.StageDataUtil.GetStageOrNull(self._stageId)
  if stageData == nil then
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

function ActFun2MainDlg:_InitFromPlayerData()
  local suc, stageStatus = CS.Torappu.PlayerData.instance.data.dungeon.stages:TryGetValue(self._stageId)
  self.m_rank = 0
  if not suc or stageStatus == nil then
    return;
  end
  self.m_rank = stageStatus.state.value__
end

function ActFun2MainDlg:_InitBGM()
  local config = CS.Torappu.UI.UIMusicManager.ChunkConfig()
  config.signal = CS.Torappu.Battle.AudioSignals.ON_GAME_READY
  config.subSignal = self._subsignal
  config.playModule = CS.Torappu.UI.UIMusicManager.PlayModuleType.MODULE_BATTLE
  CS.Torappu.UI.UIMusicManager.ModifyMusicChunk(self.m_parent:GetInstanceID(), config) 
  CS.Torappu.UI.UIMusicManager.SyncPlayingMusic()
end

function ActFun2MainDlg:_RefreshContent()
  self._textDesc.text = self.m_battleDesc
  self:_RefreshRewards(self.m_rank)
  self:_RefreshRankView(self.m_rank)
  self:_RefreshStartBtn()
end


function ActFun2MainDlg:_RefreshRewards(rank)
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


function ActFun2MainDlg:_RefreshRankView(rank)
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

function ActFun2MainDlg:_RefreshStartBtn()
  self._animWrapper:InitIfNot()
  self._animWrapper:SampleClipAtBegin(ANIM_KEY_IN)
  local tweenHandler = self._animWrapper:PlayWithTween(ANIM_KEY_IN)
  tweenHandler:SetDelay(0.3)
end

function ActFun2MainDlg:EventOnCloseClick()
  self:Close()
end

function ActFun2MainDlg:EventOnAvgBtnClick()
  CS.Torappu.Lua.LuaActivityEntry.StartStoryWithSyncMusic(self._avgStoryId)
end

function ActFun2MainDlg:EventOnCollectionBtnClick()
  local parent = self.m_parent
  parent:SetRecentPlayedAct(ActFun2MainDlg.DLG_NAME)
  parent:GetGroup():SwitchChildDlg(ActFunCollectionDlg)
end

function ActFun2MainDlg:EventOnStartBattleClick()
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
  actMeta.activityId = self._actId
  actMeta.backAsHomeAct = true
  
  
  local bundle = CS.Torappu.DataBundle()
  bundle:SetString(ActFunMainDlgGroup.KEY_INITDLG, ActFun2MainDlg.DLG_NAME)
  actMeta.meta = bundle

  param.actMeta = actMeta
  
  local gameTagMeta = {
    gameTag = CS.Torappu.Battle.GameTagMeta.ACTFUN
  }
  param.gameTagMeta = gameTagMeta

  CS.Torappu.BattleStartController.StartBattle(param)
end