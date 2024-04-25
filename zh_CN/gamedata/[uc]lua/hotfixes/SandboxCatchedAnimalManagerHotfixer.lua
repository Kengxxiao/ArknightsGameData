



local SandboxCatchedAnimalManagerHotfixer = Class("SandboxCatchedAnimalManagerHotfixer", HotfixBase)
local lua_hashSet = CS.System.Collections.Generic.HashSet(CS.System.Int32)
local lua_dict_StrInt = CS.System.Collections.Generic.Dictionary(CS.System.String, CS.System.Int32)
              
local function _Fix_OnFenceFinishInNormal(self, character)
  self.m_roomTilesCache:Clear()
  self.m_roomDiff:Clear()
  for row = 0, self.m_mapHeight - 1 do
    for col = 0, self.m_mapWidth - 1 do
      if self:_IsFenceTile(row, col) then
        self.m_roomTilesCache[self:_CatchedAnimalRoomId(row, col)] = self.m_catchedAnimalFlagMap:GetValue(row, col)
      end
    end
  end

  local tile = character.rootTile;
  self.m_catchedAnimalFlagMap:SetValue(CS.XLua.Cast.Int32(0), tile.row, tile.col)
  self:_RefreshCatchAnimalMap()
  self:_RefreshCatchAnimalMapStatus()
  self:_RefreshTrapFenceAnimatorSurround(tile.row, tile.col)

  if self.output.catchedAnimals == nil or self.output.catchedAnimals.Count == 0 then
    return
  end

  for row = 0, self.m_mapHeight - 1 do
    for col = 0, self.m_mapWidth - 1 do
      local tileId = self:_CatchedAnimalRoomId(row, col)
      if self.m_roomTilesCache:ContainsKey(tileId) and self:_IsFenceTile(row, col) then
        local oldRoomId = self.m_roomTilesCache[tileId]
        local newRoomId = self.m_catchedAnimalFlagMap:GetValue(row, col)
        if self.m_roomDiff:ContainsKey(oldRoomId) then
          self.m_roomDiff[oldRoomId]:Add(newRoomId);
        else
          local roomDiff = lua_hashSet()
          roomDiff:Add(newRoomId)
          self.m_roomDiff:Add(oldRoomId, roomDiff)
        end
      end
    end
  end

  self.m_catchedAnimalCache:Clear();
  for k, v in pairs(self.output.catchedAnimals) do
    self.m_catchedAnimalCache:Add(k, v)
  end
  self.output.catchedAnimals:Clear();
  self.m_animalCountInRoom:Clear()

  for animalCacheKey, _animalCacheValue in pairs(self.m_catchedAnimalCache) do
    local animalCacheValue = {}
    for k, v in pairs(_animalCacheValue) do
      animalCacheValue[k] = v
    end

    if self.m_roomDiff:ContainsKey(animalCacheKey) then
      local newRoomIds = self.m_roomDiff[animalCacheKey]
      for k, v in pairs(newRoomIds) do
        local newRoomId = v
        local roomAnimalCountTmp = {}
        for animalCacheValue_k, animalCacheValue_v in pairs(animalCacheValue) do
          roomAnimalCountTmp[animalCacheValue_k] = animalCacheValue_v
        end

        for roomAnimalCountTmp_k, roomAnimalCountTmp_v in pairs(roomAnimalCountTmp) do
          if roomAnimalCountTmp_v > 0 then
            local addCount = self:_RegisterAnimalInRoom(newRoomId, roomAnimalCountTmp_v)
            if addCount <= 0 then
              break
            end

            if self.output.catchedAnimals:ContainsKey(newRoomId) then
              if self.output.catchedAnimals[newRoomId]:ContainsKey(roomAnimalCountTmp_k) then
                local newCount = self.output.catchedAnimals[newRoomId][roomAnimalCountTmp_k] + addCount
                self.output.catchedAnimals[newRoomId][roomAnimalCountTmp_k] = newCount
              else
                self.output.catchedAnimals[newRoomId]:Add(roomAnimalCountTmp_k, addCount)
              end
            else
              local catchAnimalNew = lua_dict_StrInt()
              catchAnimalNew:Add(roomAnimalCountTmp_k, addCount)
              self.output.catchedAnimals:Add(newRoomId, catchAnimalNew)
            end

            local restCount = roomAnimalCountTmp_v - addCount;
            animalCacheValue[roomAnimalCountTmp_k] = restCount
            if restCount > 0 then
              break
            end
          end
        end
      end
    end
  end
end

function SandboxCatchedAnimalManagerHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.Sandbox.SandboxCatchedAnimalManager)
  self:Fix_ex(CS.Torappu.Battle.Sandbox.SandboxCatchedAnimalManager, "_OnFenceFinishInNormal", function(self, character)
    local ok, ret = xpcall(_Fix_OnFenceFinishInNormal, debug.traceback, self, character)
    if not ok then
      LogError("[Hotfix] failed to _Fix_OnFenceFinishInNormal : " .. ret)
      return self:_OnFenceFinishInNormal(character)
    else
      return ret
    end
  end)
end

return SandboxCatchedAnimalManagerHotfixer
