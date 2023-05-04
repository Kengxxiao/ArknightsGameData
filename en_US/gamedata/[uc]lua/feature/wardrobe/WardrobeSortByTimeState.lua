
WardrobeSortByTimeState = Class("WardrobeSortByTimeState", UIPanel);

function WardrobeSortByTimeState:OnInit()
	self.stateBean = {}
	self.stateBean.skinList = {}
	self.initFlag = false	
	self.showUnGetFlag = WardrobeUtil.GetSkinUnGetFlag()
	local go = CS.UnityEngine.GameObject.Instantiate(self._adapter, self._container);
	self.adapter = self:CreateCustomComponent(WardrobeRecycleSkinList, go, self);
	local charList = {}
  UISender.me:SendRequest(CS.Torappu.Network.ServiceCode.SHOP_SKIN_LIST, 
    {
    	charIdList = charList
    }, 
    {
      onProceed = Event.Create(self, self._RefreshReponseContent);

      onBlock = Event.CreateStatic(function(error)
        return true;
			end);
			hideMask = true
    });
	self:_RefreshView()
end

function WardrobeSortByTimeState:OnResume()
	self:_RefreshView()
end

function WardrobeSortByTimeState:CheckData(data)
	self:_RefreshView()
	if (self.initFlag) then
		self:EntryEffect()
	end
end

function WardrobeSortByTimeState:GetTransInfo()
	return self.initFlag and not self.onFadeIn and self.effectFlag , self.stateBean.skinList
end

function WardrobeSortByTimeState:ChangeClickShowUnlockFlag()
	self:_RefreshView()
end

function WardrobeSortByTimeState:_RefreshView()
	if (self.adapter~=nil) then
		self.adapter.showUnGetFlag = WardrobeUtil.GetSkinUnGetFlag()
		self.adapter:NotifyDataChanged()
	end
end

function WardrobeSortByTimeState:OnClick(time,skinId)
	local skinIdList = {}
	local skinShopList = {}
	local timeGroupSkinList = self.stateBean.skinList

	for indexTime,skinList in pairs(timeGroupSkinList)do
		if (indexTime.year == time.year and indexTime.period == time.period) then
			for k,v in pairs(skinList) do
				if (v.onSale) then
					table.insert(skinShopList,v.shopData)
				else
					table.insert(skinIdList,v.data.skinId)
				end			
			end
			break
		end
	end
	if (#skinIdList + #skinShopList > 0) then
		CS.Torappu.UI.Skin.SkinPage.OpenPageForMultiSkinList(skinId,skinShopList,skinIdList)
	end
end


function WardrobeSortByTimeState:_RefreshViewModel(obj)
	
	local skinData = CS.Torappu.SkinDB.data.charSkins
	local currentTime =  CS.Torappu.DateTimeUtil.timeStampNow
	for skinId, skinDetail in pairs(skinData) do
		if (skinDetail:IsBuyAble() and skinDetail.displaySkin.getTime< currentTime) then

			local getTime
			local flag = false
			for key, value in pairs(self.stateBean.skinList) do
				if (key.year == skinDetail.displaySkin.onYear and key.period == skinDetail.displaySkin.onPeriod) then
					getTime = key
					flag = true
				end
			end
			if (not flag) then
				getTime = {}
				getTime.year = skinDetail.displaySkin.onYear
				getTime.period = skinDetail.displaySkin.onPeriod
			end
			if (self.stateBean.skinList[getTime] == nil) then
				self.stateBean.skinList[getTime] = {}
			end
			local skinInfo = {}
			skinInfo.data = skinDetail			
			skinInfo.onSale = false
			for i, shopSkin in pairs(obj.goodList) do
				if (shopSkin.skinId == skinDetail.skinId) then
					skinInfo.shopData = shopSkin
					if (CheckTimeAvailWithTimeStamp(shopSkin.startDateTime, shopSkin.endDateTime)) then
						skinInfo.onSale = true
					end
					break
				end
			end
			table.insert( self.stateBean.skinList[getTime],skinInfo)
		end
	end
	for i,shopskin in pairs (self.stateBean.skinList) do
		table.sort(shopskin, function(a, b)
			if (a.onSale ~= b.onSale) then
				return a.onSale
			end
			if (a.data.displaySkin.getTime ~= b.data.displaySkin.getTime)then
				return a.data.displaySkin.getTime < b.data.displaySkin.getTime
			end
			return a.data.displaySkin.sortId < b.data.displaySkin.sortId 
		end);
	end
end

function WardrobeSortByTimeState:_RefreshReponseContent(obj)
	self:_RefreshViewModel(obj)
	local skinArray = {}
	for i, shopSkin in pairs(self.stateBean.skinList) do
		if (#shopSkin > 5) then
			local frontPart = {}
			local endPart = {}
			for j, skin in pairs(shopSkin) do
				if (j > 5) then
					table.insert(endPart,skin)
				else
					table.insert(frontPart,skin)
				end
			end
			local frontObj = {}
			frontObj.time = i
			frontObj.showTime = true
			frontObj.skinList = frontPart
			table.insert(skinArray, frontObj)
			local endObj = {}
			endObj.time = i
			endObj.showTime = false
			endObj.skinList = endPart
			table.insert(skinArray, endObj)
		else
			local temp = {}
			temp.time = i
			temp.showTime = true
			temp.skinList = shopSkin
			table.insert(skinArray, temp)
		end
	end
	table.sort(skinArray, 
		function(a, b)
			if (a.time.year ~= b.time.year) then
				return (a.time.year > b.time.year) 
			end
			if (a.time.period ~= b.time.period) then
				return (a.time.period > b.time.period) 
			end
			if (a.showTime ~= b.showTime) then
				return (a.showTime) 
			end
			return false
		end
	)
	self.adapter.viewModelList = skinArray
	self.adapter.showUnGetFlag = self.showUnGetFlag
	self.initFlag = true
	self:EntryEffect()
end

function WardrobeSortByTimeState:EntryEffect()
	if (self.initFlag == false) then
		return
	end
	self.adapter.overwriteFlag = false
	self.adapter.effectState = 0
	self.effectFlag = false
	self._rootCanvas.blocksRaycasts = false
	self.adapter:NotifyDataSourceChanged()
	self.adapter:ResetToTop()
	self:Delay(0.3,self.ShowFirstEffect)
	self:Delay(0.4,self.ShowSecondEffect)
	self:Delay(0.5,self.ShowBanFlag)
end

function WardrobeSortByTimeState:ShowFirstEffect()
self.adapter.effectState = 1
self.adapter:NotifyDataSourceChanged()
end

function WardrobeSortByTimeState:ShowSecondEffect()
	self.adapter.effectState = 2
	self.adapter:NotifyDataSourceChanged()
end

function WardrobeSortByTimeState:ShowBanFlag()
	self.adapter.effectState = -1
	self.effectFlag = true
	self.adapter.overwriteFlag = true
	self._rootCanvas.blocksRaycasts = true
	self.adapter:NotifyDataSourceChanged()
end
