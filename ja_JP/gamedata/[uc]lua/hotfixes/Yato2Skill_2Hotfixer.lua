local Yato2Skill_2Hotfixer = Class("Yato2Skill_2Hotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

local function OnTickFix(self, deltaTime)
    if not self.projectile.isValid then
        return;
    end
    self:OnTick(deltaTime)
end

function Yato2Skill_2Hotfixer:OnInit()
    self:Fix_ex(CS.Torappu.Battle.Projectiles.Yato2S2Behaviour, "OnTick",
        function(self, deltaTime)
            local ok, errorInfo = xpcall(OnTickFix, debug.traceback, self, deltaTime)
            if not ok then
                eutil.LogError("[Yato2Skill_2Hotfixer] fix" .. errorInfo)
            end
        end)
end

function Yato2Skill_2Hotfixer:OnDispose()
end

return Yato2Skill_2Hotfixer
