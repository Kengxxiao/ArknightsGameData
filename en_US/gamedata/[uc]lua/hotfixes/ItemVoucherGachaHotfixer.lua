local ItemVoucherGachaHotfixer = Class("ItemVoucherGachaHotfixer", HotfixBase)

local classToFix = CS.Torappu.UI.ItemRepo.ItemRepoVoucherGachaDetailState
local function LuaFunction(self)
    
    self:_InitIfNot()
    local voucherData = self._stateBean.cacheCharData
    local securityRarityEnum = CS.System.Enum.ToObject(typeof(CS.Torappu.RarityRank),voucherData.securityRarity)
    self.m_holder:RenderGachaDetail("BOOT_1",voucherData.detailData,voucherData.hasSecurity,securityRarityEnum)

end

function ItemVoucherGachaHotfixer:OnInit()
    

    xlua.hotfix(classToFix, "OnEnter", function(self)
        local ok, errorInfo = xpcall(LuaFunction, debug.traceback, self)
        if not ok then
            LogError("[ItemVoucherGachaHotfixer] fix" .. errorInfo)
        end
    end)
end

function ItemVoucherGachaHotfixer:OnDispose()
end

return ItemVoucherGachaHotfixer