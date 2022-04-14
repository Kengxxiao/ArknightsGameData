local luaUtils = CS.Torappu.Lua.Util;































ReturnMainDlg = DlgMgr.DefineDialog("ReturnMainDlg", "Operation/Returnning/return_main_dlg");

local ReturnTaskView = require("Feature/Operation/Returnning/ReturnTaskView")
local ReturnSpecialOpenView = require("Feature/Operation/Returnning/ReturnSpecialOpenView")
local ReturnCheckinView = require("Feature/Operation/Returnning/ReturnCheckinView")

local STATE_TAB_CHECKIN       = 0
local STATE_TAB_TASK          = 1
local STATE_TAB_ALL_OPEN      = 2

function ReturnMainDlg:OnInit()
  
  self.m_currentData = {}
  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnClose)
  self:AddButtonClickListener(self._btnContent, self._EventOnContentBtnClick)
  self:AddButtonClickListener(self._btnWelcome, self._EventOnWelcomBtnClick)
  self:AddButtonClickListener(self._btnTabCheckin, self._EventOnCheckinTabClick)
  self:AddButtonClickListener(self._btnTabTask, self._EventOnTaskTabClick)
  self:AddButtonClickListener(self._btnTabOpen, self._EventOnOpenTabClick)

  TrackPointModel.me:BindUI(ReturnCheckInTabTrackPoint, self._trackPointCheckIn);
  TrackPointModel.me:BindUI(ReturnTaskTabTrackPoint, self._trackPointTask);
  TrackPointModel.me:BindUI(ReturnOpenTabTrackPoint, self._trackPointOpen);
  
  self:_Render()
end

function ReturnMainDlg:OnClose()
  TrackPointModel.me:UnbindUI(ReturnCheckInTabTrackPoint);
  TrackPointModel.me:UnbindUI(ReturnTaskTabTrackPoint);
  TrackPointModel.me:UnbindUI(ReturnOpenTabTrackPoint);
end

function ReturnMainDlg:_Render()
  
  self.m_currentData = CS.Torappu.PlayerData.instance.data.backflow.current
  if not self.m_currentData then
    return
  end
  local returnConst = CS.Torappu.OpenServerDB.returnData.constData
  if not returnConst then
    return
  end

  local isSystemFinish = ReturnModel.me:CheckIfOnlyWeeklyOpen()
  local isCheckinRewardsAllClaimed = self:_IsCheckinRewardsAllClaimed()
  
  SetGameObjectActive(self._objCheckinTab, not isSystemFinish)
  SetGameObjectActive(self._objTaskTab, not isSystemFinish)
  SetGameObjectActive(self._btnWelcome.gameObject, not isSystemFinish);
  
  if isSystemFinish then
    self:_EventOnOpenTabClick()
  elseif isCheckinRewardsAllClaimed then
    self:_EventOnTaskTabClick()
  else
    self:_EventOnCheckinTabClick()
  end
end

function ReturnMainDlg:_IsCheckinRewardsAllClaimed()
  if not self.m_currentData then
    return false
  end
  local checkinHistoryList = self.m_currentData.checkIn.history
  if not checkinHistoryList then
    return false
  end
  local gameDataList = ToLuaArray(checkinHistoryList)
  local checkInPlayerDataCount = #gameDataList
  if checkInPlayerDataCount <= 0 then
    return false
  end
  local gameDataCount = ReturnModel.me:GetCheckinListCount()
  if checkInPlayerDataCount < gameDataCount then
    return false
  end
  
  for idx = 1, checkInPlayerDataCount do
    local history = gameDataList[idx]
    if history == ReturnCheckInState.STATE_CHECKIN_AVAILABLE then
      return false
    end
  end

  return true
end

function ReturnMainDlg:_EventOnContentBtnClick()
  ReturnModel.me:ShowGuide()
end

function ReturnMainDlg:_EventOnWelcomBtnClick()
  local dlg = self:GetGroup():AddChildDlg(ReturnWelcomeDlg)
end

function ReturnMainDlg:_EventOnCheckinTabClick()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return
  end
  self.m_tabState = STATE_TAB_CHECKIN
  self._twoStateCheckin.state = CS.Torappu.UI.TwoStateToggle.State.SELECT
  self._twoStateTask.state = CS.Torappu.UI.TwoStateToggle.State.UNSELECT
  self._twoStateOpen.state = CS.Torappu.UI.TwoStateToggle.State.UNSELECT
  SetGameObjectActive(self._objCheckinParent, true)
  SetGameObjectActive(self._objTaskParent, false)
  SetGameObjectActive(self._objOpenParent, false)
  
  if self.m_returnCheckinView == nil then
    self.m_returnCheckinView = self:CreateWidgetByPrefab(ReturnCheckinView, self._checkinViewPrefab, self._rectCheckinParent)
  end
  self.m_returnCheckinView:Render()
  
end

function ReturnMainDlg:_EventOnTaskTabClick()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return
  end
  self.m_tabState = STATE_TAB_TASK
  self._twoStateCheckin.state = CS.Torappu.UI.TwoStateToggle.State.UNSELECT
  self._twoStateTask.state = CS.Torappu.UI.TwoStateToggle.State.SELECT
  self._twoStateOpen.state = CS.Torappu.UI.TwoStateToggle.State.UNSELECT
  SetGameObjectActive(self._objCheckinParent, false)
  SetGameObjectActive(self._objTaskParent, true)
  SetGameObjectActive(self._objOpenParent, false)
  
  if self.m_returnTaskView == nil then
    self.m_returnTaskView = self:CreateWidgetByPrefab(ReturnTaskView, self._taskViewPrefab, self._rectTaskParent)
    self.m_returnTaskView:Bind(self)
  end
  
  self.m_returnTaskView:Render()
end

function ReturnMainDlg:EventOnShowCreditRewards()
  
  local dlg = self:GetGroup():AddChildDlg(ReturnRewardsDlg)
  dlg:Flush(CS.Torappu.StringRes.RETURN_CREDITS_REWARDS_TITLE, CS.Torappu.OpenServerDB.returnData.creditsList)
end

function ReturnMainDlg:_EventOnOpenTabClick()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return
  end
  self.m_tabState = STATE_TAB_ALL_OPEN
  self._twoStateCheckin.state = CS.Torappu.UI.TwoStateToggle.State.UNSELECT
  self._twoStateTask.state = CS.Torappu.UI.TwoStateToggle.State.UNSELECT
  self._twoStateOpen.state = CS.Torappu.UI.TwoStateToggle.State.SELECT
  SetGameObjectActive(self._objCheckinParent, false)
  SetGameObjectActive(self._objTaskParent, false)
  SetGameObjectActive(self._objOpenParent, true)
  if self.m_returnSpecialOpenView == nil then
    self.m_returnSpecialOpenView = self:CreateWidgetByPrefab(ReturnSpecialOpenView, self._specialOpenPrefab, self._rectOpenParent)
  end
  self.m_returnSpecialOpenView:Render()

  
  ReturnModel.me:SetAllOpenTabClicked(true)
  TrackPointModel.me:UpdateNode(ReturnOpenTabTrackPoint)
end