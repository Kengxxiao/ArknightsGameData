-- local BaseHotfixer = require ("Module/Core/BaseHotfixer")
-- local xutil = require('xlua.util')
-- local eutil = CS.Torappu.Lua.Util

---@class SquadHotfixer:HotfixBase
local SquadHotfixer = Class("SquadHotfixer", HotfixBase)

local function _CheckSkillAvalibale(charData, evolveState, level, skillIndex)
  local skills = charData.skills
  if skillIndex < 0 or skillIndex >= skills.Length then
    return false
  end
  return skills[skillIndex].initialUnlockCond:Validate(level, evolveState)
end

function SquadHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.CharacterUtil)
  self:Fix_ex(CS.Torappu.CharacterUtil, "_CheckSkillAvalibale", _CheckSkillAvalibale)
end

function SquadHotfixer:OnDispose()
end

return SquadHotfixer