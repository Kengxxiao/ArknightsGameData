local ScatteredProjectileHitBehaviourHotfixer = Class("ScatteredProjectileHitBehaviourHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

local function Fix_Init(self, start, target, projectile)
    if projectile ~= nil and projectile.source ~= nil then
        self:Init(start, target, projectile)
    else
        base(self):Init(start, target, projectile)
    end
end

function ScatteredProjectileHitBehaviourHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.Projectiles.ScatteredProjectileHitBehaviour)

    self:Fix_ex(CS.Torappu.Battle.Projectiles.ScatteredProjectileHitBehaviour, "Init",
        function(self, start, target, projectile)
            local ok, errorInfo = xpcall(Fix_Init, debug.traceback, self, start, target, projectile)
            if not ok then
                eutil.LogError("[ScatteredProjectileHitBehaviourHotfixer] fix" .. errorInfo)
            end
        end)
end

function ScatteredProjectileHitBehaviourHotfixer:OnDispose()
end

return ScatteredProjectileHitBehaviourHotfixer
