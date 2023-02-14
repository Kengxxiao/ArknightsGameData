
local eutil = CS.Torappu.Lua.Util


local SandboxGameModeHotfixer = Class("SandboxGameModeHotfixer", HotfixBase)

local function _RecordPlacedItemState(self, targetKey, newStatus)
  local tile = CS.Torappu.Battle.Map.instance.GetTile(CS.Torappu.Battle.Map.instance, targetKey.position)
  if tile ~= nil then
    local character = tile:GetCharacter()
    if character ~= nil then
      newStatus.statusHpRatio = character.hpRatio:AsFloat()
    end
  end

  self:RecordPlacedItemState(targetKey, newStatus)
end

local function _PreprocessPlayerDeckList(self, deckList)
  self:PreprocessPlayerDeckList(deckList)

  for index = self.m_sandboxFactoryTrapList.Count - 1, 0, -1 do
    if self.m_sandboxFactoryTrapList[index].remainingCnt <= 0 then
      self.m_sandboxFactoryTrapList:RemoveAt(index);
    end
  end
end

function SandboxGameModeHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.GameMode.GameModeFactory.DefaultGameMode)
  xlua.private_accessible(CS.Torappu.Battle.GameMode.GameModeFactory.SandboxGameMode)
  xlua.private_accessible(CS.Torappu.Battle.Map)

  self:Fix_ex(CS.Torappu.Battle.GameMode.GameModeFactory.SandboxGameMode, "RecordPlacedItemState",
    function(self, targetKey, newStatus)
      local ok, errorInfo = xpcall(_RecordPlacedItemState, debug.traceback, self, targetKey, newStatus)
      if not ok then
        eutil.LogError("[SandboxGameMode] RecordPlacedItemState fix" .. errorInfo)
      end
    end
  )

  self:Fix_ex(CS.Torappu.Battle.GameMode.GameModeFactory.SandboxGameMode, "PreprocessPlayerDeckList",
    function(self, deckList)
      local ok, errorInfo = xpcall(_PreprocessPlayerDeckList, debug.traceback, self, deckList)
      if not ok then
        eutil.LogError("[SandboxGameMode] PreprocessPlayerDeckList fix" .. errorInfo)
      end
    end
  )
end

function SandboxGameModeHotfixer:OnDispose()
end

return SandboxGameModeHotfixer
