-- local BaseHotfixer = require ("Module/Core/BaseHotfixer")
-- local xutil = require('xlua.util')
local eutil = CS.Torappu.Lua.Util

---@class CampaignHotfixer:HotfixBase
local CampaignHotfixer = Class("CampaignHotfixer", HotfixBase)

local function LoadData(self,stageId,inputEndTime)
	-- body
	self:LoadData(stageId,inputEndTime)
	local stageCaches = CS.Torappu.UI.UILocalCache.instance:LoadStageCache();
	if (stageCaches:ContainsKey(stageId)) then
		self.stateViewModel.stageCommonViewModel.localCache = stageCaches:get_Item(stageId)
	end
end

local function _GoToSquad(self)
	local stageCaches = CS.Torappu.UI.UILocalCache.instance:LoadStageCache();
	local stageId = self._stateBean.property.Value.viewModel.id
	local stageLocalCache
	if (not stageCaches:ContainsKey(stageId)) then
		stageLocalCache = CS.Torappu.UI.Stage.StageViewModel.LocalCache()
		stageCaches:set_Item(stageId,stageLocalCache)
	else
		stageLocalCache = stageCaches:get_Item(stageId)
	end

	stageLocalCache.isAutoBattle = self._stateBean.previewConfigProperty.Value.isAutoBattle
	stageCaches:set_Item(stageId,stageLocalCache)
	CS.Torappu.UI.UILocalCache.instance:SaveStageCache(stageCaches)

	self:_GoToSquad()
end

function CampaignHotfixer:OnInit()
	xlua.private_accessible(CS.Torappu.UI.Campaign.CampaignZoneMapState)
	self:Fix_ex(CS.Torappu.UI.Campaign.CampaignZoneMapState, "_GoToSquad", function(self)
		_GoToSquad(self)
    	return
 	end)
 	xlua.private_accessible(CS.Torappu.UI.Campaign.CampaignStageMapViewModel)
	self:Fix_ex(CS.Torappu.UI.Campaign.CampaignStageMapViewModel, "LoadData", function(self,stageId,inputEndTime)
		LoadData(self,stageId,inputEndTime)
    	return
 	end)
end

function CampaignHotfixer:OnDispose()
end

return CampaignHotfixer