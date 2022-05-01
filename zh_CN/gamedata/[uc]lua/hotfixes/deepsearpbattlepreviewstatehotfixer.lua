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
end
 
function DeepSeaRPBattlePreviewStateHotfixer:OnDispose()
end
 
return DeepSeaRPBattlePreviewStateHotfixer