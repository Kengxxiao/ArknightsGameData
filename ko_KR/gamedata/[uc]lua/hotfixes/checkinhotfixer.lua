local xutil = require('xlua.util')
local stringRes = require("HotFixes/LuaStringRes")
local eutil = CS.Torappu.Lua.Util

---@class CheckinHotfixer:HotfixBase
local CheckinHotfixer = Class("CheckinHotfixer", HotfixBase)

function CheckinHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.Home.HomeCheckInState)

  xutil.hotfix_ex(CS.Torappu.UI.Home.HomeCheckInState, "_DoInit",
  function(self,flag)
    xpcall(DoInitFix, function(e)
      eutil.LogError(e)
    end,self,flag)
  end)

end

function DoInitFix(self,flag) 
  self:_DoInit(flag)
  for i,v in pairs(self.m_objList) do
    local count_text_ten = CS.Torappu.Lua.LuaUIUtil.GetChild(v.gameObject,"count_back_ten")
    local text = CS.Torappu.Lua.LuaUIUtil.GetChild(count_text_ten.gameObject,"Text")
    local textScript = text:GetComponent("Text")
    textScript.horizontalOverflow = CS.UnityEngine.HorizontalWrapMode.Overflow
    textScript.verticalOverflow = CS.UnityEngine.VerticalWrapMode.Overflow
  end
end

function CheckinHotfixer:OnDispose()
  xlua.hotfix(CS.Torappu.UI.Home.HomeCheckInState, "_DoInit", nil)
end

return CheckinHotfixer