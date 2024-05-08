local BattleControllerHotfixer = Class("BattleControllerHotfixer", HotfixBase)

local function SetTempLifePoint_Fix(self, value, side)
  if not self.isPlaying then
    return
  end

  local pSide = (side == CS.Torappu.PlayerSide.DEFAULT) and self.playerSide or side

  local temp = self.m_tempLifePointDict[pSide]
  local encrypted = CS.CodeStage.AntiCheat.ObscuredTypes.ObscuredInt.Encrypt(value)
  temp:SetEncrypted(encrypted)
  self.m_tempLifePointDict[pSide] = temp
end

function BattleControllerHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.BattleController)

    self:Fix_ex(CS.Torappu.Battle.BattleController, "SetTempLifePoint", function(self, value, side)
        local ok, errorInfo = xpcall(SetTempLifePoint_Fix, debug.traceback, self, value, side)
        if not ok then
            LogError("[BattleControllerHotfixer] fix" .. errorInfo)
        end
    end)
end

function BattleControllerHotfixer:OnDispose()
end

return BattleControllerHotfixer