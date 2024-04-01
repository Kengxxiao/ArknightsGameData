local luaUtils = CS.Torappu.Lua.Util






local Act5FunBattleFinishUserItemModel = Class("Act5FunBattleFinishUserItemModel")














local Act5funBattleFinishViewModel = Class("Act4funBattleFinishViewModel")
local DEFAULT_THRESHOLD_COUNT = 999999999

function Act5funBattleFinishViewModel:InitData()
  local playerData = CS.Torappu.PlayerData.instance.data
  local outPut = CS.Torappu.Battle.BattleInOut.instance.output;
  local finishResp = outPut.finishResponse;
  local act5FunData = CS.Torappu.ActivityDB.data.actFunData.act5FunData

  self.isGettingReward = false
  self.guideStageId = CS.Torappu.Battle.BattleInOut.instance.input.stageInfo.stageId
  self.name = luaUtils.Format("{0}#{1}", playerData.status.nickName, playerData.status.nickNumber)
  self.coinCount = finishResp.score
  self.needSkip = finishResp.result == 1
  self.isNewRecord = finishResp.isHighScore
  self.winCount = finishResp.playerResult.totalWin
  self.totalCount = finishResp.playerResult.totalRound
  local streak = finishResp.playerResult.streak
  
  self.winningStreakStr = ''
  self.wordStr = ''
  self.userInfoList = {}
  self.userInfoCount = 0
  self.thresholdCount = DEFAULT_THRESHOLD_COUNT
  if act5FunData ~= nil then
    local constData = act5FunData.constData  
    if constData ~= nil then
      self.thresholdCount = constData.maxFund
    end
    
    local streakData = act5FunData.streakData
    if streakData ~= nil then
      for i = 0, streakData.Count - 1 do
        local streakDataItem = streakData[i]
        if streakDataItem ~= nil and streakDataItem.count == streak then
          self.winningStreakStr = streakDataItem.desc
          break
        end
      end
    end

    local ratingData = act5FunData.ratingData
    if ratingData ~= nil then
      for i = 0, ratingData.Count - 1 do
        local ratingDataItem = ratingData[i]
        if ratingDataItem ~= nil and ratingDataItem.minRating <= self.coinCount and ratingDataItem.maxRating >= self.coinCount then
          self.wordStr = ratingDataItem.ratingDesc
          break
        end
      end
    end

    local npcData = act5FunData.npcData
    local npcResult = finishResp.npcResult
    local successData = act5FunData.successData
    if npcResult ~= nil then
      for id, count in pairs(npcResult) do
        if id ~= nil and npcData ~= nil then
          local suc, npcDataItem = npcData:TryGetValue(id)
          if suc then
            local userItemInfo = Act5FunBattleFinishUserItemModel.new()
            userItemInfo.iconId = npcDataItem.avatarId
            userItemInfo.nameStr = npcDataItem.name
            local successStr = ''
            if successData ~= nil then
              for i = 0, successData.Count - 1 do
                local successDataItem = successData[i]
                if successDataItem ~= nil and successDataItem.count == count then
                  successStr = successDataItem.desc
                  break
                end
              end
            end
            userItemInfo.winningStreakStr = successStr
            userItemInfo.winningCount = count
            table.insert(self.userInfoList, userItemInfo)
            self.userInfoCount = self.userInfoCount + 1
          end
        end
      end
      table.sort(self.userInfoList, function(a, b)
        return a.winningCount > b.winningCount
      end)
    end
  end
  self:_DealWithReward(finishResp)
end

function Act5funBattleFinishViewModel:_DealWithReward(finishResp)
  local itemTable = nil
  local respItems = finishResp.reward
  if respItems ~= nil and respItems.Count > 0 then
    itemTable = {}
    for idx = 0, respItems.Count - 1 do
      local respItem = respItems[idx]
      local item = self:_CreateItemBundle(respItem.id, respItem.type, respItem.count)
      table.insert(itemTable, item)
    end
  end
  if itemTable ~= nil then
    self.isGettingReward = true
    local meta = CS.Torappu.Battle.BattleInOut.instance.input.actMeta.meta
    meta:SetDataBundleList(ActFunMainDlgGroup.KEY_REWARD, itemTable)
  end
end 

function Act5funBattleFinishViewModel:_CreateItemBundle(id, type, count)
  local bundle = CS.Torappu.DataBundle()
  bundle:SetString("id", id)
  bundle:SetString("type", type:ToString())
  bundle:SetInt("count", count)
  return bundle
end

return Act5funBattleFinishViewModel