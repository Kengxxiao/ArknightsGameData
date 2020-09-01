local xutil = require('xlua.util')
local eutil = CS.Torappu.Lua.Util

---@class RoguelikeUILocalCacheHotfixer:HotfixBase
local RoguelikeUILocalCacheHotfixer = Class("RoguelikeUILocalCacheHotfixer", HotfixBase)

local function _LoadSquad()
	local uuid = CS.Torappu.PlayerData.instance.data.roguelike.current.status.uuid
	local cacheUUID = CS.Torappu.PlayerPrefsWrapper.GetUserString("UI_ROGUELIKE_UUID")
	if (cacheUUID=="") then
		CS.Torappu.PlayerPrefsWrapper.SetUserString("UI_ROGUELIKE_UUID", uuid);
	else
		if (cacheUUID~=uuid) then
			CS.Torappu.UI.Roguelike.RoguelikeUtil.CleanRoguelikeSquad()
			CS.Torappu.PlayerPrefsWrapper.SetUserString("UI_ROGUELIKE_UUID", uuid);
		end
	end
	return CS.Torappu.UI.Roguelike.RoguelikeUtil.LoadRoguelikeSquad()
end


local function _SaveSquad(squad)
	local uuid = CS.Torappu.PlayerData.instance.data.roguelike.current.status.uuid
	CS.Torappu.PlayerPrefsWrapper.SetUserString("UI_ROGUELIKE_UUID", uuid);
	return CS.Torappu.UI.Roguelike.RoguelikeUtil.SaveRoguelikeSquad(squad)
end


function RoguelikeUILocalCacheHotfixer:OnInit()
	xlua.private_accessible(CS.Torappu.UI.Roguelike.RoguelikeUtil)
	self:Fix_ex(CS.Torappu.UI.Roguelike.RoguelikeUtil, "LoadRoguelikeSquad", function()
   		local ok, ret, errorInfo = xpcall(_LoadSquad,debug.traceback)
    	if not ok then
      		eutil.LogError("[LoadRoguelikeSquad] fix" .. errorInfo)
	    end
    	return ret
 	end)
 	self:Fix_ex(CS.Torappu.UI.Roguelike.RoguelikeUtil, "SaveRoguelikeSquad", function(squad)
   		local ok, ret, errorInfo = xpcall(_SaveSquad,debug.traceback,squad)
    	if not ok then
      		eutil.LogError("[SaveRoguelikeSquad] fix" .. errorInfo)
	    end
    	return ret
 	end)
end

function RoguelikeUILocalCacheHotfixer:OnDispose()
end

return RoguelikeUILocalCacheHotfixer