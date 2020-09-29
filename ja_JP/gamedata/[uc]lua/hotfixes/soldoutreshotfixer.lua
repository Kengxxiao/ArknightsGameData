---@class SoldoutResHotfixer:HotfixBase

local eutil = CS.Torappu.Lua.Util
local assetUtil = CS.Torappu.UI.UIAssetLoader
local class2inject = CS.Torappu.UI.TemplateShop.TemplateShopCommonItemView
local resMgr = CS.Torappu.Resource.ResourceManager
local SoldoutResHotfixer = Class("SoldoutResHotfixer",HotfixBase)


local function GetLan()
    local isJp = CS.Torappu.I18N.LocalizationEnv.IsJapan()
    local isKr = CS.Torappu.I18N.LocalizationEnv.IsKorea()
    local isEn = CS.Torappu.I18N.LocalizationEnv.IsEnArea()
  
    if isJp then
      return "JP"
    elseif isKr then
      return "KR"
    elseif isEn then
      return "EN"
    end
end


local path = "[[{lan}]]/Hotfix/sold_out_st_bar.png"
path = path:gsub("{lan}",GetLan())
local imgRes = nil
local function SoldoutResReplace(self)
    if imgRes == nil then
        local resList = resMgr.LoadAll(path)
        if resList ~= nil then
            for i = 0, resList.Length-1 do
                if(resList[i]:GetType() == typeof(CS.UnityEngine.Sprite)) then
                    imgRes = resList[i]
                    break
                end
            end
        end
    end
    if imgRes ~= nil then
        self._soldOutImg:GetComponent("Image").sprite = imgRes
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
