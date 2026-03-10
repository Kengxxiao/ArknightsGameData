














local ReturnNewsItemViewModel = Class("ReturnNewsItemViewModel", nil);


function ReturnNewsItemViewModel:ctor(newsData)
  self.id = newsData.groupId;
  self.sortId = newsData.sortId;
  self.title = newsData.title;
  self.desc = newsData.desc;
  self.tag = newsData.tabTitle;
  self.imgId = newsData.imgId;
  self.iconId = newsData.iconId;
  self.newsType = newsData.jumpType;
  self.jumpDestination = newsData.jumpPlace;
  self.typeIconId = newsData.tabIcon;
  self.stoneTotal = 0;
  self.isSelected = false;
  self:LoadData();
end

function ReturnNewsItemViewModel:LoadData()
  if (self.newsType == CS.Torappu.ReturnNewsType.ROGUE) then
    self:_LoadRogueData();
  elseif (self.newsType == CS.Torappu.ReturnNewsType.SANDBOX) then
    self:_LoadSandboxData();
  elseif (self.newsType == CS.Torappu.ReturnNewsType.MAIN_SS) then
    self:_LoadMainlineData();
  end
end

function ReturnNewsItemViewModel:_LoadMainlineData()
  local ok, zoneData = CS.Torappu.ZoneDB.data.zones:TryGetValue(self.jumpDestination);
  if (zoneData ~= nil) then
    self.stoneTotal = zoneData.diamondRewardCount;
  end
  
  local sixStarMilestoneGroupId = zoneData.sixStarMilestoneGroupId;
  local ok, sixStarMilestoneGroupData = CS.Torappu.StageDB.data.sixStarMilestoneInfo:TryGetValue(sixStarMilestoneGroupId);
  if (sixStarMilestoneGroupData ~= nil) then
    local milestoneList = ToLuaArray(sixStarMilestoneGroupData.milestoneDataList);
    for index1, milestoneData in ipairs(milestoneList) do
      local rewardList = ToLuaArray(milestoneData.rewardList);
      if (rewardList ~= nil) then
        for index2, item in ipairs(rewardList) do
          if item.type == CS.Torappu.ItemType.DIAMOND then
            self.stoneTotal = self.stoneTotal + 1;
          end
        end
      end
    end
  end
  local ok, actId = CS.Torappu.ActivityDB.data.zoneToActivity:TryGetValue(self.jumpDestination);
  if (not ok or actId == nil) then
    return;
  end
  
  local activeActList = CS.Torappu.UI.ActivityUtil.FindValidActs(CS.Torappu.ActivityType.TYPE_MAINSS);
  if (activeActList ~= nil and activeActList:Contains(actId)) then
    self.jumpType = ReturnNewsJumpType.ACTIVITY;
    local alert = nil;
    self.jumpDestination = actId;
  else
    self.jumpType = ReturnNewsJumpType.ZONE;
    
    local mainlineZoneList = CS.Torappu.ZoneDB.data.mainlineZoneIdList;
    if (mainlineZoneList == nil or mainlineZoneList.Count == 0) then
      return;
    end
    for index = mainlineZoneList.Count - 1, 0, -1 do
      local zoneId = mainlineZoneList[index];
      local preposedStage = CS.Torappu.StageDataUtil.GetMainlineAndRetroPreposedStageData(zoneId);
      if (preposedStage == nil) then
        self.jumpDestination = zoneId;
        break;
      end
      if (CS.Torappu.StageDataUtil.CheckIfStageUnlocked(preposedStage.stageId)) then
        local avail, playerStage = CS.Torappu.StageDataUtil.TryGetAvailStage(preposedStage.stageId);
        if (avail and playerStage ~= nil and playerStage.state == CS.Torappu.PlayerStageState.COMPLETE) then
          self.jumpDestination = zoneId;
          break;
        end
      end
    end
  end
end

function ReturnNewsItemViewModel:_LoadSandboxData()
  self.jumpType = ReturnNewsJumpType.SANDBOX;
  self.rewardItems = {};
  UISender.me:SendRequest(
    ReturnServiceCode.GET_NEWS_REWARD_SHOW,
    {
      shopIdList = { self.jumpDestination },
    }, 
    {
      hideMask = true,
      onProceed = Event.Create(self, self._HandleLoadSandboxData)
    }
  );
