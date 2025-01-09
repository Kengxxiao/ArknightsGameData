

local xutil = require('xlua.util')



local V057Hotfixer = Class("V057Hotfixer", HotfixBase)

local luaUtils = CS.Torappu.Lua.Util;

local function Fix_Act1VAutoChessShopQuickAssist_TryRefreshNormalItemView(self, arg1)
  if self.view == nil then
    return;
  end
  self.view:Render(arg1);
end

local function Fix_Act1VAutoChessShopQuickAssist_TryRefreshTitleItemView(self, arg1)
  if self.view == nil then
    return;
  end
  self.view:Render(arg1);
end

local function _GetArcadeUnlockDes(actId, zoneId)
  local curTs = CS.Torappu.DateTimeUtil.timeStampNow
  local succ, zoneValidInfo = CS.Torappu.ZoneDB.data.zoneValidInfo:TryGetValue(zoneId)
  if not succ then
    return ""
  end
  local startTs = zoneValidInfo:GetStartTs()
  local endTs = zoneValidInfo:GetEndTs()
  local isNotOpen = curTs < startTs
  local isClosed = curTs >= endTs
  local avail = not isNotOpen and not isClosed
  if avail then
    return ""
  end
  local arcadeData = CS.Torappu.Activity.Act1Arcade.ArcadeUtil.GetActArcadeData(actId)
  if arcadeData == nil then
    return ""
  end
  if isNotOpen then
    local startTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(startTs)
    local timeSpan = startTime - CS.Torappu.DateTimeUtil.currentTime
    local timeDelta = CS.Torappu.FormatUtil.FormatTimeDelta(timeSpan)
    return luaUtils.Format(StringRes.ACT1ARCADE_STAGE_UNLOCK_TIME_FORMAT, timeDelta)
  else
    return arcadeData.constData.zoneEntryEndText
  end
end

local function Fix_Act1ArcadeEntryGameEntryItemViewModel_GetIsZoneAvail(self, actId, zoneId)
  local avail, _ = self:_GetIsZoneAvail(actId, zoneId)
  local unlockDes = _GetArcadeUnlockDes(actId, zoneId)
  return avail, unlockDes
end

local function Fix_Act1ArcadeStageZoneEntryItemView_OnValueChanged(self, property)
  self:OnValueChanged(property)
  if self.m_zoneModel == nil then
    return
  end
  local stageSelectModel = property:GetValueNotNull()
  local arcadeData = stageSelectModel.arcadeData
  if arcadeData == nil then
    return
  end
  self._textUnlockDes.text = _GetArcadeUnlockDes(stageSelectModel.actId, self.m_zoneModel.zoneId)
end

local ZONE_LAYER_MAP = {
  zone_1 = 1,
  zone_2 = 2,
  zone_3 = 3,
  zone_4 = 4,
  zone_5 = 5,
};


local function GetChatUnlockStatusFix(currentData)
  local status = CS.Torappu.RoguelikeDataUtil.GetChatUnlockStatus(currentData);
  local zoneIndex = currentData.player.cursor.zone;
  local playerMap = currentData.map;
  if playerMap == nil or playerMap.zones == nil then
    return status;
  end
  local ok, playerZone = playerMap.zones:TryGetValue(zoneIndex);
  if not ok then
    return status;
  end
  local zoneId = playerZone.id;
  local zoneLayer = ZONE_LAYER_MAP[zoneId];
  if zoneLayer == nil then
    return status;
  end
  status.curZone = zoneLayer;
  return status;
end

local function Fix_HomeCharRotationViewModel_LoadData(self)
  self:LoadData()
  local playerCharRotation = CS.Torappu.PlayerData.instance.data.charRotation
  if playerCharRotation == nil then
    return
  end
  self:RefreshData(playerCharRotation.currentPresetId, CS.Torappu.UI.Home.HomeCharRotationViewModel.SelectSkinStrategy.USE_NOW_PREVIEWING)
end

