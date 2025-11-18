local AutoChessDragStateHotfixer = Class("AutoChessDragStateHotfixer", HotfixBase)

local function _RevertBattleOverlapFix(self, currentCharacter)
  if currentCharacter == nil then
    return
  end
  self:_RevertBattleOverlap(currentCharacter)
end

function AutoChessDragStateHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.UI.UIStateNode)
    xlua.private_accessible(CS.Torappu.Battle.UI.AutoChessDragState)

    self:Fix_ex(CS.Torappu.Battle.UI.AutoChessDragState, "_RevertBattleOverlap", function(self, currentCharacter)
        local ok, ret = xpcall(_RevertBattleOverlapFix, debug.traceback, self, currentCharacter)
        if not ok then
            LogError("[AutoChessDragStateHotfixer] fix" .. ret)
        end
    end)
end

function AutoChessDragStateHotfixer:OnDispose()
end

return AutoChessDragStateHotfixer