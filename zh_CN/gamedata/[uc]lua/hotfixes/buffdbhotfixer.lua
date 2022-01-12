local BuffDBHotfixer = Class("BuffDBHotfixer", HotfixBase)
 
local function StartFix(self)
    CS.Torappu.Battle.BuffDB.instance.m_buffTemplates = nil
    self:Start()
end
 
function BuffDBHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Battle.BuffDB)
    xlua.private_accessible(CS.Torappu.UI.Login.LoginViewController)

    self:Fix_ex(CS.Torappu.UI.Login.LoginViewController, "Start", function(self)
        local ok, errorInfo = xpcall(StartFix, debug.traceback, self)
        if not ok then
            eutil.LogError("[BuffDBHotfixer] fix" .. errorInfo)
        end
    end)
end
 
function BuffDBHotfixer:OnDispose()
end
 
return BuffDBHotfixer