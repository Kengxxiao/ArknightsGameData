local CampaignDataUtil = CS.Torappu.CampaignDataUtil;









local OpenServerV3StageCampaignItemViewModel = Class("OpenServerV3StageCampaignItemViewModel");



OpenServerV3StageCampaignDlgViewModel = Class("OpenServerV3StageCampaignDlgViewModel", UIViewModel);




function OpenServerV3StageCampaignDlgViewModel:_CollectSortedStageCampaignData(stageCampaignDataList)
  local sortedDataList = {};
  if stageCampaignDataList == nil or stageCampaignDataList.Count <= 0 then
    return sortedDataList;
  end

  for index = 0, stageCampaignDataList.Count - 1 do
    local stageCampaignData = stageCampaignDataList[index];
    if stageCampaignData ~= nil then
      table.insert(sortedDataList, stageCampaignData);
    end
  end

  table.sort(sortedDataList, function(a, b)
    local sortIdA = a.sortId or 0;
    local sortIdB = b.sortId or 0;
    if sortIdA ~= sortIdB then
      return sortIdA < sortIdB;
    end
    local stageIdA = a.stageId or "";
    local stageIdB = b.stageId or "";
    return stageIdA < stageIdB;
  end);
  return sortedDataList;
end





function OpenServerV3StageCampaignDlgViewModel:_CreateStageCampaignItemModel(stageCampaignData, playerCampaign)
  local stageId = stageCampaignData.stageId;
  if stageId == nil or stageId == "" then
    return nil;
  end

  local campaignDataDict = CS.Torappu.CampaignDB.data.campaigns;
  if campaignDataDict == nil then
    return nil;
  end

  local ok, campaignData = campaignDataDict:TryGetValue(stageId);
  if not ok or campaignData == nil then
    return nil;
  end

  local stageType = CampaignDataUtil.GetStageType(stageId);
  local stateModel = CS.Torappu.UI.Campaign.CampaignStateViewModel(campaignData, stageType);

  if playerCampaign ~= nil and playerCampaign.instances ~= nil then
    local hasPlayerStage, playerStage = playerCampaign.instances:TryGetValue(stageId);
    if hasPlayerStage and playerStage ~= nil then
      stateModel:SetPlayerData(playerStage);
    end
  end

  local itemModel = OpenServerV3StageCampaignItemViewModel.new();
  itemModel.stageId = stageId;
  itemModel.stageCode = CampaignDataUtil.GetStageCode(stageId);
  itemModel.stageName = CampaignDataUtil.GetStageName(stageId);
  itemModel.zoneId = CampaignDataUtil.GetStageZone(stageId);
  itemModel.isUnlock = CampaignDataUtil.IsStageUnlocked(stageId);
  itemModel.unlockTip = CampaignDataUtil.GetOpenServerStageUnlockText(stageId);
  itemModel.imgId = CS.Torappu.UI.Campaign.CampaignZoneMapResUtil.GetCampaignStageImgId(stageId);
  itemModel.stateModel = stateModel;
  return itemModel;
end

function OpenServerV3StageCampaignDlgViewModel:LoadData()
  self.stageList = {};

  local gameData = OpenServerV3Model.me:GetGameData();
  if gameData == nil or gameData.stageCampaignData == nil or gameData.stageCampaignData.Count <= 0 then
    return;
  end

  local playerCampaign = CS.Torappu.PlayerData.instance.data.campaign;
  local sortedDataList = self:_CollectSortedStageCampaignData(gameData.stageCampaignData);
  for _, stageCampaignData in ipairs(sortedDataList) do
    local itemModel = self:_CreateStageCampaignItemModel(stageCampaignData, playerCampaign);
    if itemModel ~= nil then
      table.insert(self.stageList, itemModel);
    end
  end
end
