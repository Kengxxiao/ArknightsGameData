local xutil = require('xlua.util')
local stringRes = require("HotFixes/LuaStringRes")
local eutil = CS.Torappu.Lua.Util

---@class ItemRepoVoucherGachaStateHotfixer:HotfixBase
local ItemRepoVoucherGachaStateHotfixer = Class("ItemRepoVoucherGachaStateHotfixer", HotfixBase)

local function ItemRepoRepair(self)
    local image = self._rarityCharPart6:GetComponent("Image")
    local resList = CS.Torappu.Resource.ResourceManager.LoadAll("Arts/UI/ItemRepo/Textures/rarity_6.png")
    if resList ~= nil then
      for i = 0,resList.Length-1 do
        if(resList[i]:GetType() == typeof(CS.UnityEngine.Sprite)) then
          image.sprite = resList[i];
          break
        end
      end
    end
    image:SetNativeSize()
end

function ItemRepoVoucherGachaStateHotfixer:OnInit()
  xutil.hotfix_ex(CS.Torappu.UI.ItemRepo.ItemRepoVoucherGachaState, "ShowChar",
    function(self, info)
      xpcall(ItemRepoRepair, function(e)
        eutil.LogError(e)
      end, self)
      self:ShowChar(info)
    end, self
  )
end

function ItemRepoVoucherGachaStateHotfixer:OnDispose()
    xlua.hotfix(CS.Torappu.UI.ItemRepo.ItemRepoVoucherGachaState, "ShowChar", nil)
end

return ItemRepoVoucherGachaStateHotfixer