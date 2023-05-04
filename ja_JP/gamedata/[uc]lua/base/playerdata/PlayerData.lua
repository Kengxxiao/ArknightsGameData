




PlayerData = ModelMgr.DefineModel("PlayerData")

local DEPRECATE_META = 
{
  __index = function() 
    CS.Torappu.Lua.Util.LogError("PlayerData in lua has been deprecated. Don't use this.")
  end,
  __newindex = function()
    CS.Torappu.Lua.Util.LogError("PlayerData in lua has been deprecated. Don't use this.")
  end
}

local DEPRECATE_DATA = {}
setmetatable(DEPRECATE_DATA, DEPRECATE_META)

function PlayerData:OnInit()
  self.data = DEPRECATE_DATA
  CS.Torappu.Lua.Util.BindPlayerDataListener(self)
end

function PlayerData:OnDispose()
  CS.Torappu.Lua.Util.BindPlayerDataListener(nil)
  self.data = DEPRECATE_DATA
end



function PlayerData:ExportSetData(playerDataModel)
  self.data = DEPRECATE_DATA
end