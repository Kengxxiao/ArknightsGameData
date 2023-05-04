local eutil = CS.Torappu.Lua.Util


local CrisisBattleFinishHotfixer = Class("CrisisBattleFinishHotfixer", HotfixBase)

local function _LoadSquadData(self)
  self.squadList = CS.Torappu.Battle.BattleInOut.instance.input.squadLocalData;

  local friendSquad = CS.Torappu.Battle.BattleInOut.instance.input.friendData;
  if friendSquad ~= nil then
    local skillIndex = friendSquad.assistChar.skillIndex;
    local skills = friendSquad.assistChar.skills;
    local skillId = "";
    if skills ~= nil then
      if (skillIndex >= 0 and skillIndex < skills.Length) then
        skillId = skills[skillIndex].skillId;
      end
    end

    local charModel = CS.Torappu.UI.CharacterUtil.ConvertToCharacterCardViewModel(friendSquad.assistChar);
    self.assistSquad = CS.Torappu.UI.Squad.SquadItemStruct(skillId, charModel);
  end
end

function CrisisBattleFinishHotfixer:OnInit()
  self:Fix_ex(CS.Torappu.UI.Crisis.CrisisBattleFinishViewModel, "_LoadSquadData", function(self)
    local ok, error = xpcall(_LoadSquadData, debug.traceback, self);
    if not ok then
      eutil.LogError("[CrisisBattleFinishHotfixer] fix load squad data error:" .. error);
      self:_LoadSquadData();
    end
  end)
end

function CrisisBattleFinishHotfixer:OnDispose()
end

return CrisisBattleFinishHotfixer