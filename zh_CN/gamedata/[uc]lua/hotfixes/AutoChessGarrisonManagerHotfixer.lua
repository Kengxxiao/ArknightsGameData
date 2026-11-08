

local AutoChessGarrisonManagerHotfixer = Class("AutoChessGarrisonManagerHotfixer", HotfixBase)

local AutoChessGarrisonManager = CS.Torappu.Battle.AutoChess.AutoChessGarrisonManager
local AutoChessGameStatus = CS.Torappu.Battle.AutoChess.AutoChessGameStatus
local AutoChessBattleUtil = CS.Torappu.Battle.AutoChess.AutoChessBattleUtil

function AutoChessGarrisonManagerHotfixer:OnInit()
  
  xlua.private_accessible(AutoChessGarrisonManager)

  
  self:Fix_ex(AutoChessGarrisonManager, "TriggerGarrisonStatusRefresh", function(self, target, blackboard)
    local gameStatus = AutoChessGameStatus.instanceOrNull
    if gameStatus ~= nil and gameStatus.inEndSubState then
      return
    end
    self:TriggerGarrisonStatusRefresh(target, blackboard)
  end)

  
  
  self:Fix_ex(AutoChessGarrisonManager, "_GetBondIdsSelfAndBehind", function(self, snapShot, names)
    local target = snapShot ~= nil and snapShot.target or nil
    if target == nil then
      return
    end
    if AutoChessBattleUtil.GetChessInstByPos(target.gridPosition) == nil then
      return
    end
    self:_GetBondIdsSelfAndBehind(snapShot, names)
  end)
end

return AutoChessGarrisonManagerHotfixer
