local luaUtils = CS.Torappu.Lua.Util;











BlessOnlyMainDlg = Class("BlessOnlyMainDlg", DlgBase)

local BlessOnlyViewModel = require("Feature/Activity/BlessOnly/BlessOnlyViewModel");
local BlessOnlyHomeView = require("Feature/Activity/BlessOnly/BlessOnlyHomeView");
local BlessOnlyPacketView = require("Feature/Activity/BlessOnly/BlessOnlyPacketView");
local BlessOnlyBlessListView = require("Feature/Activity/BlessOnly/BlessOnlyBlessListView");
local BlessOnlyBlessCollectionView = require("Feature/Activity/BlessOnly/BlessOnlyBlessCollectionView");
local UICharacterIllustLuaLoader= require("Feature/Supportor/UI/UICharacterIllustLuaLoader");

function BlessOnlyMainDlg:OnInit()
  local actId = self.m_parent:GetData("actId");
  self.m_blessOnlyViewModel = self:CreateViewModel(BlessOnlyViewModel);
  self.m_blessOnlyViewModel:LoadData(actId);

  local homeView = self:CreateWidgetByPrefab(BlessOnlyHomeView, self._panelHome, self._homeContainer);
  homeView.onClickDailyCheckInBtn = Event.Create(self, self._OnClickDailyCheckInBtn);
  homeView.onClickSwitchToCollectionBtn = Event.Create(self, self._OnClickSwitchToBlessCollectionBtn);
  homeView.onClickHomeReceivePacketBtn = Event.Create(self, self._OnClickHomeReceivePacketBtn);
  homeView.onClickHomeCheckBlessBtn = Event.Create(self, self._OnClickHomeCheckBlessListBtn);
  homeView.onClickCloseHome = Event.Create(self, self._OnClickCloseHomeBtn);
  homeView:InitEventFunc();
  
  local packetView = self:CreateWidgetByPrefab(BlessOnlyPacketView, self._panelPacket, self._packetContainer);  
  packetView.onClickOpenPacketReward = Event.Create(self, self._OnOpenPacketReward);
  packetView.onClosePacketPanel = Event.Create(self, self._OnClosePacketPanel);
  
  local blessList = self:CreateWidgetByPrefab(BlessOnlyBlessListView, self._panelBlessList, self._blessListContainer);  
  blessList.onLeftArrowClick = Event.Create(self, self._OnClickBlessListLeftArrow);
  blessList.onRightArrowClick = Event.Create(self, self._OnClickBlessListRightArrow);
  blessList.onCloseBtnClick = Event.Create(self, self._OnClickCloseBlessListEvent);
  blessList.onSwitchBtnClick = Event.Create(self, self._OnSwitchBlessHorOrVerType);
  blessList.onConfirmBtnClick = Event.Create(self, self._ChangeFestivalDefaultChar);
  local illustLoader = self:CreateCustomComponent(UICharacterIllustLuaLoader, self.m_root);
  blessList.illustLoader = illustLoader;
  
  local blessCollection = self:CreateWidgetByPrefab(BlessOnlyBlessCollectionView, self._panelBlessCollection, self._blessCollectionContainer);  
  blessCollection.onClickCloseBtn = Event.Create(self, self._OnCloseBlessCollectionPanel);

  self.m_blessOnlyViewModel:NotifyUpdate();
end




function BlessOnlyMainDlg:_OnClickBlessListLeftArrow()
  self.m_blessOnlyViewModel:MoveBlessListLeft();
  self.m_blessOnlyViewModel:NotifyUpdate();
end

function BlessOnlyMainDlg:_OnClickBlessListRightArrow()
  self.m_blessOnlyViewModel:MoveBlessListRight();
  self.m_blessOnlyViewModel:NotifyUpdate();
end

function BlessOnlyMainDlg:_OnClickCloseBlessListEvent()
  self.m_blessOnlyViewModel:CloseBlessList();
  self.m_blessOnlyViewModel:NotifyUpdate();
end

function BlessOnlyMainDlg:_OnSwitchBlessHorOrVerType()
  self.m_blessOnlyViewModel:SwitchBlessListHorOrVerType();
  self.m_blessOnlyViewModel:NotifyUpdate();
end

