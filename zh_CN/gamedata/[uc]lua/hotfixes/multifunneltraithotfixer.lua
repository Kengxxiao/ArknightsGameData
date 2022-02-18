local MultiFunnelTraitHotfixer = Class("MultiFunnelTraitHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

local m_modeFirstFunnel

local function _SetFunnelAtkScale(self, target, projectile)
    if m_modeFirstFunnel == nil then
        m_modeFirstFunnel = projectile.ability
    end
    if self.m_mainFunnel == nil then
        if m_modeFirstFunnel == projectile.ability then
            self.m_mainFunnel = projectile.ability
            if not self.m_funnels:ContainsKey(projectile.ability) then
                self.m_funnels:Add(projectile.ability, CS.Torappu.Battle.Abilities.MultiFunnelTrait.AttackData)
            end
            local data = self.m_funnels[projectile.ability]
            data.lastTarget = self.m_mainFunnelData.lastTarget
            data.curStackCnt = self.m_mainFunnelData.curStackCnt
            data.curAtkScale = self.m_mainFunnelData.curAtkScale
            self.m_funnels[projectile.ability] = data
        else
            self.m_mainFunnel = m_modeFirstFunnel
        end
    end

    return self:SetFunnelAtkScale(target, projectile)
end

local function _IsFunnelActive(self, ability, ignoreRestoring)
    local toRemove = {};
    local activeFunnelsIter = self.m_activeFunnels:GetEnumerator()
    while activeFunnelsIter:MoveNext() do
        local activeFunnel = activeFunnelsIter.Current
        if ((not self.m_toRemoveFromActiveFunnels:Contains(activeFunnel)) and (not activeFunnel.isCasting)) then
            table.insert(toRemove, activeFunnel)
        end
    end

    for i, ability in ipairs(toRemove) do
      self.m_activeFunnels:Remove(ability);
    end

    return self:IsFunnelActive(ability, ignoreRestoring)
end

local function _Reset(self)
    self:Reset(self)
    self.m_toRemoveFromActiveFunnels:Clear()
    m_modeFirstFunnel = nil
end

function MultiFunnelTraitHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.Abilities.MultiFunnelTrait)
    xlua.private_accessible(CS.Torappu.Battle.Abilities.MultiFunnelTrait.AttackData)

    self:Fix_ex(CS.Torappu.Battle.Abilities.MultiFunnelTrait, "SetFunnelAtkScale", function(self, target, projectile)
        return _SetFunnelAtkScale(self, target, projectile)
    end)

    self:Fix_ex(CS.Torappu.Battle.Abilities.MultiFunnelTrait, "IsFunnelActive", function(self, ability, ignoreRestoring)
        return _IsFunnelActive(self, ability, ignoreRestoring)
    end)

    self:Fix_ex(CS.Torappu.Battle.Abilities.MultiFunnelTrait, "Reset", function(self)
        local ok, errorInfo = xpcall(_Reset, debug.traceback, self)
        if not ok then
            eutil.LogError("[MultiFunnelTraitHotfixer] fix Reset failed. " .. errorInfo)
        end
    end)
end

function MultiFunnelTraitHotfixer:OnDispose()
end

return MultiFunnelTraitHotfixer