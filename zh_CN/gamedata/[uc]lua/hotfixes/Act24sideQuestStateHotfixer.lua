
local Act24sideQuestStateHotfixer = Class("Act24sideQuestStateHotfixer", HotfixBase)

local Act24sideQuestState = CS.Torappu.Activity.Act24side.Act24sideQuestState
local AutoBattleConvertUtil = CS.Torappu.UI.AutoBattleConvertUtil
local ServiceCode = CS.Torappu.Network.ServiceCode
local UIPopupWindow = CS.Torappu.UI.UIPopupWindow
local StringRes = CS.Torappu.StringRes

local function _OpenSquadAfterLoadBattleLog(self, actId, questItemModel)
  local stageId = questItemModel.stageId
  local hasBattleLog = AutoBattleConvertUtil.TryLoadBattleLogFromMem(stageId, nil)
  if hasBattleLog then
    self:_OpenSquad(actId, questItemModel, false)
    return
  end

  UISender.me:SendRequest(ServiceCode.LOAD_BATTLE_REPLAY, {
    stageId = stageId
  }, {
    onProceed = Event.CreateStatic(function(response)
      if response == nil or response.battleReplay == nil or response.battleReplay == "" then
        UIPopupWindow.Alert(StringRes.ERROR_BATTLE_REPLAY_NOT_FOUND)
        return
      end

      local success, battleLog = AutoBattleConvertUtil.TryDecompressBattleLog(response.battleReplay, nil)
      if success then
        AutoBattleConvertUtil.SaveBattleLogToMem(stageId, battleLog)
        self:_OpenSquad(actId, questItemModel, false)
      else
        UIPopupWindow.Alert(StringRes.ERROR_BATTLE_REPLAY_NOT_FOUND)
      end
    end),
    onBlock = Event.CreateStatic(function(error)
      return false
    end)
  })
end

local function _EventOnBtnStartHotfix(self)
  if CS.Torappu.UI.UIPageController.isTransiting then
    return
  end

  local se = self:GetSupportStateEngine()
  if se == nil or se:IsTransitting() then
    return
  end

  local questModel = self.m_stateBean.prop.Value
  if questModel == nil then
    return
  end

  local selectQuestItemModel = questModel:FindSelectedQuestItemModel()
  if selectQuestItemModel == nil then
    return
  end

  if not self:_CheckCostBeforeStartBattle(selectQuestItemModel) then
    return
  end

  if not selectQuestItemModel.isMultiBattle then
    self:_OpenSquad(questModel.actId, selectQuestItemModel, false)
    return
  end

  _OpenSquadAfterLoadBattleLog(self, questModel.actId, selectQuestItemModel)
end

function Act24sideQuestStateHotfixer:OnInit()
  if HOTFIX_ENABLE then
    if xlua and xlua.private_accessible then
      xlua.private_accessible(Act24sideQuestState)
    end
    self:Fix_ex(Act24sideQuestState, "EventOnBtnStart", _EventOnBtnStartHotfix)
  end
end

return Act24sideQuestStateHotfixer
