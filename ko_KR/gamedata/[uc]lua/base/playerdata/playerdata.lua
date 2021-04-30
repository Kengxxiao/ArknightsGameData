--[[
  Global model to access PlayerData.
  About PlayerData see http://dev.int.hypergryph.com/doc/display/TOR/PlayerData.
  Note that the inner data of PlayerData is readonly and its content shouldn't be modified.
  Use PlayerData.me.data to access the player data schema
]]--

---@class PlayerData
---@field me PlayerData
---@field data table the player data schema in LuaTable form
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

---Sync player data from C# with a newly generated table instance
---@param data table 
function PlayerData:ExportSetData(playerDataModel)
  self.data = DEPRECATE_DATA
end