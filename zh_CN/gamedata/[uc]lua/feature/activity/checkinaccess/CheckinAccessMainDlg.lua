local luaUtils = CS.Torappu.Lua.Util;










CheckinAccessMainDlg = Class("CheckinAccessMainDlg", DlgBase);

local CheckinAccessViewModel = require("Feature/Activity/CheckinAccess/CheckinAccessViewModel");
local CheckinAccessMainView = require("Feature/Activity/CheckinAccess/CheckinAccessMainView");
local CheckinAccessUrlView = require("Feature/Activity/CheckinAccess/CheckinAccessUrlView");

function CheckinAccessMainDlg:OnInit()
  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnClose);
  self:AddButtonClickListener(self._btnClose, self._EventOnCloseBtnClick);
  self:AddButtonClickListener(self._btnConfirm, self._EventOnConfirmBtnClick);
  self:AddButtonClickListener(self._btnJumpUrl, self._EventOnUrlBtnClick);

  local actId = self.m_parent:GetData("actId");
  self.m_viewModel = self:CreateViewModel(CheckinAccessViewModel);
  self.m_viewModel:LoadData(actId);

  self._imgMain.sprite = self:LoadSprite(CS.Torappu.ResourceUrls.GetActAccessMainDynImagePath(actId));

  local mainView = self:CreateWidgetByGO(CheckinAccessMainView, self._mainView);
  local urlView = self:CreateWidgetByGO(CheckinAccessUrlView, self._urlView);
  
  self.m_viewModel:NotifyUpdate();
end


function CheckinAccessMainDlg:_EventOnConfirmBtnClick()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  local viewModel = self.m_viewModel;
  if viewModel == nil or viewModel.status ~= CheckinAccessStatus.CAN_CONFIRM or
      string.isNullOrEmpty(viewModel.actId) then
    return;
  end
  viewModel.status = CheckinAccessStatus.CONFIRMED;
  viewModel:NotifyUpdate();
  UISender.me:SendRequest(CheckinAccessServiceCode.GET_REWARD, 
      {
        activityId = viewModel.actId,
      }, {
        onProceed = Event.Create(self, self._HandleGetRewardResponse),
      });
end


function CheckinAccessMainDlg:_HandleGetRewardResponse(response)
  local handler = CS.Torappu.UI.LuaUIMisc.ShowGainedItems(response.items, CS.Torappu.UI.UIGainItemFloatPanel.Style.DEFAULT,
      function()
        self:_RefreshPlayerData();
      end);
  self:_AddDisposableObj(handler);
end

function CheckinAccessMainDlg:_RefreshPlayerData()
  local viewModel = self.m_viewModel;
  if viewModel == nil then
    return;
  end
  viewModel:RefreshPlayerData();
  viewModel:NotifyUpdate();
end


function CheckinAccessMainDlg:_EventOnUrlBtnClick()
  local viewModel = self.m_viewModel;
  if viewModel == nil or not viewModel.showUrlBtn then
    return;
  end
  luaUtils.OpenUrl(viewModel.jumpUrl);
  luaUtils.ConsumeTrack(CS.Torappu.LocalTrackTypes.ACT_TIME_TRACK, viewModel.actId);
  viewModel.showTrackPoint = false;
  viewModel:NotifyUpdate();
end


function CheckinAccessMainDlg:_EventOnCloseBtnClick()
  self:Close();
end