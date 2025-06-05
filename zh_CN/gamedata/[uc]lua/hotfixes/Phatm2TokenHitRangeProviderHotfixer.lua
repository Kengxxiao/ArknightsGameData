
local Phatm2TokenHitRangeProviderHotfixer = Class("Phatm2TokenHitRangeProviderHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

function IsInHitRangeFix(self, option)
    local result = self:IsInHitRange(option)
    if not option.sourceEntity.isValid then
        return false
    end
    
    local source = option.sourceEntity:Lock()
    if source:GetType() ~= typeof(CS.Torappu.Battle.Enemy) then
        return false
    end
    return result
end

function Phatm2TokenHitRangeProviderHotfixer:OnInit()
    xlua.private_accessible("Torappu.Battle.PropLikeStaticBlockToken+Phatm2TokenHitRangeProvider")
    self:Fix_ex("Torappu.Battle.PropLikeStaticBlockToken+Phatm2TokenHitRangeProvider", "IsInHitRange", function(self, option) 
        local ok, result, errorInfo = xpcall(IsInHitRangeFix, debug.traceback, self, option)
        if ok then
            return result
        else
          eutil.LogError("[Phatm2TokenHitRangeProviderHotfixer] Phatm2TokenHitRangeProvider fix" .. errorInfo)
        end
    end)
end

function Phatm2TokenHitRangeProviderHotfixer:OnDispose()
end

return Phatm2TokenHitRangeProviderHotfixer