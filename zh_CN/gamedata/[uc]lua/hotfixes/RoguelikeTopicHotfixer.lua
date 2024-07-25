
local RoguelikeTopicHotfixer = Class("RoguelikeTopicHotfixer", HotfixBase)


local function _RenderInitSquadWithDifficultyFix(self, viewModel)
  repeat
    if viewModel == nil or viewModel.initialRelic == nil or viewModel.initialRelic.topicId == nil then
      break;
    end
    local topicId = viewModel.initialRelic.topicId;
    if topicId ~= "rogue_4" then
      break;
    end

    local finder = CS.Torappu.UI.UIPageFinder();
    if finder == nil then
      LogError("[RoguelikeTopicHotfixer] fix _RenderInitSquadWithDifficulty error: cannot get page finder.");
      break;
    end
    local pageInterface = finder:Current(self);
    if pageInterface == nil then
      LogError("[RoguelikeTopicHotfixer] fix _RenderInitSquadWithDifficulty error: cannot find interface.");
      break;
    end
    
    local page = pageInterface:GetAssetLoader();
    if page == nil then
      LogError("[RoguelikeTopicHotfixer] fix _RenderInitSquadWithDifficulty error: cannot get assetloader.");
      break;
    end
    local atlasObject = page:LoadAsset(CS.Torappu.ResourceUrls.GetRL04DifficultyIconAtlasPath(topicId));
    if atlasObject == nil then
      LogError("[RoguelikeTopicHotfixer] fix _RenderInitSquadWithDifficulty error: cannot find atlas object.");
      break;
    end
    if atlasObject:GetType() ~= typeof(CS.Torappu.UI.UIAtlasObject) then
      LogError("[RoguelikeTopicHotfixer] fix _RenderInitSquadWithDifficulty error: atlas object type error.");
      break;
    end

    self._difficultyAtlasObject = atlasObject;
  until(true);

  self:_RenderInitSquadWithDifficulty(viewModel);
end

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

function RoguelikeTopicHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.Roguelike.RoguelikeMenuInitSquadWithDifficultyObject);
  self:Fix_ex(CS.Torappu.UI.Roguelike.RoguelikeMenuInitSquadWithDifficultyObject, "_RenderInitSquadWithDifficulty", function(self, viewModel)
    local ok, errorInfo = xpcall(_RenderInitSquadWithDifficultyFix, debug.traceback, self, viewModel)
    if not ok then
      LogError("[RoguelikeTopicHotfixer] fix _RenderInitSquadWithDifficulty error: " .. errorInfo)
    end
  end)
  xlua.private_accessible(CS.Torappu.Battle.RemovableSharedRandomTileGlobalBuff)
  self:Fix_ex(CS.Torappu.Battle.RemovableSharedRandomTileGlobalBuff, "TryRemoveBindingTiles", function(self, tiles)
    local ok, errorInfo = xpcall(_TryRemoveBindingTiles, debug.traceback, self, tiles)
    if not ok then
      LogError("[RemovableSharedRandomTileGlobalBuffHotfixer] fix" .. errorInfo)
    end
  end)     
end

function RoguelikeTopicHotfixer:OnDispose()
end

return RoguelikeTopicHotfixer;