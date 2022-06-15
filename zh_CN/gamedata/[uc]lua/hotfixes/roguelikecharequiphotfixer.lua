
local RoguelikeCharEquipHotfixer = Class("RoguelikeCharEquipHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

local function _LoadUniqEquipFix(self, charData, charQuery, evolvePhase, level,
      favorPoint, potentialRank, playerCharEquipId,  playerCharEquipInfos)
  self:_LoadUniqEquip(charData, charQuery, evolvePhase, level,
      favorPoint, potentialRank, playerCharEquipId,  playerCharEquipInfos)
  local countN = self.branchGroup.branchModels.Length
  for i = 0,countN -1 do
    local equipModel = self.branchGroup.branchModels[i]
    if (equipModel.equipLevel == 0) then
      equipModel.isAvailable = false
    end
  end
end

function RoguelikeCharEquipHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.Roguelike.RoguelikeCharCardViewModel)

  self:Fix_ex(CS.Torappu.UI.Roguelike.RoguelikeCharCardViewModel, "_LoadUniqEquip", function(self, charData, charQuery, evolvePhase, level,
      favorPoint, potentialRank, playerCharEquipId,  playerCharEquipInfos)
    local ok, errorInfo = xpcall(_LoadUniqEquipFix, debug.traceback, self, charData, charQuery, evolvePhase, level,
      favorPoint, potentialRank, playerCharEquipId,  playerCharEquipInfos)
    if not ok then
      eutil.LogError("[RoguelikeCharEquipHotfixer] fix" .. errorInfo)
    end
  end)
end

function RoguelikeCharEquipHotfixer:OnDispose()
end

return RoguelikeCharEquipHotfixer