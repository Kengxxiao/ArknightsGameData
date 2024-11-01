local V056RoguelikeBattleHotfixer = Class("V056RoguelikeBattleHotfixer", HotfixBase)

local function Fix_ApplyFinalAttributes(self, attributes)
  self:_ApplyFinalAttributes(attributes)
  local maxHpField = CS.Torappu.AttributesData.fieldMetas[0].field
  local minValue = math.max(CS.Torappu.AttributesData.ReadAttributesField(maxHpField:GetValue(attributes)), 1)
  CS.Torappu.AttributesData.WriteAttributesField(maxHpField, attributes, minValue)  
end

function V056RoguelikeBattleHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.Roguelike.RoguelikeBattleManager)
  self:Fix_ex(CS.Torappu.Battle.Roguelike.RoguelikeBattleManager, "_ApplyFinalAttributes", function(self, attributes)
    local ok, result = xpcall(Fix_ApplyFinalAttributes, debug.traceback, self, attributes)
    if not ok then
      LogError("[V056RoguelikeBattleHotfixer] fix" .. result)
    else
      return result;
    end
  end)
end

function V056RoguelikeBattleHotfixer:OnDispose()
end

return V056RoguelikeBattleHotfixer