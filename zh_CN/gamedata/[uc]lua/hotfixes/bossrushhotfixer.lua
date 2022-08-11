
local BossRushHotfixer = Class("BossRushHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util
local DataConvertUtil = CS.Torappu.DataConvertUtil
 
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
 
function BossRushHotfixer:OnInit()
    xlua.private_accessible(DataConvertUtil)
 
    self:Fix_ex(DataConvertUtil, "_GenBattleSlotsWithPlayerData", function(squadSlots, playerModel, squad, isAutoBattle)
        local ok, ret = xpcall(_GenBattleSlotsWithPlayerDataFix, debug.traceback, squadSlots, playerModel, squad, isAutoBattle)
        if not ok then
            eutil.LogError("[BossRushHotfixer] fix" .. ret)
            local listType = CS.System.Collections.Generic.List(CS.Torappu.AdvancedCharacterInst)
            return listType()
        end

        return ret
    end)
end
 
function BossRushHotfixer:OnDispose()
end
 
return BossRushHotfixer