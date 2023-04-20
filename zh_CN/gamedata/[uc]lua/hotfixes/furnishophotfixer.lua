local FurniShopHotfixer = Class("FurniShopHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

local function RefreshNumFix(self, currCount)
  local count = self:RefreshNum(currCount)
  if count < 0 then
    return 0
  end
  return count
end

function FurniShopHotfixer:OnInit()

  self:Fix_ex(CS.Torappu.UI.Shop.ShopDetailFurnView, "RefreshNum", function(self,currCount)
    local ok, value, errorInfo = xpcall(RefreshNumFix, debug.traceback, self, currCount)
    if not ok then
      eutil.LogError("[FurniShopHotfixer] fix" .. errorInfo)
    end
    return value
  end)
end

function FurniShopHotfixer:OnDispose()
end

return FurniShopHotfixer