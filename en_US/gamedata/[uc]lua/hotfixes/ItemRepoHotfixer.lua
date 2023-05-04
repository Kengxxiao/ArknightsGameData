local ItemRepoHotfixer = Class("ItemRepoHotfixer", HotfixBase)

local function _UpdateStageDropInfoFix(self,viewModel,descViewModel)
	local stageDataMainLine = CS.Torappu.StageDataUtil:GetMainStageProgress();	
	if (stageDataMainLine == nil)then
		local curTs = CS.Torappu.DateTimeUtil.timeStampNow;
		if (viewModel.stageDrop ~= nil) then
			for i = viewModel.stageDrop.Count - 1,0,-1 do
				local dropInfo = viewModel.stageDrop[i]
				local stageSucc,stageDataWrapper = CS.Torappu.StageDataUtil.TryGetStageWrapper(dropInfo.stageId, curTs)
				if (stageSucc) then
		          	local stageData = stageDataWrapper.data;
		          	if (stageData ~= nil) and (stageData.stageType == CS.Torappu.StageType.MAIN) then
						local succ, playerStage = CS.Torappu.PlayerData.instance.data.dungeon.stages:TryGetValue(dropInfo.stageId)
						if (succ == false) then
							viewModel.stageDrop:RemoveAt(i)
						end
					end
				end
			end
		end
	end
end

local function _UpDateStageDropInfoFixWrapped(self,viewModel,descViewModel)
	local ok = xpcall(_UpdateStageDropInfoFix, debug.traceback, self,viewModel, descViewModel)
	return self:_UpdateStageDropInfo(viewModel,descViewModel)
end

function ItemRepoHotfixer:OnInit()
	self:Fix_ex(CS.Torappu.UI.ItemRepoDropInfoView, "_UpdateStageDropInfo", function(self,viewModel,descViewModel)
        return _UpDateStageDropInfoFixWrapped(self,viewModel,descViewModel)
    end)
end

function ItemRepoHotfixer:OnDispose()
end

return ItemRepoHotfixer