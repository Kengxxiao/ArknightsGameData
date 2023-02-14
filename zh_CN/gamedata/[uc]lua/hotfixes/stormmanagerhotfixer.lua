
local eutil = CS.Torappu.Lua.Util


local StormManagerHotfixer = Class("StormManagerHotfixer", HotfixBase)

local function _OnUnitFinish_Fixed(self, arg)
    if arg ~= nil and self.m_tileContainStormBlocker ~= nil then
        self._OnUnitFinish(self, arg)
    end
end

local function _UpdateTileStatus_Fixed(self)
    if self.m_tileInStorm ~= nil and self.m_tileInStormBefore ~= nil then
        self._UpdateTileStatus(self)
    end
end

local function _UpdateStormBlocker_Fixed(self, unit)
    if self.m_tileInStorm ~= nil and self.m_tileInStormBefore ~= nil then
        self._UpdateStormBlocker(self, unit)
    end
end

local function _OnUnitBorn_Fixed(self, unit)
    if unit ~= nil then
        if self.m_tileContainStormBlocker.ContainsKey(self.m_tileContainStormBlocker, unit) then
            self._UpdateTileStatus(self)
            self._UpdateStormBlocker(self, unit)
        else
            self._OnUnitBorn(self, unit)
        end
    end
end

function StormManagerHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.StormManager)

    self:Fix_ex(CS.Torappu.Battle.StormManager, "_OnUnitFinish",
        function(self, arg)
            local ok, errorInfo = xpcall(_OnUnitFinish_Fixed, debug.traceback, self, arg)
            if not ok then
                eutil.LogError("[StormManagerHotfixer] _OnUnitFinish fix" .. errorInfo)
            end
        end)

    self:Fix_ex(CS.Torappu.Battle.StormManager, "_UpdateTileStatus",
        function(self)
            local ok, errorInfo = xpcall(_UpdateTileStatus_Fixed, debug.traceback, self)
            if not ok then
                eutil.LogError("[StormManagerHotfixer] _UpdateTileStatus fix" .. errorInfo)
            end
        end)

    self:Fix_ex(CS.Torappu.Battle.StormManager, "_UpdateStormBlocker",
        function(self, unit)
            local ok, errorInfo = xpcall(_UpdateStormBlocker_Fixed, debug.traceback, self, unit)
            if not ok then
                eutil.LogError("[StormManagerHotfixer] _UpdateStormBlocker fix" .. errorInfo)
            end
        end)

    self:Fix_ex(CS.Torappu.Battle.StormManager, "_OnUnitBorn",
        function(self, arg)
            local ok, errorInfo = xpcall(_OnUnitBorn_Fixed, debug.traceback, self, arg)
            if not ok then
                eutil.LogError("[StormManagerHotfixer] _OnUnitBorn fix" .. errorInfo)
            end
        end)
end

function StormManagerHotfixer:OnDispose()
end

return StormManagerHotfixer
