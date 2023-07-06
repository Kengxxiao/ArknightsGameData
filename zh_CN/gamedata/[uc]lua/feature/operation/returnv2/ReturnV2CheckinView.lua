local ReturnV2CheckinRewardModel = require("Feature/Operation/ReturnV2/ReturnV2CheckinRewardModel")
local ReturnV2CheckinItemView = require("Feature/Operation/ReturnV2/ReturnV2CheckinItemView")
local ReturnV2CheckinDotView = require("Feature/Operation/ReturnV2/ReturnV2CheckinDotView")














local ReturnV2CheckinView = Class("ReturnV2CheckinView", UIPanel)

ReturnV2CheckinView.ITEM_WIDTH = 20


function ReturnV2CheckinView:OnViewModelUpdate(data)
  if data == nil then
    return
  end

  if data.tabState ~= ReturnV2StateTabStatus.STATE_TAB_CHECKIN then
    return
  end
  self.m_viewModel = data

  self:_InitIfNot()

  self:_UpdateEndTimeText(data)
  self:_UpdateDotSlider(data)
  self:_UpdateListSpacing(data)
  self.m_signListAdapter:NotifyDataSetChanged()
  self.m_dotListAdapter:NotifyDataSetChanged()
end


function ReturnV2CheckinView:_UpdateEndTimeText(viewModel)
  local endTime = viewModel.missionEndTime;
  if endTime then
    local endDateTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(endTime);
    self._endTimeText.text = CS.Torappu.FormatUtil.FormatDateTimeyyyyMMddHHmm(endDateTime);
  end
end


function ReturnV2CheckinView:_UpdateDotSlider(viewModel)
  local sliderVal = 0
  local signList = viewModel:GetCheckInItemList()
  local signCnt = #signList
  if signList ~= nil and signCnt ~= 0 then
    local availCount = 0
    for i=1, signCnt do
      local itemModel = signList[i]
      if itemModel:GetState() >= ReturnV2CheckinRewardModel.SIGN_REWARD_STATE.CAN_GAIN then
        availCount = availCount + 1
      end
    end

    if signCnt > 1 and availCount > 0 then
      sliderVal = (availCount-1) / (signCnt-1)
    else
      sliderVal = 0
    end
  end
  self._dotSlider.value = sliderVal
end


function ReturnV2CheckinView:_UpdateListSpacing(viewModel)
  local dotCount = 0
  local signList = viewModel:GetCheckInItemList()
  if signList ~= nil then
    dotCount = #signList
  end

  local dotCount = self:_GetDotItemCount()
  local listSpacing = 0
  if dotCount > 1 then
    local listWidth = self._dotLayoutRt.rect.width
    listSpacing = (listWidth - dotCount*self.ITEM_WIDTH) / (dotCount-1)
  end
  self._dotLayoutGruop.spacing = listSpacing
end


function ReturnV2CheckinView:_InitIfNot()
  if self.m_hasInited then
    return
  end
  self.m_hasInited = true

  self.m_signListAdapter = self:CreateCustomComponent(
      UISimpleLayoutAdapter, self, self._signItemList, self._CreateRewardItemView,
      self._GetRewardItemCount, self._UpdateRewardItemView)
  self.m_dotListAdapter = self:CreateCustomComponent(
      UISimpleLayoutAdapter, self, self._dotList, self._CreateDotItemView,
      self._GetDotItemCount, self._UpdateDotItemView)
end



function ReturnV2CheckinView:_CreateDotItemView(gameObj)
  local itemView = self:CreateWidgetByGO(ReturnV2CheckinDotView, gameObj)
  return itemView
end


function ReturnV2CheckinView:_GetDotItemCount()
  local signList = self.m_viewModel:GetCheckInItemList()
  if signList == nil then
    return 0
  end
  return #signList
end




function ReturnV2CheckinView:_UpdateDotItemView(index, itemView)
  local luaIndex = index + 1
  local signList = self.m_viewModel:GetCheckInItemList()
  local isLatest = self.m_viewModel:GetActiveCheckinCount() == luaIndex

  itemView:Render(signList[luaIndex], isLatest)
end



function ReturnV2CheckinView:_CreateRewardItemView(gameObj)
  local itemView = self:CreateWidgetByGO(ReturnV2CheckinItemView, gameObj)
  return itemView
end


function ReturnV2CheckinView:_GetRewardItemCount()
  local signList = self.m_viewModel:GetCheckInItemList()
  if signList == nil then
    return 0
  end
  return #signList
end




function ReturnV2CheckinView:_UpdateRewardItemView(index, itemView)
  local luaIndex = index + 1
  local signList = self.m_viewModel:GetCheckInItemList()

  itemView.onSignItemClick = self.onSignItemClick
  itemView:Render(luaIndex, signList[luaIndex])
end

return ReturnV2CheckinView