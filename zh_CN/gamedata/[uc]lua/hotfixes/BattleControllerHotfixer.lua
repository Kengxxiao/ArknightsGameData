
local BattleControllerHotfixer = Class("BattleControllerHotfixer", HotfixBase)

local function _OnDestroy(self)
  if self.isCooperateMode then
    CS.Torappu.Battle.BuffDB.instance.m_buffTemplates = nil
  end

  self:OnDestroy()
end

function BattleControllerHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.BattleController)
  xlua.private_accessible(CS.Torappu.Battle.BuffDB)
  self:Fix_ex(CS.Torappu.Battle.BattleController, "OnDestroy", function(self)
    local ok, result = xpcall(_OnDestroy, debug.traceback, self)
    if not ok then
      LogError("[BattleControllerHotfixer] fix" .. result)
    end
  end)
end

function BattleControllerHotfixer:OnDispose()
end

return BattleControllerHotfixer
