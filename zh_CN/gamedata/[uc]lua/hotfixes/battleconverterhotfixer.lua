-- local BaseHotfixer = require ("Module/Core/BaseHotfixer")
-- local xutil = require('xlua.util')
-- local eutil = CS.Torappu.Lua.Util

---@class BattleConverterHotFixer:HotfixBase
local BattleConverterHotFixer = Class("BattleConverterHotFixer", HotfixBase)

local function _CalcSkillLevel(slot, isAssistChar)
  if isAssistChar then
    return
  end
  local instId = slot.inst.playerInstId
  if instId <= 0 or instId > 100000 then
    return
  end
  local tmplId = slot.tmplId
  if tmplId ~= "char_002_amiya" and tmplId ~= "char_1001_amiya2" then
    return
  end
  local playerChar = CS.Torappu.PlayerData.instance:GetCharInstById("char_002_amiya")
  if playerChar == nil then
    return
  end
  local skills = playerChar:GetSkills(tmplId)
  if skills == nil or skills.Length <= 0 then
    return
  end
  local skillIndex = slot.skillIndex
  if skillIndex < 0 or skillIndex >= skills.Length then
    return
  end
  local skill = skills[skillIndex]
  slot.mainSkillLvl = skill.specializeLevel + playerChar.mainSkillLvl
end

-- _ConvertInternal(slot.inst.characterKey, slot, isToken, isAssistChar, slot.skinId, true /* generateUniqueId */);

local function ConvertToCharacterData(slot, isToken, isAssistChar)
  local ok = xpcall(_CalcSkillLevel, debug.traceback, slot, isAssistChar)
  return CS.Torappu.Battle.BattleDataConverter._ConvertInternal(slot.inst.characterKey, slot, isToken, isAssistChar, slot.skinId, true)
end

function BattleConverterHotFixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.BattleDataConverter)
  self:Fix_ex(CS.Torappu.Battle.BattleDataConverter, "ConvertToCharacterData", ConvertToCharacterData)
end

function BattleConverterHotFixer:OnDispose()
end

return BattleConverterHotFixer