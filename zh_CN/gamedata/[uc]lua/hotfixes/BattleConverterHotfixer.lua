
local eutil = CS.Torappu.Lua.Util


local BattleConverterHotfixer = Class("BattleConverterHotfixer", HotfixBase)


local function _ConvertToCharacterData(slot, isToken, isAssistChar, playerSide)
  local slotType = slot:GetType();
  local type = typeof(CS.Torappu.LevelData.PredefinedData.PredefinedCharacter);

  if slotType == type then
    if not CS.Torappu.Battle.BattleController.hasInstance
        or CS.Torappu.Battle.BattleController.instance.levelId == nil
        or CS.Torappu.Battle.BattleController.instance.levelId == "" then
      CS.Torappu.Battle.BattleDataConverter.s_uniqueId = CS.Torappu.Battle.BattleDataConverter.s_uniqueId - 1;
    end
  end
  return CS.Torappu.Battle.BattleDataConverter.ConvertToCharacterData(slot, isToken, isAssistChar, playerSide)
end

function BattleConverterHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.BattleDataConverter)
  self:Fix_ex(CS.Torappu.Battle.BattleDataConverter, "ConvertToCharacterData", function(slot, isToken, isAssistChar, playerSide)
    return _ConvertToCharacterData(slot, isToken, isAssistChar, playerSide)
  end)
end

function BattleConverterHotfixer:OnDispose()
end

return BattleConverterHotfixer