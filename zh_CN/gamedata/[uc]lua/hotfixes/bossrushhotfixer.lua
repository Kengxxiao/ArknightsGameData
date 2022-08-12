
local BossRushHotfixer = Class("BossRushHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util
local DataConvertUtil = CS.Torappu.DataConvertUtil
local BattleStartController = CS.Torappu.BattleStartController
 
local function _GenBattleSlotsWithPlayerDataFix(squadSlots, playerModel, squad, isAutoBattle)
  local listType = CS.System.Collections.Generic.List(CS.Torappu.AdvancedCharacterInst)
  local battleSlots = listType()

  for i = 0, squadSlots.Length-1 do
    local slot = squadSlots[i]
    if slot.cardModel ~= nil then
      local charInst
      if slot.cardModel.chrInstId > 0 then
        charInst = DataConvertUtil._GenCharInstWithPlayerData(slot, playerModel, squad, isAutoBattle)
      else
        charInst = DataConvertUtil._GenCharInstWithSlotData(slot)
        local cardModel = slot.cardModel
        local targetTmpl = slot.currentTmpl
        local skillIndex = slot:GetSkillIndex(targetTmpl)
        local curSkill = nil
        if cardModel.skills ~= nil and skillIndex >= 0 and skillIndex < cardModel.skills.Length then
          curSkill = cardModel.skills[skillIndex]
        end
        local targetSkillLv = cardModel.mainSkillLvl
        if curSkill ~= nil then
          targetSkillLv = targetSkillLv + curSkill.specializeLevel
        end
        charInst.mainSkillLvl = targetSkillLv
      end

      if charInst ~= nil then
        battleSlots:Add(charInst)
      end
    end
  end
  return battleSlots
end

local function GenPredefinedCardsToInjectFix(levelData)
  if levelData.options.isPredefinedCardsSelectable then
    return nil
  end

  local predefinedData
  local stageId = BattleStartController.m_cache.param.stageId
  if stageId == "act11d0_s02#f#" or stageId == "act11d0_s01#f#" then
    predefinedData = DataConvertUtil.LoadComposeHardPredefine(levelData)
  else
    predefinedData = levelData.predefines
  end

  if predefinedData == nil then
    return nil
  end
  return predefinedData.characterCards
end
 
function BossRushHotfixer:OnInit()
    xlua.private_accessible(DataConvertUtil)
    xlua.private_accessible(BattleStartController)
 
    self:Fix_ex(DataConvertUtil, "_GenBattleSlotsWithPlayerData", function(squadSlots, playerModel, squad, isAutoBattle)
        local ok, ret = xpcall(_GenBattleSlotsWithPlayerDataFix, debug.traceback, squadSlots, playerModel, squad, isAutoBattle)
        if not ok then
            eutil.LogError("[BossRushHotfixer] fix" .. ret)
            local listType = CS.System.Collections.Generic.List(CS.Torappu.AdvancedCharacterInst)
            return listType()
        end

        return ret
    end)

    self:Fix_ex(DataConvertUtil, "GenPredefinedCardsToInject", function(levelData)
      local ok, ret = xpcall(GenPredefinedCardsToInjectFix, debug.traceback, levelData)
      if not ok then
        eutil.LogError("[GenPredefinedCardsToInject] fix" .. ret)
        return nil
      end

      return ret
    end)
end
 
function BossRushHotfixer:OnDispose()
end
 
return BossRushHotfixer