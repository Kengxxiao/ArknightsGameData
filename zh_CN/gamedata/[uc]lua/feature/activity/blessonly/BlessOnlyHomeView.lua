local FadeSwitchTween = CS.Torappu.UI.FadeSwitchTween



























local BlessOnlyHomeView = Class("BlessOnlyHomeView", UIPanel);

local BlessOnlyHomePacketView = require("Feature/Activity/BlessOnly/BlessOnlyHomePacketView");
local BlessOnlyDailyCheckInAdapter = require("Feature/Activity/BlessOnly/BlessOnlyDailyCheckInAdapter");

function BlessOnlyHomeView:OnInit()
  self.m_fesPacket1 = self:CreateWidgetByGO(BlessOnlyHomePacketView, self._fesPacket1);
  self.m_fesPacket2 = self:CreateWidgetByGO(BlessOnlyHomePacketView, self._fesPacket2);
  self.m_fesPacket3 = self:CreateWidgetByGO(BlessOnlyHomePacketView, self._fesPacket3);
  self.m_fesPacket4 = self:CreateWidgetByGO(BlessOnlyHomePacketView, self._fesPacket4);
  self:AddButtonClickListener(self._switchToCollectionBtn, self._OnClickSwitchToCollection);
  self:AddButtonClickListener(self._closeHomeBtn, self._OnClickCloseHome);
  self:AddButtonClickListener(self._fullScreenBtn, self._OnClickCloseHome);
  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._closeHomeBtn);

  self.m_switchTween = FadeSwitchTween(self._canvasGroup)
  self.m_switchTween:Reset(false)

  self.m_dailyCheckInAdapter = self:CreateCustomComponent(BlessOnlyDailyCheckInAdapter, self._dailyCheckInAdapter, self);
  self.m_dailyCheckInAdapter.dailyCheckInModelList = {};
  self.m_hasFocused = false;
end


function BlessOnlyHomeView:OnViewModelUpdate(data)
  if data == nil then
    return;
  end

  
  self.m_switchTween.isShow = data.panelState == BlessOnlyPanelState.HOME and not(data.isBlessListState);
  if data.panelState ~= BlessOnlyPanelState.HOME then
    return;
  end
  self.m_fesPacket1:Render(data);
  self.m_fesPacket2:Render(data);
  self.m_fesPacket3:Render(data);
  self.m_fesPacket4:Render(data);

  local isAllReceive = data:CheckIsAllPacketReceived();
  SetGameObjectActive(self._enableSwitchToCollectionObject, isAllReceive);
  SetGameObjectActive(self._disableSwitchToCollectionObject, not(isAllReceive));
  self._receivedPacketCnt.text = CS.Torappu.Lua.Util.Format(StringRes.BLESSONLY_BLESS_COUNT, data:GetReceivedPacketCnt(), data:GetPacketCnt());

  self.m_dailyCheckInAdapter.dailyCheckInModelList = data.checkInItemList;
  self.m_dailyCheckInAdapter:NotifyDataSourceChanged();

  if not self.m_hasFocused then
    
    self.m_dailyCheckInAdapter:NotifyRebuildWithIndex(data:GetFirstAvailCheckInIndex());
    self.m_hasFocused = true;
  end
  
  self._actEndTimeText.text = data.actEndTimeDesc;
  self._apSupplyEndTimeText.text = data.apSupplyEndTimeDesc;
end

function BlessOnlyHomeView:InitEventFunc()
  self.m_fesPacket1:SetEventForBtn(self.onClickHomeReceivePacketBtn, self.onClickHomeCheckBlessBtn);
  self.m_fesPacket2:SetEventForBtn(self.onClickHomeReceivePacketBtn, self.onClickHomeCheckBlessBtn);
  self.m_fesPacket3:SetEventForBtn(self.onClickHomeReceivePacketBtn, self.onClickHomeCheckBlessBtn);
  self.m_fesPacket4:SetEventForBtn(self.onClickHomeReceivePacketBtn, self.onClickHomeCheckBlessBtn);
  self.m_dailyCheckInAdapter.onClickReceiveReward = self.onClickDailyCheckInBtn;
end

function BlessOnlyHomeView:_OnClickSwitchToCollection()
  if CS.Torappu.FastActionDetector.IsFastAction() then
    return;
  end
  if self.onClickSwitchToCollectionBtn == nil then
    return;
  end
  Event.Call(self.onClickSwitchToCollectionBtn);
end

function BlessOnlyHomeView:_OnClickCloseHome()
  if self.onClickCloseHome == nil then
    return;
  end
  Event.Call(self.onClickCloseHome);
end

return BlessOnlyHomeView