local function Fix_HomeCharRotationViewModel_RefreshData(self, displayPresetInstId, selectSkinStrategy)
  local cachedDisplayPresetInstId = self.displayPresetInstId
  self:RefreshData(displayPresetInstId, selectSkinStrategy)
  if displayPresetInstId == nil or displayPresetInstId.Length == 0 then
    if self.presets:ContainsKey(cachedDisplayPresetInstId) then
      self:_SetDisplayPreset(cachedDisplayPresetInstId, selectSkinStrategy)
    end
  end
end

local function Fix_HomeCharRotationPresetListDialog_EventOnBackBtnClicked(self)
  self.m_isHiding = true
  local output = CS.Torappu.ValueBundle()
  local intVal = 0
  if self.m_hasAppliedPreset then
    intVal = 1
  end	
  output.intVal = intVal
  local playerCharRotation = CS.Torappu.PlayerData.instance.data.charRotation
  if playerCharRotation == nil then
    return
  end
  output.strVal = playerCharRotation.currentPresetId
  self:OnConfirmWithHide(output)
end


local function Fix_BuildingDataConverter_LoadWorkshopFormulaUnlockCondition(formula) 
  
  local isUnlock, unlockCond = CS.Torappu.Building.BuildingDataConverter.LoadWorkshopFormulaUnlockCondition(formula);
  if not isUnlock then 
    return isUnlock, unlockCond;
  end
  
  local playerBuilding = CS.Torappu.PlayerData.instance.data.building;
  if playerBuilding == nil then
    return false, unlockCond;
  end
  local playerRooms = playerBuilding.rooms;
  if playerRooms == nil then
    return false, unlockCond;
  end
  local playerWorkshop = playerBuilding.rooms.workshop;
  if playerWorkshop == nil or playerWorkshop.Count == 0 then
    return false, unlockCond;
  end
  local slotId = playerWorkshop.Keys[0];
  local playerSlots = playerBuilding.roomSlots;
  if playerSlots == nil then
    return false, unlockCond;
  end
  local ok, slotInfo = playerSlots:TryGetValue(slotId);
  if not ok then 
    return false, unlockCond;
  end
  if slotInfo.state == CS.Torappu.PlayerRoomSlotState.UPGRADING then
    local lockInfo = StringRes.BUILDING_WORKSHOP_UPGRADING;
    return false, lockInfo;
  end

  return isUnlock, unlockCond;
end

local function Fix_CommonCharSelectDetailDefaultView_Reset(self, arg1)
  self.m_targetChar = nil
end

