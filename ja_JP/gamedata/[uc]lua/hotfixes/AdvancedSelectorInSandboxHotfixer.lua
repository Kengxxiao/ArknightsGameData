
local eutil = CS.Torappu.Lua.Util


local AdvancedSelectorInSandboxHotfixer = Class("AdvancedSelectorInSandboxHotfixer", HotfixBase)

local function _OnPostFilter(self, candidates)
    if self._filter == CS.Torappu.Battle.AdvancedSelectorInSandbox.SandboxFilterType.RANDOM_NEAREST and candidates ~= nil then
        local owner = self.owner
        local map = CS.Torappu.Battle.Map.instance
        local route = map.GenerateRuntimeTraceRoute(map, owner.gridPosition, owner.changeableMotionMode)
        for i = candidates.Count - 1, 0, -1 do         
            if not route:CheckReachable(candidates[i].gridPosition) then
                candidates:RemoveAt(i)
            end
        end
    end

    self:OnPostFilter(candidates)
end

function AdvancedSelectorInSandboxHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.AdvancedSelectorInSandbox)
    xlua.private_accessible(CS.Torappu.Battle.BattleController)
    xlua.private_accessible(CS.Torappu.Battle.Route)
    xlua.private_accessible(CS.Torappu.Battle.Map)

    self:Fix_ex(CS.Torappu.Battle.AdvancedSelectorInSandbox, "OnPostFilter",
        function(self, candidates)
            local ok, errorInfo = xpcall(_OnPostFilter, debug.traceback, self, candidates)
            if not ok then
                eutil.LogError("[AdvancedSelectorInSandbox] OnPostFilter fix" .. errorInfo)
            end
        end)
end

function AdvancedSelectorInSandboxHotfixer:OnDispose()
end

return AdvancedSelectorInSandboxHotfixer
