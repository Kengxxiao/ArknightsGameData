local SandboxCatchedAnimalManagerHotfixer = Class("SandboxCatchedAnimalManagerHotfixer", HotfixBase)

local FENCE_AREA_FLAG = -1;

local function DoResetFromCacheFix(self)
  for row = 0, self.m_mapHeight - 1 do
    for col = 0, self.m_mapWidth - 1 do
      local tile = CS.Torappu.Battle.Map.instance:GetTile(row, col)
      if tile ~= nil then
        local character = tile:GetCharacter()
        if character ~= nil and character.rootTile ~= nil and character.rootTile == tile then
          local flagValue
          if self:_IsFenceTileId(character.id) then
            flagValue = FENCE_AREA_FLAG;
          else
            flagValue = 0;
          end
          self.m_catchedAnimalFlagMap:SetValue(CS.XLua.Cast.Int32(flagValue), row, col);
        end
      end
    end
  end

  for i = self.m_catchedAnimals.Count - 1, 0, -1 do
    local enemy = self.m_catchedAnimals:Get(i).Key
    enemy:FinishWithNoReason()
  end
  self.m_catchedAnimals:Clear()
  self.m_catchedAnimalFenceId:Clear()
  self:_ParseCatchedAnimals(self.m_catchedAnimalCache)
  for key, value in pairs(self.m_catchedAnimalCardCount) do
    self:_ForceChargeCatchedAnimalCard(key, value);
  end
end

function SandboxCatchedAnimalManagerHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.Sandbox.SandboxCatchedAnimalManager)
  xlua.private_accessible(CS.Torappu.Battle.Character)
  self:Fix_ex(CS.Torappu.Battle.Sandbox.SandboxCatchedAnimalManager, "DoResetFromCache", function(self)
    local ok, errorInfo = xpcall(DoResetFromCacheFix, debug.traceback, self)
    if not ok then
      LogError("[SandboxCatchedAnimalManagerHotfixer] fix" .. errorInfo)
    end
  end)
end

function SandboxCatchedAnimalManagerHotfixer:OnDispose()
end

return SandboxCatchedAnimalManagerHotfixer