function BlessOnlyMainDlg:_ChangeFestivalDefaultChar()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end

  local actId = self.m_parent:GetData("actId");
  if self.m_blessOnlyViewModel == nil or self.m_blessOnlyViewModel.openPacketModel == nil or 
      self.m_blessOnlyViewModel.openPacketModel.curBlessItemModel == nil then
    return;
  end
  
  UISender.me:SendRequest(BlessOnlyServiceCode.CHANGE_FESTIVAL_CHAR, 
      {
        activityId = actId,
        index = self.m_blessOnlyViewModel.openFestivalOrder - 1,
        newChar = self.m_blessOnlyViewModel.openPacketModel.curBlessItemModel.fesCharId,
      }, 
      {
        onProceed = Event.Create(self, self._HandleChangeFestivalDefaultCharResponse);
      }
  )
end

function BlessOnlyMainDlg:_HandleChangeFestivalDefaultCharResponse()
  self.m_blessOnlyViewModel:CloseBlessList();
  self.m_blessOnlyViewModel:UpdateData();
  self.m_blessOnlyViewModel:NotifyUpdate();
end




function BlessOnlyMainDlg:_OnClickHomeReceivePacketBtn(fesOrder);
  self.m_blessOnlyViewModel:SwitchToReceivePacketState(fesOrder);
  self.m_blessOnlyViewModel:NotifyUpdate();
end


function BlessOnlyMainDlg:_OnClickHomeCheckBlessListBtn(fesOrder);
  self.m_blessOnlyViewModel:SwitchToCheckBlessListState(fesOrder);
  self.m_blessOnlyViewModel:NotifyUpdate();
end


function BlessOnlyMainDlg:_OnClickDailyCheckInBtn(order)
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  if order < 0 then
    return;
  end

  local actId = self.m_parent:GetData("actId");
  if string.isNullOrEmpty(actId) then
    return;
  end
  UISender.me:SendRequest(BlessOnlyServiceCode.GET_CHECK_IN_REWARD, 
      {
        activityId = actId,
        index = order,
        isFestival = BlessOnlyRewardType.NORMAL,
      }, 
      {
        onProceed = Event.Create(self, self._HandleDailyCheckinResponse);
      }
  )
end

function BlessOnlyMainDlg:_HandleDailyCheckinResponse(response) 
  local handler = CS.Torappu.UI.LuaUIMisc.ShowGainedItems(response.items, CS.Torappu.UI.UIGainItemFloatPanel.Style.DEFAULT, function()
    self.m_blessOnlyViewModel:UpdateData();
    self.m_blessOnlyViewModel.playHomeEntryAnim = false;
    self.m_blessOnlyViewModel:NotifyUpdate();
  end);
  self:_AddDisposableObj(handler);
end

function BlessOnlyMainDlg:_OnClickSwitchToBlessCollectionBtn()
  self.m_blessOnlyViewModel:SwitchToBlessCollectionState();
  self.m_blessOnlyViewModel:NotifyUpdate();
end

function BlessOnlyMainDlg:_OnClickCloseHomeBtn()
  self:Close();
end



function BlessOnlyMainDlg:_OnOpenPacketReward()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  local openPacketOrder = self.m_blessOnlyViewModel.openFestivalOrder - 1;
  if openPacketOrder < 0 then
    return;
  end

  local actId = self.m_parent:GetData("actId");
  if string.isNullOrEmpty(actId) then
    return;
  end
  UISender.me:SendRequest(BlessOnlyServiceCode.GET_CHECK_IN_REWARD, 
      {
        activityId = actId,
        index = openPacketOrder,
        isFestival = BlessOnlyRewardType.FESTIVAL,
      }, 
      {
        onProceed = Event.Create(self, self._HandleOpenPacketResponse);
      }
  )
end

function BlessOnlyMainDlg:_HandleOpenPacketResponse(response) 
  local handler = CS.Torappu.UI.LuaUIMisc.ShowGainedItems(response.items, CS.Torappu.UI.UIGainItemFloatPanel.Style.DEFAULT, function()
    self.m_blessOnlyViewModel:SwitchToOpenPacketBlessList(false);
    self.m_blessOnlyViewModel:NotifyUpdate();
  end);
  self:_AddDisposableObj(handler);
end

function BlessOnlyMainDlg:_OnClosePacketPanel()
  self.m_blessOnlyViewModel:ReturnToHomeStateFromPacket();
  self.m_blessOnlyViewModel:NotifyUpdate();
end


function BlessOnlyMainDlg:_OnCloseBlessCollectionPanel()
  self.m_blessOnlyViewModel:CloseBlessCollection();
  self.m_blessOnlyViewModel:NotifyUpdate();
end