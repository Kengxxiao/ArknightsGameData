local xutil = require('xlua.util')
local stringRes = require("HotFixes/LuaStringRes")
local eutil = CS.Torappu.Lua.Util

---@class InventoryHotfixer:HotfixBase
local InventoryHotfixer = Class("InventoryHotfixer", HotfixBase)

function InventoryHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.ItemRepo.ItemRepoApItemState)
  xlua.private_accessible(CS.Torappu.UI.ItemRepo.ItemRepoUseApSupplyItem)
  xlua.private_accessible(CS.Torappu.UI.UILinearDimensionAdjust)

  xutil.hotfix_ex(CS.Torappu.UI.ItemRepo.ItemRepoApItemState, "OnEnter",
  function(self)
    xpcall(OnEnterApItem, function(e)
      eutil.LogError(e)
    end,self)
    self:OnEnter()
  end)

  xutil.hotfix_ex(CS.Torappu.UI.ItemRepo.ItemRepoUseableDetailState, "OnEnter",
  function(self)
    xpcall(OnEnterUseableDetail, function(e)
      eutil.LogError(e)
    end,self)
    self:OnEnter()
  end)
  
end

function OnEnterUseableDetail(self) 
  local timePart = CS.Torappu.Lua.LuaUIUtil.GetChild(self.gameObject,"time_part")
  local imageInfo = CS.Torappu.Lua.LuaUIUtil.GetChild(timePart,"Image")
  local uiLinearDimensionAdjust = imageInfo:GetComponent("UILinearDimensionAdjust")
  uiLinearDimensionAdjust._biasWidth = 230
  local timeText = CS.Torappu.Lua.LuaUIUtil.GetChild(timePart,"time_text")
  local timeTextComp = timeText:GetComponent("Text")
  timeTextComp.horizontalOverflow = CS.UnityEngine.HorizontalWrapMode.Overflow
  local constText = CS.Torappu.Lua.LuaUIUtil.GetChild(timePart,"const_text")
  local constTextRect = constText:GetComponent("RectTransform")
  local vector2 = constTextRect.anchoredPosition
  vector2.x = 213.2
  constTextRect.anchoredPosition = vector2
end

function OnEnterApItem(self) 
  local timePart = CS.Torappu.Lua.LuaUIUtil.GetChild(self.gameObject,"time_part")
  local imageInfo = CS.Torappu.Lua.LuaUIUtil.GetChild(timePart,"Image")
  local uiLinearDimensionAdjust = imageInfo:GetComponent("UILinearDimensionAdjust")
  uiLinearDimensionAdjust._biasWidth = 230
  local timeText = CS.Torappu.Lua.LuaUIUtil.GetChild(timePart,"time_text")
  local timeTextComp = timeText:GetComponent("Text")
  timeTextComp.horizontalOverflow = CS.UnityEngine.HorizontalWrapMode.Overflow
  local constText = CS.Torappu.Lua.LuaUIUtil.GetChild(timePart,"const_text")
  local constTextRect = constText:GetComponent("RectTransform")
  local vector2 = constTextRect.anchoredPosition
  vector2.x = 213.2
  constTextRect.anchoredPosition = vector2

  local add_btn =  CS.Torappu.Lua.LuaUIUtil.GetChild(self.gameObject,"add_btn")
  local button = add_btn:GetComponent("Button")
  button.interactable = true
end

function InventoryHotfixer:OnDispose()
  xlua.hotfix(CS.Torappu.UI.ItemRepo.ItemRepoApItemState, "OnEnter", nil)
  xlua.hotfix(CS.Torappu.UI.ItemRepo.ItemRepoUseApSupplyItem, "OnEnter", nil)
end

return InventoryHotfixer