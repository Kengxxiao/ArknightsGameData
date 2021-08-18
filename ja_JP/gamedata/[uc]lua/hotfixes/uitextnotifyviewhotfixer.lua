local eutil = CS.Torappu.Lua.Util


local UITextNotifyViewHotfixer = Class("UITextNotifyViewHotfixer",HotfixBase)

local class2inject = CS.Torappu.UI.Notification.UITextNotifyView

local function _FixTextNotifyViewMaxHeight(self)
  self._maxTextHeight = 300
  CS.UnityEngine.Debug.Log("set height")
    
end


function UITextNotifyViewHotfixer:OnInit()
  CS.UnityEngine.Debug.Log("init")
  self:Fix_ex(class2inject,"Render",function (self, textParam)
    local ok,error = xpcall(_FixTextNotifyViewMaxHeight, debug.traceback,self)
    if not ok then
      eutil.LogError("[UITextNotifyViewHotfixer] fix height error" .. error)
    end
    self:Render(textParam)
  end)
end



function  UITextNotifyViewHotfixer:OnDispose()
end



return UITextNotifyViewHotfixer