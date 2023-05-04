local NameCardHotfixer = Class("NameCardHotfixer", HotfixBase)

local function RenderFix(self,viewModel)	
	self:Render(viewModel)
	local val = viewModel.lastMissionCode
	if (val == nil) then
		val = CS.Torappu.StringRes.DESC_HOME_ALL_STAGE_COMPELTE
	end
	local fontInstance = CS.Torappu.SceneFontHolder.instance;
	if (fontInstance == nil) then
		return
	end
	if (val == CS.Torappu.StringRes.DESC_HOME_ALL_STAGE_COMPELTE) then 
		self._stageInfo.text = val;
		local succ, font = fontInstance:TryGetFont("NotoSansHans-Medium")
		if (succ) then
			self._stageInfo.font = font
		end
	else
		local succ, font = fontInstance:TryGetFont("AEwide")
		if (succ) then
			self._stageInfo.font = font
		end
	end
end

function NameCardHotfixer:OnInit()
	self:Fix_ex(CS.Torappu.UI.Friend.NameCardView, "Render", function(self,viewModel)
        return RenderFix(self,viewModel)
    end)
end

function NameCardHotfixer:OnDispose()
end

return NameCardHotfixer