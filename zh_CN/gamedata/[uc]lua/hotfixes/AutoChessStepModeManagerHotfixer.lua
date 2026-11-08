

local AutoChessStepModeManagerHotfixer = Class("AutoChessStepModeManagerHotfixer", HotfixBase)

local AutoChessStepModeManager = CS.Torappu.Battle.AutoChess.AutoChessStepModeManager
local AutoChessBattleUtil = CS.Torappu.Battle.AutoChess.AutoChessBattleUtil
local BossBattleEnemyInfo = CS.Torappu.Battle.AutoChess.BossBattleEnemyInfo
local BossPlayerGroup = CS.Torappu.BossPlayerGroup


local function _ShouldIgnoreOtherGroup(self, playerGroup)
  local gameManager = self.gameManager
  if gameManager ~= nil and gameManager.enableViewMultiBattle then
    return false
  end
  return playerGroup ~= self.m_playerGroup
end


local function _GetOrCreateSummonedEnemyInfo(self, enemyInst)
  local enemyInfos = self.m_enemyInfos
  local found, info = enemyInfos:TryGetValue(enemyInst)
  if found then
    return info
  end

  local enemyIdentifier = enemyInst >> 16
  local enemyId = AutoChessBattleUtil.indexer:GetSummonedEnemyIdByIdentifier(enemyIdentifier)
  if enemyId == nil or enemyId == "" then
    
    return nil
  end

  info = BossBattleEnemyInfo()
  info.enemyId = enemyId
  info.instId = enemyInst
  info.actionIndex = -1
  enemyInfos:Add(enemyInst, info)
  return info
end

function AutoChessStepModeManagerHotfixer:OnInit()
  
  xlua.private_accessible(AutoChessStepModeManager)

  
  
  self:Fix_ex(AutoChessStepModeManager, "_OnNewSummonedEnemyReachExit", function(self, enemy)
    local actions = self.m_cachedActions
    local countBefore = actions.Count
    self:_OnNewSummonedEnemyReachExit(enemy)
    if actions.Count == countBefore + 1 then
      actions[actions.Count - 1].paramList[1] = 0
    end
  end)

  self:Fix_ex(AutoChessStepModeManager, "_ApplyEnemyAppear", function(self, paramList)
    if paramList ~= nil and paramList.Count >= 3 then
      local enemyInst = paramList[0]
      local playerGroup = paramList[2]
      if _ShouldIgnoreOtherGroup(self, playerGroup) then
        return
      end
      local found, info = self.m_enemyInfos:TryGetValue(enemyInst)
      if found then
        info.playerGroup = BossPlayerGroup.__CastFrom(playerGroup)
      end
    end
    self:_ApplyEnemyAppear(paramList)
  end)

  self:Fix_ex(AutoChessStepModeManager, "_ApplySummonedEnemyAppear", function(self, paramList)
    if paramList ~= nil and paramList.Count >= 3 then
      local enemyInst = paramList[0]
      local escapedCount = paramList[1]
      local playerGroup = paramList[2]
      if _ShouldIgnoreOtherGroup(self, playerGroup) then
        return
      end
      
      self.m_enemyEscapeCountDict[enemyInst] = escapedCount
      local info = _GetOrCreateSummonedEnemyInfo(self, enemyInst)
      if info ~= nil then
        info.playerGroup = BossPlayerGroup.__CastFrom(playerGroup)
      end
    end
    self:_ApplySummonedEnemyAppear(paramList)
  end)
end

return AutoChessStepModeManagerHotfixer
