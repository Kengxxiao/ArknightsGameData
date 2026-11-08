

local AutoChessLevelEnemyManagerHotfixer = Class("AutoChessLevelEnemyManagerHotfixer", HotfixBase)

local AutoChessLevelEnemyManager = CS.Torappu.Battle.AutoChess.AutoChessLevelEnemyManager
local AutoChessGameManager = CS.Torappu.Battle.AutoChess.AutoChessGameManager
local MapLayer = CS.Torappu.MapLayer

function AutoChessLevelEnemyManagerHotfixer:OnInit()
  
  xlua.private_accessible(AutoChessLevelEnemyManager)
  
  self:Fix_ex(AutoChessLevelEnemyManager, "_GetMapLayerByGroup", function(self, playerGroup)
    local gameManager = AutoChessGameManager.instanceOrNull
    if gameManager ~= nil and not gameManager.enableViewMultiBattle then
      return MapLayer.LAYER_A
    end
    return self:_GetMapLayerByGroup(playerGroup)
  end)
end

return AutoChessLevelEnemyManagerHotfixer
