local eutil = CS.Torappu.Lua.Util


local UIHotfixer = Class("UIHotfixer", HotfixBase)

local function _FixRefreshCharmsList(self) 
  self:_RefreshCharmsList()
  if self.m_charmList == nil then
    local StringList = CS.System.Collections.Generic.List(CS.System.String)
    self.m_charmList = StringList()
  end
end

function UIHotfixer:OnInit()
  self:Fix_ex(CS.Torappu.UI.Squad.SquadHomeStateBean, "_RefreshCharmsList", function(self)
    local ok, errorInfo = xpcall(_FixRefreshCharmsList, debug.traceback, self)
    if not ok then
      eutil.LogError("[_RefreshCharmsList] error " .. errorInfo)
    end
  end)
end

function UIHotfixer:OnDispose()
end

return UIHotfixer