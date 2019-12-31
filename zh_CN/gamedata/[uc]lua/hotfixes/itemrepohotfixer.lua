-- local BaseHotfixer = require ("Module/Core/BaseHotfixer")
-- local xutil = require('xlua.util')
-- local stringRes = require("Module/Config/LuaStringRes")
local eutil = CS.Torappu.Lua.Util

---@class ItemRepoHotfixer:HotfixBase
local ItemRepoHotfixer = Class("ItemRepoHotfixer", HotfixBase)

local function ClickToDetail(self,charId)
  if (CS.Torappu.FastActionDetector.IsFastAction()) then
    return;
  end
  self:OnClick(charId)
end

function ItemRepoHotfixer:OnInit()
  self:Fix_ex(CS.Torappu.UI.ItemRepo.ItemRepoChooseCharState, "OnClick", function(self,charId)
    local ok, error = xpcall(ClickToDetail,debug.traceback,self,charId)
    if not ok then
      eutil.LogError("[ItemRepo] fix" .. error);
    end
  end)
end

function ItemRepoHotfixer:OnDispose()
end

return ItemRepoHotfixer