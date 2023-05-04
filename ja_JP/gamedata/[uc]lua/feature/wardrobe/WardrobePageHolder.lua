


WardrobePageHolder = Class("WardrobePageHolder", DlgBase);

WardrobePageHolder.stateList = {
	"SortByTimeStateIndex",
	"SortBySkinGroupStateIndex",
	"SkinGroupDetailStateIndex"
}

WardrobePageHolder.StateEnum = CreatEnumTable(WardrobePageHolder.stateList)

WardrobePageHolder.DefaultStateIndex = WardrobePageHolder.StateEnum.SortByTimeStateIndex

function WardrobePageHolder:OnInit()
	WardrobePageHolder.singelton = self

	self.sortByTimeState = self:CreateWidgetByPrefab(WardrobeSortByTimeState, self._sortByTimeState, self._stateContainer);
	self.sortBySkinGroupState = self:CreateWidgetByPrefab(WardrobeSortBySkinGroupState, self._sortBySkinGroupState, self._stateContainer);
	self.skinGroupDetailState = self:CreateWidgetByPrefab(WardrobeSkinGroupDetailState, self._skinGroupDetailState, self._stateContainer);

	self.sortByTimeState.parent = self
	self.sortBySkinGroupState.parent = self
	self.skinGroupDetailState.parent = self
	self:ToState(WardrobePageHolder.DefaultStateIndex)
	self:AddButtonClickListener(self._changeStateButton, self._ChangeState);
	self:AddButtonClickListener(self._showNotGetBtn, self.ChangeClickShowUnlockFlag);
	self._topMenuHolder.achieveInst = self.ApplyTopMenu
	self:RefreshShowNotGetFlag()	
end

function WardrobePageHolder.ApplyTopMenu(inst)
	local topMenu = inst:GetComponent("Torappu.UI.CommonTopMenu");
	topMenu.onBackClick = WardrobePageHolder.singelton.ReturnPage
	WardrobePageHolder.cacheTopMenu = topMenu;
end


function WardrobePageHolder:ReturnPage()
	if (WardrobePageHolder.singelton.currentState == WardrobePageHolder.StateEnum.SortByTimeStateIndex
		or WardrobePageHolder.singelton.currentState == WardrobePageHolder.StateEnum.SortBySkinGroupStateIndex) then
			WardrobePageHolder.singelton:Close()
	end
	if (WardrobePageHolder.singelton.currentState == WardrobePageHolder.StateEnum.SkinGroupDetailStateIndex) then
		WardrobePageHolder.singelton:ToState(WardrobePageHolder.StateEnum.SortBySkinGroupStateIndex)
	end
	
end

function WardrobePageHolder:ToState(index)
	
	local transData
	if (self.currentState~= nil) then
		local lastState = self:GetState(self.currentState)
		if (lastState.OnExit ~= nil and type(lastState.OnExit) == "function") then
			lastState:OnExit()
		end
		local ableFlag, data = lastState:GetTransInfo()
		if (not ableFlag) then
			return
		end
		transData = data
	end
	self.currentState = index

	for i = 1, 3 do
		local obj = self:GetState(i)
		CS.Torappu.Lua.Util.SetActiveIfNecessary(obj.m_root,i == index)
		if (i==index and obj.CheckData ~= nil and type(obj.CheckData) == "function") then
			obj:CheckData(transData)
		end
		if (i==index and obj.StartFadeIn~=nil) then
			obj:StartFadeIn()
		end
	end
	if (self.currentState == WardrobePageHolder.StateEnum.SortByTimeStateIndex) then
		CS.Torappu.Lua.Util.SetActiveIfNecessary(self._twoStateToggle.gameObject,true)
		CS.Torappu.Lua.Util.SetActiveIfNecessary(self._showNotGetBtn.gameObject,true);
		self._twoStateToggle.state = CS.Torappu.UI.TwoStateToggle.State.SELECT
	end
	if (self.currentState == WardrobePageHolder.StateEnum.SortBySkinGroupStateIndex) then
		CS.Torappu.Lua.Util.SetActiveIfNecessary(self._twoStateToggle.gameObject,true)
		CS.Torappu.Lua.Util.SetActiveIfNecessary(self._showNotGetBtn.gameObject,true);
		self._twoStateToggle.state = CS.Torappu.UI.TwoStateToggle.State.UNSELECT
	end
	if (self.currentState == WardrobePageHolder.StateEnum.SkinGroupDetailStateIndex) then
		CS.Torappu.Lua.Util.SetActiveIfNecessary(self._showNotGetBtn.gameObject,false);
		CS.Torappu.Lua.Util.SetActiveIfNecessary(self._twoStateToggle.gameObject,false)
	end
end

function WardrobePageHolder:OnResume()
	local currentState = self:GetState(self.currentState)
	if (currentState ~= nil and currentState.OnResume~=nil) then
		currentState:OnResume()
	end
end

function WardrobePageHolder:RefreshShowNotGetFlag()
	if (WardrobeUtil.GetSkinUnGetFlag()) then
		self._showNotGetFlag.state = CS.Torappu.UI.TwoStateToggle.State.UNSELECT
	else
		self._showNotGetFlag.state = CS.Torappu.UI.TwoStateToggle.State.SELECT
	end
end

function WardrobePageHolder:ChangeClickShowUnlockFlag()
	local showUnGetFlag = not WardrobeUtil.GetSkinUnGetFlag()
	WardrobeUtil.SetSkinUnGetFlag(showUnGetFlag)

	local currentState = self:GetState(self.currentState)
	if (currentState ~= nil and currentState.ChangeClickShowUnlockFlag~=nil) then
		currentState:ChangeClickShowUnlockFlag()
	end
	self:RefreshShowNotGetFlag()
end


function WardrobePageHolder:_ChangeState()
	if (self.currentState == WardrobePageHolder.StateEnum.SortByTimeStateIndex) then
		self:ToState(WardrobePageHolder.StateEnum.SortBySkinGroupStateIndex)
		return
	end
	if (self.currentState == WardrobePageHolder.StateEnum.SortBySkinGroupStateIndex) then
		self:ToState(WardrobePageHolder.StateEnum.SortByTimeStateIndex)
		return
	end
end

function WardrobePageHolder:GetState(index)
	
	if (index == WardrobePageHolder.StateEnum.SortByTimeStateIndex) then
		return self.sortByTimeState
	end
	if (index == WardrobePageHolder.StateEnum.SortBySkinGroupStateIndex) then
		return self.sortBySkinGroupState
	end
	if (index == WardrobePageHolder.StateEnum.SkinGroupDetailStateIndex) then
		return self.skinGroupDetailState
	end
	return nil
end

function WardrobePageHolder:OnClose()
	WardrobePageHolder.singelton = nil
	WardrobePageHolder.cacheTopMenu.onBackClick = nil
end