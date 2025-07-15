

local BattleDataConverterHotfixer = Class("BattleDataConverterHotfixer", HotfixBase)

local function _FixConverterInternal(characterKey, slot, isToken, isAssistChar, skinId, generateUniqueId, playerSide)
  local battleChar = CS.Torappu.Battle.BattleDataConverter._ConvertInternal(characterKey, slot, isToken, isAssistChar, skinId, generateUniqueId, playerSide)
  local charQuery = CS.Torappu.CharQuery()
  charQuery.charId = characterKey
  charQuery.isToken = isToken
  charQuery.tmplId = slot.tmplId

  local success, data = CS.Torappu.CharacterUtil.TryGetCharData(charQuery)
  if not success then
    return battleChar
  end

  if (data.talents == nil or data.talents.Count == 0) and battleChar.uniEquips ~= nil and battleChar.uniEquips.Count ~= 0  then
    local equipTargets = CS.System.Collections.Generic.List(CS.Torappu.UniEquipTarget)()
    local equipTalents = CS.System.Collections.Generic.List(CS.Torappu.TalentData)()
    for i = 0, battleChar.uniEquips.Count - 1 do
      local equip = battleChar.uniEquips[i]
      CS.Torappu.Battle.UniEquip.UniEquipUtil.AddEquipTalentData(battleChar, equip, slot.inst.level, slot.inst.phase, slot.inst.potentialRank, equipTargets, equipTalents)
    end

    battleChar.talents:AddRange(equipTalents)
  end

  return battleChar
end


function BattleDataConverterHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.BattleDataConverter)
  self:Fix_ex(CS.Torappu.Battle.BattleDataConverter, "_ConvertInternal", function(characterKey, slot, isToken, isAssistChar, skinId, generateUniqueId, playerSide)
    local ok, result = xpcall(_FixConverterInternal, debug.traceback, characterKey, slot, isToken, isAssistChar, skinId, generateUniqueId, playerSide)
    if not ok then
      LogError("[BattleDataConverter._ConvertInternal] error : " .. tostring(result))
      return CS.Torappu.Battle.BattleDataConverter._ConvertInternal(characterKey, slot, isToken, isAssistChar, skinId, generateUniqueId, playerSide)
    end
    return result
  end)
end

function BattleDataConverterHotfixer:OnDispose()
end

return BattleDataConverterHotfixer