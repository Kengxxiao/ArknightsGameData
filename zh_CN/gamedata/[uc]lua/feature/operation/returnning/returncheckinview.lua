local luaUtils = CS.Torappu.Lua.Util














local ReturnCheckinView = Class("ReturnCheckinView", UIPanel)

local ReturnCheckinItem = require("Feature/Operation/Returnning/ReturnCheckinItem")
local ReturnCheckinDot = require("Feature/Operation/Returnning/ReturnCheckinProgressDot")

local SERVER_ITEM_COLLECT_STATE = {
  AVAILABLE = 1,
  RECEIVED = 0
}
function ReturnCheckinView:OnInit()
  self.m_currentData = CS.Torappu.PlayerData.instance.data.backflow.current
  self.checkinRewardList = CS.Torappu.OpenServerDB.returnData.checkinRewardList
end

function ReturnCheckinView:RenderDots()
  if self.checkinRewardList == nil then
    return false
  end
  local dotNum = self.checkinRewardList.Count 
  if dotNum <= 1 then
    return false
  end
  local posDiff = self._progressAnchorRight.position - self._progressAnchorLeft.position
  local singleDiff = posDiff / (dotNum - 1)
  if self.m_progressDots == nil then
    self.m_progressDots = {}
    for index = 0, dotNum-1 do
      local dotObj = self:CreateWidgetByPrefab(ReturnCheckinDot, self._checkinDotPrefab, self._dotContainerRect)
      dotObj:RootGameObject().transform.position = self._progressAnchorLeft.position + index * singleDiff
      table.insert(self.m_progressDots,dotObj)
    end
  end
  local checkinHistory = self.m_currentData.checkIn.history
  if checkinHistory == nil then
    return false
  end
  if checkinHistory.Count == 0 then
    return false
  end
 
  for idx = 1, dotNum do
    local csIdx = idx - 1
    local dotState = nil
    local colletable = idx <= checkinHistory.Count

    if idx == checkinHistory.Count and checkinHistory[csIdx] == SERVER_ITEM_COLLECT_STATE.AVAILABLE then
      dotState = ReturnCheckinDot.DOT_STATE.CURRENT
    elseif self.checkinRewardList[csIdx].isImportant then
      dotState = ReturnCheckinDot.DOT_STATE.IMPORTANT
    else
      dotState = ReturnCheckinDot.DOT_STATE.NORMAL
    end
    local dotTar = self.m_progressDots[idx]
    dotTar:SetState(dotState,colletable)
    dotTar:Render()
  end
  
  local currentDotIndex = checkinHistory.Count
  if currentDotIndex > dotNum or currentDotIndex == 0 then
    return false
  end
  local currentDotPos = self.m_progressDots[currentDotIndex]:RootGameObject().transform.position
  local leftDiffWorldPercent = math.abs((currentDotPos - self._progressAnchorLeft.position).x / posDiff.x)
  local rightDiffWorldPercent= 1 - leftDiffWorldPercent
  local anchoredDiffLength = (self._progressAnchorRight.anchoredPosition - self._progressAnchorLeft.anchoredPosition).x
  self._progressLineLeft.sizeDelta = CS.UnityEngine.Vector2(anchoredDiffLength * leftDiffWorldPercent, self._progressLineLeft.sizeDelta.y)
  self._progressLineRight.sizeDelta = CS.UnityEngine.Vector2(anchoredDiffLength * rightDiffWorldPercent, self._progressLineRight.sizeDelta.y)
  return true
end

function ReturnCheckinView:RenderItems()
  if self.checkinRewardList == nil then
    return
  end
  local rewardNum = self.checkinRewardList.Count
  if rewardNum == 0 then
    return
  end
  if self.m_checkinItemList == nil then
    self.m_checkinItemList = {}
    for idx = 1, rewardNum do
      local itemObj = self:CreateWidgetByPrefab(ReturnCheckinItem, self._itemCardPrefab, self._itemContainerRect)
      itemObj:Bind(self)
      table.insert(self.m_checkinItemList,itemObj)
    end
  end
  local checkinHistory = self.m_currentData.checkIn.history
  if checkinHistory.Count == 0 then
    return
  end
  for idx = 1, rewardNum do
    local csIdx = idx - 1
    local curItem = self.m_checkinItemList[idx]
    local itemState = 0
    if idx > checkinHistory.Count then
      itemState = ReturnCheckinItem.ITEM_STATE.UNCOLLETABLE
    else
      if checkinHistory[csIdx] == SERVER_ITEM_COLLECT_STATE.AVAILABLE then
        itemState = ReturnCheckinItem.ITEM_STATE.COLLECTABLE
      elseif checkinHistory[csIdx] == SERVER_ITEM_COLLECT_STATE.RECEIVED then
        itemState = ReturnCheckinItem.ITEM_STATE.COLLECTED
      end
    end
    local itemBundleFirst = self.checkinRewardList[csIdx].checkinRewardItems[0]
    local itemBundleSecond = self.checkinRewardList[csIdx].checkinRewardItems[1]
    if itemBundleFirst == nil or itemBundleSecond == nil then
      return
    end
    curItem:SetState(itemState,itemBundleFirst, itemBundleSecond, idx)
    curItem:Render()
  end

end
function ReturnCheckinView:Render()
  self.m_currentData = CS.Torappu.PlayerData.instance.data.backflow.current
  local result = self:RenderDots()
  SetGameObjectActive(self._dotContainerRect.gameObject, result)
  self:RenderItems()
  self:RenderEndTimeText()
end

function ReturnCheckinView:RenderEndTimeText()
  local startTime = self.m_currentData.start
  local endDateTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(startTime):AddDays(CS.Torappu.OpenServerDB.returnData.constData.systemTab_time)
  local timedesc = CS.Torappu.Lua.Util.Format(CS.Torappu.StringRes.DATE_FORMAT_YYYY_MM_DD_HH_MM, endDateTime.Year, endDateTime.Month, endDateTime.Day, endDateTime.Hour,endDateTime.Minute);
  self._endTimeText.text = timedesc
end


function ReturnCheckinView:_ClaimCheckinItemGetResponse(response)
  CS.Torappu.Activity.ActivityUtil.DoShowGainedItems(response.items)
  self:Render()
  TrackPointModel.me:UpdateNode(ReturnCheckInTabTrackPoint)
end



function ReturnCheckinView:_EventOnClaimRewardClick(index)
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return
  end
  local checkinHistory = self.m_currentData.checkIn.history
  if index > checkinHistory.Count then
    return;
  end
  if checkinHistory[index-1] ~= SERVER_ITEM_COLLECT_STATE.AVAILABLE then
    return;
  end

  UISender.me:SendRequest(ReturnServiceCode.GET_SIGNIN_REWARD,
  {
    index = index - 1
  },
  {
    onProceed = Event.Create(self, self._ClaimCheckinItemGetResponse);
  })
end

return ReturnCheckinView