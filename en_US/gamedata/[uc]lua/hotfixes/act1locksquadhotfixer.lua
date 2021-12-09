 local xutil = require('xlua.util')
 local eutil = CS.Torappu.Lua.Util


local Act1lockSquadHotfixer = Class("Act1lockSquadHotfixer", HotfixBase)


local function _DeleteCurrentSquad(self)
    if (self.m_stateBean.isSquadImmutable) then
        CS.Torappu.UI.UINotification.TextToast(CS.Torappu.StringRes.ALERT_PREDEFINED_SQUAD_NOT_EDITABLE)
    else 
        self:_DeleteCurrentSquad()
    end
end

function Act1lockSquadHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Activity.Act1Lock.UI.Act1LockSquadHomeState)

    self:Fix_ex(CS.Torappu.Activity.Act1Lock.UI.Act1LockSquadHomeState, "_DeleteCurrentSquad", _DeleteCurrentSquad)
end

function Act1lockSquadHotfixer:OnDispose()
end

return Act1lockSquadHotfixer