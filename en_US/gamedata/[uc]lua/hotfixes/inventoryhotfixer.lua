local xutil = require('xlua.util')
local stringRes = require("HotFixes/LuaStringRes")
local eutil = CS.Torappu.Lua.Util

---@class InventoryHotfixer:HotfixBase
local InventoryHotfixer = Class("InventoryHotfixer", HotfixBase)

function InventoryHotfixer:OnInit()

  xutil.hotfix_ex(CS.Torappu.UI.ItemRepo.ItemRepoApItemState, "OnEnter",
  function(self)
    xpcall(OnEnterApItem, function(e)
      eutil.LogError(e)
    end,self)
    self:OnEnter()
  end)

end

function OnEnterApItem(self) 
  local add_btn =  CS.Torappu.Lua.LuaUIUtil.GetChild(self.gameObject,"add_btn")
  local button = add_btn:GetComponent("Button")
  button.interactable = true

  -- fix 'remaining' overflow bug
  local label_count_back = CS.Torappu.Lua.LuaUIUtil.GetChild(self.gameObject, "label_count_back")
  local const_text = CS.Torappu.Lua.LuaUIUtil.GetChild(label_count_back, "const_text")
  local target_text = const_text:GetComponent("Text")
  target_text.resizeTextForBestFit = true
  target_text.resizeTextMaxSize = 25
  target_text.horizontalOverflow = CS.UnityEngine.HorizontalWrapMode.Wrap
  local target_rect = const_text:GetComponent("RectTransform")
  local target_sizeDelta = target_rect.sizeDelta
  target_sizeDelta.x = 68
  target_rect.sizeDelta = target_sizeDelta
end

function InventoryHotfixer:OnDispose()
  xlua.hotfix(CS.Torappu.UI.ItemRepo.ItemRepoApItemState, "OnEnter", nil)
end

return InventoryHotfixer