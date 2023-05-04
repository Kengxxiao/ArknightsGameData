local DeepSeaRPBattlePreviewStateHotfixer = Class("DeepSeaRPBattlePreviewStateHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util
 
local function OnBtnStartBattleClickFix(self)
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  self:OnBtnStartBattleClick();
end

local function OnBtnStartPracticeClickFix(self)
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  self:OnBtnStartPracticeClick();
end

local function ShowFix(self, param)
  self:Show(param);
end

local function OnValueChangedFix(self, property)
  self:_InitIfNot();

  local detailModel = property.Value;
  if detailModel == nil then
    return;
  end

  local stageModel = detailModel.currSelectStage;
  self._mapDesc.text = stageModel.stageDesc;
  local previewStageId = stageModel.id;
  if stageModel.stageDifficulty == CS.Torappu.LevelData.Difficulty.FOUR_STAR then
    local normalStage = detailModel.nodeModel.normalStage;
    if normalStage ~= nil then
      previewStageId = normalStage.id;
    end
  end
  self:_LoadMapPreview(previewStageId);
  self.m_switchTween.isShow = detailModel.isShowDetail;
end

local function StoryViewOnValueChangedFix(self, property)
  self:OnValueChanged(property);
  local model = property.Value;
  if model == nil then
    return;
  end
  local stageModel = model.currSelectStage;
  if stageModel == nil then
    return;
  end
  local storyList = stageModel.replayStoryData;
  if storyList == nil or storyList.Count == 0 then
    return;
  end
  
  local leftTextTransform = eutil.FindChild(self._leftBtnPanel.transform, "text_avg_name");
  local rightTextTransform = eutil.FindChild(self._rightBtnPanel.transform, "text_avg_name");
  if leftTextTransform == nil or rightTextTransform == nil then
    return;
  end
  local leftText = eutil.GetComponent(leftTextTransform.gameObject, "Text");
  local rightText = eutil.GetComponent(rightTextTransform.gameObject, "Text");
  if leftText == nil or rightText == nil then
    return;
  end

  if storyList.Count == 1 then
    local storyData = storyList[0];
    if storyData.trigger.type == CS.Torappu.StoryData.Trigger.TriggerType.BEFORE_BATTLE then
      leftText.text = CS.Torappu.StringRes.BEFORE_BATTLE_TRIGGER;
    elseif storyData.trigger.type == CS.Torappu.StoryData.Trigger.TriggerType.AFTER_BATTLE then
      leftText.text = CS.Torappu.StringRes.AFTER_BATTLE_TRIGGER;
    end
  else
    local leftStoryData = storyList[0];
    local rightStoryData = storyList[1];
    if leftStoryData.trigger.type == CS.Torappu.StoryData.Trigger.TriggerType.BEFORE_BATTLE then
      leftText.text = CS.Torappu.StringRes.BEFORE_BATTLE_TRIGGER;
    elseif leftStoryData.trigger.type == CS.Torappu.StoryData.Trigger.TriggerType.AFTER_BATTLE then
      leftText.text = CS.Torappu.StringRes.AFTER_BATTLE_TRIGGER;
    end
    if rightStoryData.trigger.type == CS.Torappu.StoryData.Trigger.TriggerType.BEFORE_BATTLE then
      rightText.text = CS.Torappu.StringRes.BEFORE_BATTLE_TRIGGER;
    elseif rightStoryData.trigger.type == CS.Torappu.StoryData.Trigger.TriggerType.AFTER_BATTLE then
      rightText.text = CS.Torappu.StringRes.AFTER_BATTLE_TRIGGER;
    end
  end
end

local function GoToSquadFix(self, stageId, hardId, isHard, isPractice, isAuto)
  if isHard and isPractice then
    local detailModel = self.m_stateBean.nodeDetailProperty.Value;
    if detailModel == nil or detailModel.nodeModel == nil then
      return;
    end
    local normalStage = detailModel.nodeModel.normalStage;
    if normalStage == nil then
      return;
    end
    self:_GoToSquad(normalStage.id, normalStage.hardStageId, isHard, isPractice, isAuto);
    return;
  end
  self:_GoToSquad(stageId, hardId, isHard, isPractice, isAuto);
end

local function EntryZoneButtonRenderFix(self, viewModel, isAllTimeout)
  self:Render(viewModel, isAllTimeout);

  if isAllTimeout then
    eutil.SetActiveIfNecessary(self._textProgress.gameObject, false);
    eutil.SetActiveIfNecessary(self._panelComplete, false);
    eutil.SetActiveIfNecessary(self._progressBar.gameObject, false);
  end
end 

function DeepSeaRPBattlePreviewStateHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.DeepSeaRP.DeepSeaRPBattlePreviewState)
  self:Fix_ex(CS.Torappu.UI.DeepSeaRP.DeepSeaRPBattlePreviewState, "OnBtnStartBattleClick", function(self)
    local ok, errorInfo = xpcall(OnBtnStartBattleClickFix, debug.traceback, self)
    if not ok then
      eutil.LogError("[DeepSeaRPBattlePreviewStateHotfixer] fix" .. errorInfo)
    end
  end);
  self:Fix_ex(CS.Torappu.UI.DeepSeaRP.DeepSeaRPBattlePreviewState, "OnBtnStartPracticeClick", function(self)
    local ok, errorInfo = xpcall(OnBtnStartPracticeClickFix, debug.traceback, self)
    if not ok then
      eutil.LogError("[DeepSeaRPBattlePreviewStateHotfixer] fix" .. errorInfo)
    end
  end);

  xlua.private_accessible(CS.Torappu.UI.DeepSeaRP.DeepSeaRPSquadHomeTechTreePluginView)
  self:Fix_ex(CS.Torappu.UI.DeepSeaRP.DeepSeaRPSquadHomeTechTreePluginView, "Show", function(self, param)
    local ok, errorInfo = xpcall(ShowFix, debug.traceback, self, param)
    if not ok then
      eutil.SetActiveIfNecessary(self.gameObject, false);
    end
  end);

  xlua.private_accessible(CS.Torappu.UI.DeepSeaRP.DeepSeaRPBattleDetailView);
  self:Fix_ex(CS.Torappu.UI.DeepSeaRP.DeepSeaRPBattleDetailView, "OnValueChanged", function(self, property)
    local ok, errorInfo = xpcall(OnValueChangedFix, debug.traceback, self, property)
    if not ok then
      eutil.LogError("[DeepSeaRPBattleDetailViewHotfixer] fix" .. errorInfo)
    end
  end);

  xlua.private_accessible(CS.Torappu.UI.DeepSeaRP.DeepSeaRPBattleStoryView);
  self:Fix_ex(CS.Torappu.UI.DeepSeaRP.DeepSeaRPBattleStoryView, "OnValueChanged", function(self, property)
    local ok, errorInfo = xpcall(StoryViewOnValueChangedFix, debug.traceback, self, property)
    if not ok then
      eutil.LogError("[DeepSeaRPBattleStoryViewHotfixer] fix" .. errorInfo)
    end
  end);

  self:Fix_ex(CS.Torappu.UI.DeepSeaRP.DeepSeaRPBattlePreviewState, "_GoToSquad", function(self, stageId, hardId, isHard, isPractice, isAuto)
    local ok, errorInfo = xpcall(GoToSquadFix, debug.traceback, self, stageId, hardId, isHard, isPractice, isAuto)
    if not ok then
      eutil.LogError("[DeepSeaRPBattlePreviewStateHotfixer] fix" .. errorInfo)
    end
  end);

  xlua.private_accessible(CS.Torappu.Activity.Act17side.Act17sideEntryZoneButtonView);
  self:Fix_ex(CS.Torappu.Activity.Act17side.Act17sideEntryZoneButtonView, "Render", function(self, viewModel, isAllTimeout)
    local ok, errorInfo = xpcall(EntryZoneButtonRenderFix, debug.traceback, self, viewModel, isAllTimeout);
    if not ok then
      eutil.LogError("[Act17sideEntryZoneButtonViewHotfixer] fix" .. errorInfo);
    end
  end);
end
 
function DeepSeaRPBattlePreviewStateHotfixer:OnDispose()
end
 
return DeepSeaRPBattlePreviewStateHotfixer