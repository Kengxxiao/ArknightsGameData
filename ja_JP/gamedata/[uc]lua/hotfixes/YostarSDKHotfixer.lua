local YostarSDKHotfixer = Class("YostarSDKHotfixer", HotfixBase)
local pattern = [[^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$]]

local function CheckIfEmailValidFix(self, emailAddr)
    if CS.System.String.IsNullOrEmpty(emailAddr) then
        return false;
    end
    
    return CS.System.Text.RegularExpressions.Regex.IsMatch(emailAddr, pattern)
end

function YostarSDKHotfixer:OnInit()
    self:Fix_ex(CS.YostarSDK.YostarSDK, "CheckIfEmailValid", function(self, emailAddr)
        return CheckIfEmailValidFix(self, emailAddr)
    end)
end

function YostarSDKHotfixer:OnDispose()
end

return YostarSDKHotfixer
