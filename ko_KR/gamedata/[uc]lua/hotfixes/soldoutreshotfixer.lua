---@class SoldoutResHotfixer:HotfixBase

local eutil = CS.Torappu.Lua.Util
local assetUtil = CS.Torappu.UI.UIAssetLoader
local class2inject = CS.Torappu.UI.TemplateShop.TemplateShopCommonItemView
local SoldoutResHotfixer = Class("SoldoutResHotfixer",HotfixBase)




local RES_PATH = "Arts/UI/TemplateShop/common/sold_out_st_bar_hub.prefab"

local function SoldoutResReplace(self)
    local hub = assetUtil.LoadPrefab(RES_PATH)
    local behavior = hub:GetComponent("SpriteHub")
    local ret, spriteRes = behavior:TryGetSprite("sold_out_st_bar")
    if spriteRes ~= nil then
        self._soldOutImg:GetComponent("Image").sprite = spriteRes
    end
    


end


function SoldoutResHotfixer:OnInit()
    self:Fix_ex(class2inject, "RenderItem", function(self, viewModel)
        self:RenderItem(viewModel)
        local ok, error = xpcall(SoldoutResReplace, debug.traceback,self)
        if not ok then 
            eutil.LogError("[SoldoutResHotfixer] fix error" .. error)
        end
    end)
end
    

function SoldoutResHotfixer:OnDispose()
    xlua.hotfix(class2inject, "RenderItem", nil)
end


return SoldoutResHotfixer
