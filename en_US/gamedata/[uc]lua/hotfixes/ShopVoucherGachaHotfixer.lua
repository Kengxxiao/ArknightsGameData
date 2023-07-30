local ShopVoucherGachaHotfixer = Class("ShopVoucherGachaHotfixer", HotfixBase)

local classToFix = CS.Torappu.UI.Shop.ShopDetailVoucherGachaState
local function LuaFunction(self)
    
    self:_InitIfNot()
    local voucherData = self.m_stateBean.voucherData
    if voucherData ~= nil then
        local securityRarityEnum = CS.System.Enum.ToObject(typeof(CS.Torappu.RarityRank),voucherData.securityRarity)
        self.m_holder:RenderGachaDetail("BOOT_1",voucherData.detailData,voucherData.hasSecurity,securityRarityEnum)
    end
end

function ShopVoucherGachaHotfixer:OnInit()
    

    xlua.hotfix(classToFix, "OnEnter", function(self)
        local ok, errorInfo = xpcall(LuaFunction, debug.traceback, self)
        if not ok then
            LogError("[ShopVoucherGachaHotfixer] fix" .. errorInfo)
        end
    end)
end

function ShopVoucherGachaHotfixer:OnDispose()
end

return ShopVoucherGachaHotfixer