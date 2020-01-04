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

function PlayerData:OnInit()
  self.data = nil
  CS.Torappu.Lua.Util.BindPlayerDataListener(self)
end

function PlayerData:OnDispose()
  CS.Torappu.Lua.Util.BindPlayerDataListener(nil)
  self.data = nil
end

---Sync player data from C# with a newly generated table instance
---@param data table 
function PlayerData:ExportSetData(playerDataModel)
  self.data = playerDataModel
end