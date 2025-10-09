local luaUtils = CS.Torappu.Lua.Util




local TeamQuestRecordViewModel  = Class("TeamQuestRecordViewModel", nil)
local TeamQuestUtil = require("Feature/Activity/TeamQuest/TeamQuestUtil")



local TeamQuestRecordDetailViewModel  = Class("TeamQuestRecordDetailViewModel", nil)



function TeamQuestRecordViewModel:Init(actId, response)
	self.actId = actId
  local actDBData = CS.Torappu.ActivityDB.data
  if actDBData == nil or actDBData.dynActs == nil then
    return
  end

  local suc1, jObject = actDBData.dynActs:TryGetValue(actId)
  if not suc1 then
    LogError("[TeamQuest]Can't find the activity data: " .. actId)
    return
  end

  local actData = luaUtils.ConvertJObjectToLuaTable(jObject)
	self.themeColor = actData.constData.themeColor

	self.recordViewModel = {}
	self.friendViewModel = {}
	self.playerData = TeamQuestUtil.GetPlayerData(actId)
	for key,value in pairs(self.playerData.share.showData) do
		local shareInfo = {}			
		shareInfo.id = key
		shareInfo.value = value
		shareInfo.themeColor = self.themeColor
		for _,v in pairs(actData.shareInfoData) do
			if (v.shareId == key)then
				shareInfo.data = v
				break;
			end
		end
		table.insert(self.recordViewModel, shareInfo)
	end
	table.sort(self.recordViewModel, function(a, b)
		return a.data.shareDataOrder < b.data.shareDataOrder;
	end)
	self.friendViewModel = {}
	for _,v in pairs(response.players) do
    	table.insert(self.friendViewModel, v)
	end
end

function TeamQuestRecordViewModel:ExportFriendModel()
	
	local layoutContentModel = CS.Torappu.UI.CrossAppShare.CrossAppShareSimpleLayoutContentModel()
	layoutContentModel.viewModelList = CS.System.Collections.Generic.List(CS.Torappu.UI.CrossAppShare.CrossAppShareComponentBaseModelDict)()
	layoutContentModel.isActive = true

	
	if self.friendViewModel and #self.friendViewModel > 0 then
		for i, friendData in ipairs(self.friendViewModel) do
			local friendCollector = CS.Torappu.UI.CrossAppShare.CrossAppShareComponentBaseModelDict()

			local headIconModel = CS.Torappu.UI.CrossAppShare.CrossAppSharePlayerInfoModel()
			headIconModel.avatarInfo = friendData.avatar
		  headIconModel.nickName = luaUtils.Format("<color=#FFFFFF>{0}</color>", friendData.nickName)
			headIconModel.nickNum = luaUtils.Format("<color=#FFFFFFA8>{0}</color>", friendData.nickNumber)
			headIconModel.isActive = true
			friendCollector:Add("headIcon", headIconModel)

			local spineModel = CS.Torappu.UI.CrossAppShare.CrossAppShareCharSpineModel()
			spineModel.skinId = friendData.secretarySkinId
			spineModel.isActive = true
			friendCollector:Add("spine", spineModel)

			if friendCollector then
				layoutContentModel.viewModelList:Add(friendCollector)
			end
		end
	end
	
	return layoutContentModel
end


function TeamQuestRecordViewModel:ExportDetailModel()
	
	local layoutContentModel = CS.Torappu.UI.CrossAppShare.CrossAppShareSimpleLayoutContentModel()
	layoutContentModel.viewModelList = CS.System.Collections.Generic.List(CS.Torappu.UI.CrossAppShare.CrossAppShareComponentBaseModelDict)()
	layoutContentModel.isActive = true
  local targetColor = CS.Torappu.ColorRes.TweenHtmlStringToColor(self.themeColor);

	
	if self.recordViewModel and #self.recordViewModel > 0 then
		for i, recordViewModel in ipairs(self.recordViewModel) do
			local recordCollector = CS.Torappu.UI.CrossAppShare.CrossAppShareComponentBaseModelDict()
			local numText = CS.Torappu.UI.CrossAppShare.CrossAppShareTextModel()
			numText.text = recordViewModel.value
			numText.color = targetColor
			numText.isActive = true
			recordCollector:Add("num", numText)

			local titleText = CS.Torappu.UI.CrossAppShare.CrossAppShareTextModel()
			titleText.text = recordViewModel.data.shareName
			titleText.color = targetColor
			titleText.isActive = true
			recordCollector:Add("title", titleText)


			local targetIcon = CS.Torappu.UI.CrossAppShare.CrossAppShareDynImageModel()
			targetIcon.spritePath = CS.Torappu.ResourceUrls.GetActTeamQuestIconImagePath(recordViewModel.data.sharePic)
			targetIcon.color = targetColor
			targetIcon.isActive = true
			recordCollector:Add("icon", targetIcon)


			if recordCollector then
				layoutContentModel.viewModelList:Add(recordCollector)
			end
		end
	end
	
	return layoutContentModel
end


function TeamQuestRecordViewModel:ExportShareModel()
	
	local shareModel = CS.Torappu.UI.CrossAppShare.SimpleCrossAppShareRemakeModel()
	
	
	local mainLayoutContentModel = CS.Torappu.UI.CrossAppShare.CrossAppShareLayoutContentModel()
	mainLayoutContentModel.elementModels = CS.System.Collections.Generic.List(CS.Torappu.UI.CrossAppShare.CrossAppShareElementModelCollector)()
	
	
	local friendLayoutContent = self:ExportFriendModel()

	
	
	local detailLayoutContent = self:ExportDetailModel()

	local modelDict = {}
	modelDict["friend"] = friendLayoutContent
	modelDict["detail"] = detailLayoutContent	

	local dynResGroup = CS.Torappu.UI.CrossAppShare.CrossAppShareCharActResDynModel()
	dynResGroup.needActId = true
	dynResGroup.needColorId = true
	dynResGroup.actId = self.actId
	dynResGroup.colorId = self.themeColor
	dynResGroup.isActive = true
	modelDict["actCommon"] = dynResGroup

	
	shareModel.compModelDict = modelDict

	
	return shareModel
end


return TeamQuestRecordViewModel