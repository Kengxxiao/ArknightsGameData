local eutil = CS.Torappu.Lua.Util

----@class DataConvertFixer:HotfixBase
local DataConvertFixer = Class("DataConvertFixer", HotfixBase)

local function FixLoadPredefinedSquad(squad)
  if squad ~= nil then
    for i = 0, squad.Count - 1, 1 do 
      local charModel = squad[i]
      if charModel ~= nil then
        local skillId = CS.Torappu.DataConvertUtil.FindCharSkillIdByCharIdIndex(charModel.charId, charModel.defaultSkillIndex)
        charModel:SetSkillInfo(skillId)
      end
    end
  end
end

function DataConvertFixer:OnInit()
  xlua.private_accessible(CS.Torappu.DataConvertUtil)
  self:Fix_ex(CS.Torappu.DataConvertUtil, "_LoadStagePredefinedSquad", function(levelData)
    local squad = CS.Torappu.DataConvertUtil._LoadStagePredefinedSquad(levelData)
    local ok, error = xpcall(FixLoadPredefinedSquad, debug.traceback, squad)
    if not ok then
      eutil.LogError("[DataConvertUtilFix]" .. error)
    end
    return squad
  end)
end

return DataConvertFixer