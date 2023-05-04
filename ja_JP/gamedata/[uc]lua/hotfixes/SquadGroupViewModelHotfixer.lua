local SquadGroupViewModelHotfixer = Class("SquadGroupViewModelHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

local function LoadDataOverrideSkillSelectable(self)
  self:LoadDataOverrideSkillSelectable()
  local squads = self.squads;
  
  if squads ~= nil and squads.Length ~= 0 then
    local squad = squads[0]
    if squad ~= nil then
      local members = squad.members
      local maxSkillLvl = CS.Torappu.CharacterConst.SKILL_MAX_LVL
      for memberIndex = 0, members.Length - 1 do
        local member = members[memberIndex]
        if member ~= nil and member.cardModel ~= nil then
          local skills = member.cardModel.skills
          local mainSkillLvl = member.cardModel.mainSkillLvl
          local specSkillLvl = 0
          if mainSkillLvl > maxSkillLvl then
            specSkillLvl = mainSkillLvl - maxSkillLvl
          end
          
          member.cardModel.mainSkillLvl = mainSkillLvl - specSkillLvl
          
          for skillIndex = 0, skills.Length - 1 do
            skills[skillIndex].specializeLevel = specSkillLvl
          end
        end
      end
    end
  end
end

function SquadGroupViewModelHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.Squad.SquadGroupViewModel)
  self:Fix_ex(CS.Torappu.UI.Squad.SquadGroupViewModel, "LoadDataOverrideSkillSelectable",function(self)
    local ok, errorInfo = xpcall(LoadDataOverrideSkillSelectable, debug.traceback, self)
    if not ok then
        CS.UnityEngine.DLog.LogError(errorInfo)
    end
  end)
end

function SquadGroupViewModelHotfixer:OnDispose()
end

return SquadGroupViewModelHotfixer