
local RemovableSharedRandomTileGlobalBuffHotfixer = Class("RemovableSharedRandomTileGlobalBuffHotfixer", HotfixBase)

local function _TryRemoveBindingTiles(self, tiles)
  if tiles == nil then
    return false
  end
  local hasNew = false
  local tilesCount = tiles.Count
  local luaCreateCnt = CS.Torappu.Battle.RemovableSharedRandomTileGlobalBuff.createCnt
  local luaS_targetTiles = CS.Torappu.Battle.RemovableSharedRandomTileGlobalBuff.s_targetTiles
  local luaEffectHolder = CS.Torappu.Battle.RemovableSharedRandomTileGlobalBuff.effectHolder
  for i = 0, tilesCount - 1 do
    local tile = tiles[i]
    if tile ~= nil then
      if self:FilterTile(tile) then
        flag, cnt = luaCreateCnt:TryGetValue(tile.gridPosition)
        if flag and cnt > 0 then
          luaCreateCnt[tile.gridPosition] = cnt - 1
          if cnt - 1 <= 0 then
            luaS_targetTiles:Remove(tile.gridPosition)
            self.targetTiles:Remove(tile.gridPosition)
            local character = tile:GetCharacter()
            if character ~= nil then
              self:TryRemoveBuff(character, false)
            end
            if not string.isNullOrEmpty(self.tileEffect) then
              hasEffect, curTileEffect = luaEffectHolder:TryGetValue(tile)
              if hasEffect and curTileEffect ~= nil then
                curTileEffect:FinishMe(true)
                luaEffectHolder:Remove(tile)
              end
            end
            hasNew = true
          end
        end
      end
    end
  end
  return hasNew
end

function RemovableSharedRandomTileGlobalBuffHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.RemovableSharedRandomTileGlobalBuff)
  self:Fix_ex(CS.Torappu.Battle.RemovableSharedRandomTileGlobalBuff, "TryRemoveBindingTiles", function(self, tiles)
    local ok, errorInfo = xpcall(_TryRemoveBindingTiles, debug.traceback, self, tiles)
    if not ok then
      LogError("[RemovableSharedRandomTileGlobalBuffHotfixer] fix" .. errorInfo)
    end
  end)     
end

function RemovableSharedRandomTileGlobalBuffHotfixer:OnDispose()
end

return RemovableSharedRandomTileGlobalBuffHotfixer;