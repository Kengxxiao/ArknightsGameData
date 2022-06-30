local luaUtils = CS.Torappu.Lua.Util














local ReturnSpecialOpenView = Class("ReturnSpecialOpenView", UIPanel)
local dateUtil = CS.Torappu.DateTimeUtil
local VIEW_STATE = {
  OPEN = 1,
  PAUSED = 2,
  CLOSED = 3
}

function ReturnSpecialOpenView:_EventOnGoToSpecialOpen()
  CS.Torappu.UI.UIRouteUtil.RouteToZoneViewType(CS.Torappu.UI.Stage.ZoneViewType.WEEKLY);
end

local function _SetActive(gameObj, isActive)
  luaUtils.SetActiveIfNecessary(gameObj, isActive)
end

function ReturnSpecialOpenView:_UpdateCurrentState()
  local playerData = CS.Torappu.PlayerData.instance.data.backflow.current
  local closed = playerData.fullOpen.remain == 0 and playerData.fullOpen.today == false
  if playerData.open == false or closed then
    self.m_viewState = VIEW_STATE.CLOSED
  elseif playerData.fullOpen.today == false then
    self.m_viewState = VIEW_STATE.PAUSED
  elseif playerData.fullOpen.today == true then
    self.m_viewState = VIEW_STATE.OPEN
  end
  SetGameObjectActive(self._pauseHint,self.m_viewState == VIEW_STATE.PAUSED)
  SetGameObjectActive(self._closeState, self.m_viewState == VIEW_STATE.CLOSED)
  SetGameObjectActive(self._endTimeText, self.m_viewState == VIEW_STATE.OPEN)
  SetGameObjectActive(self._openState,self.m_viewState ~= VIEW_STATE.CLOSED)

    
end


function ReturnSpecialOpenView:OnInit()
  self:AddButtonClickListener(self._goButton, self._EventOnGoToSpecialOpen)
end

function ReturnSpecialOpenView:Render()
  self:_UpdateTimeText()
  self:_UpdateCurrentState()
end

function ReturnSpecialOpenView:_UpdateTimeText()
  local playerData = CS.Torappu.PlayerData.instance.data.backflow.current
  if playerData.fullOpen == nil then
    return
  end
  local timeStr = ""
  local DaysTextFormat = CS.Torappu.I18N.StringMap.Get("DAY_TEXT")
  if playerData.fullOpen.today == false then
    
    timeStr = luaUtils.Format(DaysTextFormat,playerData.fullOpen.remain)
  else
    
    
    local timeDays = playerData.fullOpen.remain - 1
    timeStr = luaUtils.Format(DaysTextFormat,timeDays)
    if timeDays == 0 then
      
      local currentTime = dateUtil.currentTime
      local nextCrossDayTime = dateUtil.GetNextCrossDayTime(currentTime)
      local timeSpan = nextCrossDayTime - currentTime
      timeStr = CS.Torappu.FormatUtil.FormatTimeDelta(timeSpan)
    end
  end
  local remainTextFormat = CS.Torappu.I18N.StringMap.Get("COMMON_LEFT_TIME")
  self._timeText.text = luaUtils.Format(remainTextFormat,timeStr)
end




return ReturnSpecialOpenView