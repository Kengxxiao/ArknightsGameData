local luaUtils = CS.Torappu.Lua.Util;
local FuncFurnModelHotfixer = Class("FuncFurnModelHotfixer", HotfixBase)

local function Fix_OnInit(self)
  self:OnInit();
  self:UpdateData();
end

function FuncFurnModelHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Building.BuildingFuncFurnitureModel)
  self:Fix_ex(CS.Torappu.Building.BuildingFuncFurnitureModel, "OnInit", function(self)
    local ok, errorInfo = xpcall(Fix_OnInit, debug.traceback, self)
      if not ok then
        LogError("fix BuildingFuncFurnitureModel OnInit error" .. errorInfo)
      end
    end)

end

return FuncFurnModelHotfixer