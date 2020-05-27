local xutil = require('xlua.util')
local stringRes = require("HotFixes/LuaStringRes")
local eutil = CS.Torappu.Lua.Util

---@class UICharacterSelectStateHotfixer:HotfixBase
local UICharacterSelectStateHotfixer = Class("UICharacterSelectStateHotfixer", HotfixBase)

local function UICharacterSelectState(self)
  local obj = CS.Torappu.Lua.LuaUIUtil.GetChild(self.gameObject, "label_atk_speed_value")
  local obj_text = obj:GetComponent("Text")
  local obj_rect = obj:GetComponent("RectTransform")
  obj_text.verticalOverflow = 0
  obj_text.lineSpacing = 1.0
  obj_rect.anchoredPosition = CS.UnityEngine.Vector2(67.3, 1.7)
  obj_rect.sizeDelta = CS.UnityEngine.Vector2(91.7, 21.7)
end

function UICharacterSelectStateHotfixer:OnInit()
  xutil.hotfix_ex(CS.Torappu.UI.CharSelect.UICharacterSelectState, "OnEnter",
  function(self)
    self:OnEnter()
    xpcall(UICharacterSelectState, function(e)
      eutil.LogError(e)
    end,self)
  end)
end

function UICharacterSelectStateHotfixer:OnDispose()
  xlua.hotfix(CS.Torappu.UI.CharSelect.UICharacterSelectState, "OnEnter", nil)
end

return UICharacterSelectStateHotfixer