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
end

function InventoryHotfixer:OnDispose()
  xlua.hotfix(CS.Torappu.UI.ItemRepo.ItemRepoApItemState, "OnEnter", nil)
end

return InventoryHotfixer