local luaUtils = CS.Torappu.Lua.Util
local dateUtil = CS.Torappu.DateTimeUtil
local FULL_OPEN_STATE = ReturnV2MainDlgViewModel.FULL_OPEN_STATE












local ReturnV2SpecialOpenView = Class("ReturnV2SpecialOpenView", UIPanel)


function ReturnV2SpecialOpenView:OnViewModelUpdate(data)
  if data == nil then
    return
  end

  if data.tabState ~= ReturnV2StateTabStatus.STATE_TAB_ALL_OPEN then
    return
  end
  self.m_model = data
  
  self:_InitIfNot()
  self:_RenderView()
end

function ReturnV2SpecialOpenView:_InitIfNot()
  if self.m_hasInited then
    return
  end
  self.m_hasInited = true

  self:AddButtonClickListener(self._goButton, self._EventOnGoToSpecialOpen)
end

function ReturnV2SpecialOpenView:_EventOnGoToSpecialOpen()
  CS.Torappu.UI.UIRouteUtil.RouteToZoneViewType(CS.Torappu.UI.Stage.ZoneViewType.WEEKLY);
end


function ReturnV2SpecialOpenView:_RenderView()
  self:_UpdateTimeText()
  self:_UpdateCurrentState()
end

function ReturnV2SpecialOpenView:_UpdateTimeText()
  local timeStr = ""
  local daysTextFormat = StringRes.DAY_TEXT
  if not self.m_model.isTodayFullOpen then
    
    timeStr = luaUtils.Format(daysTextFormat, self.m_model.fullOpenRemain)
  else
    
    
    local timeDays = self.m_model.fullOpenRemain - 1
    if timeDays > 0 then
      timeStr = luaUtils.Format(daysTextFormat, timeDays)
    else
      
      local currentTime = dateUtil.currentTime
      local nextCrossDayTime = dateUtil.GetNextCrossDayTime(currentTime)
      local timeSpan = nextCrossDayTime - currentTime
      timeStr = CS.Torappu.FormatUtil.FormatTimeDelta(timeSpan)
    end
  end

  local remainTextFormat = StringRes.COMMON_LEFT_TIME
  self._timeText.text = luaUtils.Format(remainTextFormat, timeStr)
end

function ReturnV2SpecialOpenView:_UpdateCurrentState()
  local viewState = self.m_model.fullOpenState

  SetGameObjectActive(self._pauseHint, viewState == FULL_OPEN_STATE.PAUSED)
  SetGameObjectActive(self._openHint, viewState == FULL_OPEN_STATE.OPEN)
  SetGameObjectActive(self._closeState, viewState == FULL_OPEN_STATE.CLOSED)
  SetGameObjectActive(self._openState, viewState ~= FULL_OPEN_STATE.CLOSED)
end


return ReturnV2SpecialOpenView