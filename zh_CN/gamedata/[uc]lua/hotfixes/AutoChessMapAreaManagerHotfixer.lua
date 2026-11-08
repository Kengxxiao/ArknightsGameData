

local AutoChessMapAreaManagerHotfixer = Class("AutoChessMapAreaManagerHotfixer", HotfixBase)

local AutoChessMapAreaManager = CS.Torappu.Battle.AutoChess.AutoChessMapAreaManager
local AutoChessGameStatus = CS.Torappu.Battle.AutoChess.AutoChessGameStatus
local MapAreaType = CS.Torappu.Battle.AutoChess.MapAreaType
local MapLayer = CS.Torappu.MapLayer
local Map = CS.Torappu.Battle.Map



local HAND_AREA_LAYERS = {
  { MapAreaType.CHAR_HAND_0, MapLayer.LAYER_A },
  { MapAreaType.EQUIP_HAND_0, MapLayer.LAYER_A },
  { MapAreaType.CHAR_HAND_1, MapLayer.LAYER_B },
  { MapAreaType.EQUIP_HAND_1, MapLayer.LAYER_B },
  { MapAreaType.CHAR_HAND_2, MapLayer.LAYER_C },
  { MapAreaType.EQUIP_HAND_2, MapLayer.LAYER_C },
  { MapAreaType.CHAR_HAND_3, MapLayer.LAYER_D },
  { MapAreaType.EQUIP_HAND_3, MapLayer.LAYER_D },
}

local function _GetHandAreaLayer(areaType)
  for i = 1, #HAND_AREA_LAYERS do
    local pair = HAND_AREA_LAYERS[i]
    if pair[1] == areaType then
      return pair[2]
    end
  end
  return nil
end

local function _PatchHandTileLayers(self)
  local gameStatus = AutoChessGameStatus.instanceOrNull
  if gameStatus == nil or not gameStatus.inBattleState then
    return
  end
  local map = Map.instance
  if map == nil then
    return
  end

  local defaultGrids = self:_EnsureValidMapGrids(MapLayer.DEFAULT)
  for i = 0, map.height - 1 do
    for j = 0, map.width - 1 do
      
      
      local tile = map:GetTile(i, j)
      if tile ~= nil then
        local gridPosition = tile.gridPosition
        local layer = _GetHandAreaLayer(self:GetMapAreaType(gridPosition, false ))
        if layer ~= nil then
          tile:SetMapLayer(layer)
          
          
          if defaultGrids:Remove(gridPosition) then
            self:_EnsureValidMapGrids(layer):Add(gridPosition)
          end
        end
      end
    end
  end
end



local function _AliasBossRightAreaPlayer(self)
  local area2Player = self.m_battleArea2PlayerIndex
  if not area2Player:ContainsKey(MapAreaType.BATTLE_BOSS_RIGHT_1) and area2Player:ContainsKey(MapAreaType.BATTLE_BOSS_LEFT_1) then
    area2Player[MapAreaType.BATTLE_BOSS_RIGHT_1] = area2Player[MapAreaType.BATTLE_BOSS_LEFT_1]
  end
end

function AutoChessMapAreaManagerHotfixer:OnInit()
  
  xlua.private_accessible(AutoChessMapAreaManager)
  self:Fix_ex(AutoChessMapAreaManager, "UpdateMapTiles", function(self)
    self:UpdateMapTiles()
    _PatchHandTileLayers(self)
  end)
  self:Fix_ex(AutoChessMapAreaManager, "_ResetPlayerIndexerInBossBattle", function(self, enableViewMultiBattle)
    self:_ResetPlayerIndexerInBossBattle(enableViewMultiBattle)
    _AliasBossRightAreaPlayer(self)
  end)
end

return AutoChessMapAreaManagerHotfixer
