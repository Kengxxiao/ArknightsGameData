local BuffTileHotfixer = Class("BuffTileHotfixer", HotfixBase)

local function _ApplyBuffs(self, target, buffUids)
  if (not target.alive) then
    if (typeof(CS.Torappu.Battle.Enemy):IsInstanceOfType(target)) then
      return
    end
  end
  self:ApplyBuffs(target, buffUids)
end

function BuffTileHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.BuffTile)

    self:Fix_ex(CS.Torappu.Battle.BuffTile, "ApplyBuffs", function(self, target, buffUids)
        local ok, ret = xpcall(_ApplyBuffs, debug.traceback, self, target, buffUids)
        if not ok then
            LogError("[BuffTileHotfixer] fix" .. ret)
        end
    end)
end

function BuffTileHotfixer:OnDispose()
end

return BuffTileHotfixer