end


function ReturnNewsItemViewModel:_HandleLoadSandboxData(response)
  local shopInfo = response.shopInfo;
  local goodList = shopInfo[self.jumpDestination];
  if (goodList == nil) then
    return;
  end
  local ok, playerTemplateShopData = CS.Torappu.PlayerData.instance.data.tshop:TryGetValue(self.jumpDestination);
  if (not ok or playerTemplateShopData == nil) then
    return;
  end
  local playerGoodList = ToLuaArray(playerTemplateShopData.info);
  local shopGoodDict = {}
  for index, shopGood in ipairs(playerGoodList) do
    shopGoodDict[shopGood.id] = shopGood.count;
  end
  for index, shopGood in ipairs(goodList) do
    if (shopGoodDict[shopGood.goodId] == nil or shopGood.availCount > shopGoodDict[shopGood.goodId]) then
      table.insert(self.rewardItems, CS.Torappu.ReturnItemData(
          shopGood.item.id, CS.Torappu.ItemType[shopGood.item.type], shopGood.item.count, index));
    end
  end
end

function ReturnNewsItemViewModel:_LoadRogueData()
  self.jumpType = ReturnNewsJumpType.ROGUE;
  self.rewardItems = {};
  
  local battlePassData = CS.Torappu.RoguelikeDataUtil.GetPlayerBattlePass(self.jumpDestination);
  local ok, rogueData = CS.Torappu.RoguelikeTopicDB.data.details:TryGetValue(self.jumpDestination);
  if (rogueData == nil or rogueData.milestones == nil or battlePassData == nil) then
    return;
  end
  local milestoneList = ToLuaArray(rogueData.milestones);
  local bpLimit = CS.Torappu.RoguelikeDataUtil.GetCurrRoguelikeTopicBpLimit(self.jumpDestination);
  for index, milestone in ipairs(milestoneList) do
    if (milestone ~= nil and milestone.isReturnDisplay and
        not battlePassData.reward:ContainsKey(milestone.id) and milestone.tokenNum <= bpLimit) then
      table.insert(self.rewardItems, CS.Torappu.ReturnItemData(
          milestone.itemID, milestone.itemType, milestone.itemCount, milestone.returnSortId));
    end
  end
  table.sort(self.rewardItems, function(a, b)
    return a.sortId < b.sortId;
  end);
end




local ReturnNewsViewModel = Class("ReturnNewsViewModel", nil);

function ReturnNewsViewModel:LoadData()
  self.newsList = {};
  local gameData = ReturnModel.me:GetGameData();
  if (gameData == nil or gameData.newsDataMap == nil) then
    return;
  end
  local playerData = ReturnModel.me:GetPlayerData();
  if (playerData == nil or playerData.currentV2 == nil or playerData.currentV2.groupId == nil) then
    return;
  end
  local groupId = playerData.currentV2.groupId;
  local ok, groupData = gameData.groupDataMap:TryGetValue(groupId);
  if (groupData == nil or groupData.newsGroupId == nil) then
    return;
  end
  local newsGroupIdList = ToLuaArray(groupData.newsGroupId);
  for index, newsGroupId in ipairs(newsGroupIdList) do
    local ok, newsData = gameData.newsDataMap:TryGetValue(newsGroupId);
    if (newsData ~= nil) then
      
      local newsItemModel = ReturnNewsItemViewModel.new(newsData);
      table.insert(self.newsList, newsItemModel);
    end
  end
  if #self.newsList == 0 then
    return;
  end
  self.newsList[1].isSelected = true;
  self.selectedModel = self.newsList[1];
end


function ReturnNewsViewModel:SetSelection(selectedId)
  for index, newsItemModel in ipairs(self.newsList) do
    if (newsItemModel.id == selectedId) then
      newsItemModel.isSelected = true;
      self.selectedModel = newsItemModel;
    else
      newsItemModel.isSelected = false;
    end
  end
end

return ReturnNewsViewModel;