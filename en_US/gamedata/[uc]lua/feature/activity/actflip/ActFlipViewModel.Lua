local luaUtils = CS.Torappu.Lua.Util






local ActFlipItemModel = Class("ActFlipItemModel")
local ActFlipGrandItemModel = Class("ActFlipGrandItemModel")












local ActFlipViewModel = Class("ActFlipViewModel")

ActFlipViewModel.skipIndex = {14,15,19,20}
ActFlipViewModel.maxIndex = 20
ActFlipViewModel.cardState = { 
  UNSELECT = 1,
  TOSELECT = 2,
  SELECTED = 3,
  GET = 4,
  GET_TODAY = 5
}
ActFlipViewModel.GrandState = { 
  UNGET = 0,
  GET = 1,
  FINISH = 2,
}

function ActFlipViewModel:ctor()
  self.isSelected = false
  self.hasPrayed = false
  self.isConfirmedReward = false

  self.selectIndex = nil
  self.selectPos = nil
  self.grandType = nil
end

function ActFlipViewModel:InitData(actId)
  local playerFlipDict = CS.Torappu.PlayerData.instance.data.activity.flipOnlyActivityList;
  if actId == nil or playerFlipDict == nil then
    return;
  end
  local suc, playerFlip = playerFlipDict:TryGetValue(actId)
  self.itemList = {}
  self.isSelected = false
  self.receivedPrizeIds = {}
  if suc then
    self.raffleCount = playerFlip.raffleCount  
    self.todayRaffleCount = playerFlip.todayRaffleCount 
    self.remainingRaffleCount = playerFlip.remainingRaffleCount 
    self.luckyToday = playerFlip.luckyToday 
    self.grandType = playerFlip.grandStatus  

    local pos = 0
    for idx = 1, ActFlipViewModel.maxIndex do
      local item = {}
      item.index = idx
      if not self:isInclude(idx,ActFlipViewModel.skipIndex) then
        item.isShow = true;
        item.pos = pos;
        local _, normalRewards = playerFlip.normalRewards:TryGetValue(pos)
        pos = pos + 1;

        item.normalRewards = normalRewards
        if item.normalRewards ~= nil then
          table.insert(self.receivedPrizeIds, normalRewards.prizeId)
          local time1 = CS.Torappu.DateTimeUtil.TimeStampToDateTime(item.normalRewards.ts) 
          local same = CS.Torappu.DateTimeUtil.IsSameDay(time1, CS.Torappu.DateTimeUtil.currentTime)
          if CS.Torappu.DateTimeUtil.IsSameDay(time1, CS.Torappu.DateTimeUtil.currentTime) then
            item.cardType = ActFlipViewModel.cardState.GET_TODAY
          else
            item.cardType = ActFlipViewModel.cardState.GET
          end
        elseif self.remainingRaffleCount ~= nil and self.remainingRaffleCount <= 0 then
          item.cardType = ActFlipViewModel.cardState.UNSELECT
        else
          item.cardType = ActFlipViewModel.cardState.TOSELECT
        end
      else
        item.isShow = false
      end
      table.insert(self.itemList, item)
    end

    if self.remainingRaffleCount <= 0 then
      self.hasPrayed = true
    end
  end

  local suc, basicData = CS.Torappu.ActivityDB.data.basicInfo:TryGetValue(actId)
  if not suc then 
    return;
  end
  self.endTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(basicData.endTime)
  local ct = CS.Torappu.DateTimeUtil.currentTime
  self.isLastDay = CS.Torappu.DateTimeUtil.IsSameDay(ct, self.endTime)
end

function ActFlipViewModel:isInclude(value, tbl)
  for k,v in ipairs(tbl) do
    if v == value then
        return true
    end
  end
  return false
end

function ActFlipViewModel:_SetCardType(idx, type)
  self.itemList[idx].cardType = type
end

function ActFlipViewModel:_selectCard(idx, pos)
  if self.isSelected then
    if self.selectIndex ~= nil and self.itemList[self.selectIndex] ~= nil then
      if idx ~= self.selectIndex then
        self:_SetCardType(self.selectIndex, ActFlipViewModel.cardState.TOSELECT)
      else
        self:_SetCardType(idx, ActFlipViewModel.cardState.TOSELECT)
        self.selectIndex = nil
        self.selectPos = nil
        self.isSelected = false
        return
      end
    else
      error("choose one place before click")
    end
  end
  self:_SetCardType(idx, ActFlipViewModel.cardState.SELECTED)
  self.selectIndex = idx
  self.selectPos = pos
  self.isSelected = true
end

return ActFlipViewModel

