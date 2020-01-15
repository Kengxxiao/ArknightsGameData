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
  self.m_objList:Clear()
  self:_DoInit(flag)
  for i,v in pairs(self.m_objList) do
    if (v~=nil) then
      local count_text_ten = CS.Torappu.Lua.LuaUIUtil.GetChild(v.gameObject,"count_back_ten")
      local text = CS.Torappu.Lua.LuaUIUtil.GetChild(count_text_ten.gameObject,"Text")
      local textScript = text:GetComponent("Text")
      textScript.horizontalOverflow = CS.UnityEngine.HorizontalWrapMode.Overflow
      textScript.verticalOverflow = CS.UnityEngine.VerticalWrapMode.Overflow
      local count_text_hundred = CS.Torappu.Lua.LuaUIUtil.GetChild(v.gameObject,"count_back_hund")
      local text_h = CS.Torappu.Lua.LuaUIUtil.GetChild(count_text_hundred.gameObject,"Text")
      local textScript_h = text_h:GetComponent("Text")
      textScript_h.horizontalOverflow = CS.UnityEngine.HorizontalWrapMode.Overflow
      textScript_h.verticalOverflow = CS.UnityEngine.VerticalWrapMode.Overflow
    end
  end
end

function CheckinHotfixer:OnDispose()
  xlua.hotfix(CS.Torappu.UI.Home.HomeCheckInState, "_DoInit", nil)
end

return CheckinHotfixer