local AutoChessShopHotfixer = Class("AutoChessShopHotfixer", HotfixBase)

local function CheckData(self, forChess, shopChessData, playerData, alreadyAdd, unused)
  local found, slot = playerData.chessSquad:TryGetValue(shopChessData.chessId)
  if (shopChessData.chessLevel ~= forChess.chessLevel or not found) then
    return
  end
  local chessType = shopChessData.chessType
  local backupCharId = shopChessData.backupCharId
  if (chessType ~= CS.Torappu.AutoChessChessType.NORMAL or CS.System.String.IsNullOrEmpty(backupCharId)) then
    return
  end
  if (slot.type == CS.Torappu.PlayerActivity.PlayerActAutoChessActivity.AutoChessCharType.BACK_UP) then
    alreadyAdd:Add(backupCharId)
    unused:Remove(backupCharId)
    return
  end
  if (alreadyAdd:Contains(backupCharId)) then
    return
  end
  unused:TryAdd(backupCharId, shopChessData)
end

local function _AddUnusedBackupCharFix(self, actId, forChess, alreadyAdd)
  if self.m_actData == nil then
    return
  end

  local playerData = CS.Torappu.UI.AutoChess.AutoChessUtil.GetActAutoChessPlayerData(self.m_cacheInput.actId);
  if playerData == nil then
    return
  end

  local dict_creator = CS.System.Collections.Generic.Dictionary(CS.System.String, CS.Torappu.ActAutoChessData.ActAutoChessCharShopChessData)
  local unused = dict_creator()

  for k, shopChessData in pairs(self.m_actData.charShopChessDatas) do
    CheckData(self, forChess, shopChessData, playerData, alreadyAdd, unused)
  end

  for k, shopChessData in pairs(unused) do
    local charModel = self:_CreateBackupChar(actId, self:_AllocInstId(), forChess, shopChessData, nil)
    charModel.selected = false
    charModel.selectIndex = -1
    self:_AddToCharCollection(charModel, true)
  end
end

local function _ClearBattleSceneDataFix(self)
  self:Reset()
  self.battleSceneData = CS.Torappu.UI.AutoChess.AutoChessBattleSceneData()
end

function AutoChessShopHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.UI.AutoChess.CharSelect.AutoChessCharSelectPoolViewModel)

    self:Fix_ex(CS.Torappu.UI.AutoChess.CharSelect.AutoChessCharSelectPoolViewModel, "_AddUnusedBackupChar", function(self, actId, forChess, alreadyAdd)
        local ok, ret = xpcall(_AddUnusedBackupCharFix, debug.traceback, self, actId, forChess, alreadyAdd)
        if not ok then
            LogError("[AutoChessDragStateHotfixer] fix" .. ret)
        end
    end)

    self:Fix_ex(CS.Torappu.UI.AutoChess.Server.AutoChessServiceBattleInfo, "Reset", function(self)
        local ok, ret = xpcall(_ClearBattleSceneDataFix, debug.traceback, self)
        if not ok then
            LogError("[AutoChessShopHotfixer] fix" .. ret)
        end
    end)
end

function AutoChessShopHotfixer:OnDispose()
end

return AutoChessShopHotfixer