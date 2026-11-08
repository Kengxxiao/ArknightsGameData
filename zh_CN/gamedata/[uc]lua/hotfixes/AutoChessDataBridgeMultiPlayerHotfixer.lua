

local AutoChessDataBridgeMultiPlayerHotfixer = Class("AutoChessDataBridgeMultiPlayerHotfixer", HotfixBase)

local AutoChessDataBridgeMultiPlayer = CS.Torappu.Battle.AutoChess.AutoChessDataBridgeMultiPlayer
local AutoChessDataCenter = CS.Torappu.Battle.DataCenter.AutoChessDataCenter
local HelpBattleData = CS.Torappu.Battle.AutoChess.HelpBattleData

function AutoChessDataBridgeMultiPlayerHotfixer:OnInit()
  
  xlua.private_accessible(AutoChessDataBridgeMultiPlayer)
  self:Fix_ex(AutoChessDataBridgeMultiPlayer, "_ReqHelpBattleFinish", function(self, fromRejoin, round)
    local dataCenter = AutoChessDataCenter.instanceOrNull
    if dataCenter ~= nil and dataCenter.helpBattleData == nil then
      
      dataCenter:UpdateData(HelpBattleData())
    end
    self:_ReqHelpBattleFinish(fromRejoin, round)
  end)
end

return AutoChessDataBridgeMultiPlayerHotfixer
