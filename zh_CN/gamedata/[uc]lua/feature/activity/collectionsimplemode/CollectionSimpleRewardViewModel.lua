local luaUtils = CS.Torappu.Lua.Util










local CollectionSimpleRewardViewModel = Class("CollectionSimpleRewardViewModel")


function CollectionSimpleRewardViewModel:LoadData(actId)
  if not actId then
    return
  end
  local suc, actData = CS.Torappu.ActivityDB.data.activity.defaultCollectionData:TryGetValue(actId);
  if not suc then
    return;
  end
  local actConfig = CollectionActModel.me:GetActCfg(actId)
  self.themeColor = actConfig.baseColor
  self.m_collections = ToLuaArray(actData.collections)
  if #self.m_collections <= 0 then
    return
  end
  table.sort(self.m_collections, function(a, b) 
    return a.pointCnt < b.pointCnt
  end)
  
  local firstCollectionData = self.m_collections[1]
  self.totalRewardCount = #self.m_collections
  self.m_pointId = firstCollectionData.pointId
  self.rewardItemModel = CS.Torappu.UI.UIItemViewModel()
  self.rewardItemModel:LoadGameData(firstCollectionData.itemId, firstCollectionData.itemType)
end


function CollectionSimpleRewardViewModel:UpdateData(actId)
  if not actId then
    return
  end
  local suc, collectStatus = CS.Torappu.PlayerData.instance.data.activity.collectionActivityList:TryGetValue(actId)
  if not suc then
    return
  end
  local suc, pointCurCnt = collectStatus.point:TryGetValue(self.m_pointId)
  self.currentPointCount = pointCurCnt
  local claimedRewardCount = 0
  local findUnfinishedCollection = false
  local reachedCollectionPointCount = 0
  local reachedCollectionLevel = 0
  for index, collectionData in pairs(self.m_collections) do
    if not findUnfinishedCollection then
      if self.currentPointCount < collectionData.pointCnt then
        findUnfinishedCollection = true
        self.nextRewardNeedPoint = collectionData.pointCnt
      end
    end
    if self.currentPointCount >= collectionData.pointCnt then
      reachedCollectionPointCount = collectionData.pointCnt
      reachedCollectionLevel = index
    end
    if collectStatus.history:ContainsKey(collectionData.id) then
      claimedRewardCount = claimedRewardCount + 1
    end
  end
  if not findUnfinishedCollection then
    self.nextRewardNeedPoint = -1
    self.collectionLevel = reachedCollectionLevel
  else
    self.collectionLevel = reachedCollectionLevel + (self.currentPointCount - reachedCollectionPointCount) / (self.nextRewardNeedPoint - reachedCollectionPointCount)
  end
  self.claimedRewardCount = claimedRewardCount
end

return CollectionSimpleRewardViewModel