function V057Hotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Activity.Act1VAutoChess.Act1VAutoChessChessShopQuickAssistOnlyItemView.VirtualView)
  self:Fix_ex(CS.Torappu.Activity.Act1VAutoChess.Act1VAutoChessChessShopQuickAssistOnlyItemView.VirtualView, "TryRefreshAssistItemView", function(self, arg1)
    local ok, errorInfo = xpcall(Fix_Act1VAutoChessShopQuickAssist_TryRefreshNormalItemView, debug.traceback, self, arg1)
    if not ok then
      LogError("fix Act1VAutoChessChessShopQuickAssistOnlyItemView virtualView error" .. errorInfo)
    end
  end)
  xlua.private_accessible(CS.Torappu.Activity.Act1VAutoChess.Act1VAutoChessChessShopQuickAssistTitleWithItemView.VirtualView)
  self:Fix_ex(CS.Torappu.Activity.Act1VAutoChess.Act1VAutoChessChessShopQuickAssistTitleWithItemView.VirtualView, "TryRefreshAssistItemView", function(self, arg1)
    local ok, errorInfo = xpcall(Fix_Act1VAutoChessShopQuickAssist_TryRefreshTitleItemView, debug.traceback, self, arg1)
    if not ok then
      LogError("fix Act1VAutoChessChessShopQuickAssistTitleWithItemView virtualView error" .. errorInfo)
    end
  end)
  xlua.private_accessible(CS.Torappu.Activity.Act1Arcade.Act1ArcadeEntryGameEntryItemViewModel)
  self:Fix_ex(CS.Torappu.Activity.Act1Arcade.Act1ArcadeEntryGameEntryItemViewModel, "_GetIsZoneAvail", function(self, actId, zoneId)
    local ok, value, unlockDesc = xpcall(Fix_Act1ArcadeEntryGameEntryItemViewModel_GetIsZoneAvail, debug.traceback, self, actId, zoneId)
    if not ok then
      LogError("fix Act1VAutoChessChessShopQuickAssistTitleWithItemView virtualView error" .. value)
      return self:_GetIsZoneAvail(actId, zoneId)
    end
    return value, unlockDesc
  end)
  xlua.private_accessible(CS.Torappu.Activity.Act1Arcade.Act1ArcadeStageZoneEntryItemView)
  self:Fix_ex(CS.Torappu.Activity.Act1Arcade.Act1ArcadeStageZoneEntryItemView, "OnValueChanged", function(self, property)
    local ok, errorInfo = xpcall(Fix_Act1ArcadeStageZoneEntryItemView_OnValueChanged, debug.traceback, self, property)
      if not ok then
         LogError("fix Act1VAutoChessChessShopQuickAssistTitleWithItemView virtualView error" .. errorInfo)
      end
  end)

  self:Fix_ex(CS.Torappu.RoguelikeDataUtil, "GetChatUnlockStatus", function(currentData)
    local ok, errorInfo = xpcall(GetChatUnlockStatusFix, debug.traceback, currentData)
    if not ok then
      LogError("[RoguelikeDataUtilHotfixer] fix GetChatUnlockStatus error " .. errorInfo);
      return CS.Torappu.RoguelikeDataUtil.GetChatUnlockStatus(currentData);
    end
    return errorInfo;
  end);
  
  xlua.private_accessible(CS.Torappu.UI.Home.HomeCharRotationViewModel)
  self:Fix_ex(CS.Torappu.UI.Home.HomeCharRotationViewModel, "RefreshData", function(self, displayPresetInstId, selectSkinStrategy)
    local ok, errorInfo = xpcall(Fix_HomeCharRotationViewModel_RefreshData, debug.traceback, self, displayPresetInstId, selectSkinStrategy)
    if not ok then
      LogError("fix HomeCharRotationViewModel RefreshData error" .. errorInfo)
    end
  end)
  xlua.private_accessible(CS.Torappu.UI.Home.HomeCharRotationViewModel)
  self:Fix_ex(CS.Torappu.UI.Home.HomeCharRotationViewModel, "LoadData", function(self)
    local ok, errorInfo = xpcall(Fix_HomeCharRotationViewModel_LoadData, debug.traceback, self)
    if not ok then
      LogError("fix HomeCharRotationViewModel LoadData error" .. errorInfo)
    end
  end)
  xlua.private_accessible(CS.Torappu.UI.Home.HomeCharRotationPresetListDialog)
  self:Fix_ex(CS.Torappu.UI.Home.HomeCharRotationPresetListDialog, "EventOnBackBtnClicked", function(self)
    local ok, errorInfo = xpcall(Fix_HomeCharRotationPresetListDialog_EventOnBackBtnClicked, debug.traceback, self)
    if not ok then
      LogError("fix HomeCharRotationPresetListDialog EventOnBackBtnClicked error" .. errorInfo)
    end
  end)

  self:Fix_ex(CS.Torappu.Building.BuildingDataConverter, "LoadWorkshopFormulaUnlockCondition", function(formula)
    local ok, unlock, unlockInfo = xpcall(Fix_BuildingDataConverter_LoadWorkshopFormulaUnlockCondition, debug.traceback, formula)
    if not ok then
      LogError("[BuildingDataConverter] fix LoadWorkshopFormulaUnlockCondition error ");
      return CS.Torappu.Building.BuildingDataConverter.LoadWorkshopFormulaUnlockCondition(formula);
    end
    return unlock, unlockInfo;
  end);

  xlua.private_accessible(CS.Torappu.UI.TemplateCharSelect.Common.CommonCharSelectDetailDefaultViewModel)
  self:Fix_ex(CS.Torappu.UI.TemplateCharSelect.Common.CommonCharSelectDetailDefaultViewModel, "Reset", function(self, arg1)
    local ok, errorInfo = xpcall(Fix_CommonCharSelectDetailDefaultView_Reset, debug.traceback, self, arg1)
    if not ok then
      LogError("fix CommonCharSelectDetailDefaultViewModel Reset error" .. errorInfo)
    end
  end)
  
end

return V057Hotfixer