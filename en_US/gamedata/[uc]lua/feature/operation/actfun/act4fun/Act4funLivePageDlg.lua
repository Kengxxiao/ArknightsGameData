local luaUtils = CS.Torappu.Lua.Util;

















Act4funLivePageDlg = DlgMgr.DefineDialog("Act4funLivePageDlg", "Activity/Actfun/Actfun4/Live/act4fun_live_page_dlg", BridgeDlgBase);

local Act4funLiveStagePanel = require "Feature/Operation/ActFun/Act4fun/Act4funLiveStagePanel";
local Act4funLiveCommentPanel = require "Feature/Operation/ActFun/Act4fun/Act4funLiveCommentPanel";
local Act4funLiveValuePanel = require "Feature/Operation/ActFun/Act4fun/Act4funLiveValuePanel";
local Act4funLivePhotoPanel = require "Feature/Operation/ActFun/Act4fun/Act4funLivePhotoPanel";
local Act4funLivePlayPanel = require "Feature/Operation/ActFun/Act4fun/Act4funLivePlayPanel";

local Act4funLiveOnlinePanel = require "Feature/Operation/ActFun/Act4fun/PopPanel/Act4funLiveOnlinePanel";
local Act4funLiveCardShowPanel = require "Feature/Operation/ActFun/Act4fun/PopPanel/Act4funLiveCardShowPanel";
local Act4funLiveEndPanel = require "Feature/Operation/ActFun/Act4fun/PopPanel/Act4funLiveEndPanel";
local Act4funLiveOfflinePanel = require "Feature/Operation/ActFun/Act4fun/PopPanel/Act4funLiveOfflinePanel";

function Act4funLivePageDlg:OnInit()
  self.m_judgeDialogHandle = self:CreateCustomComponent(CSJudgeDialogHandle);
  self:AddButtonClickListener(self._btnStop, self._StopLive);

  
  local playerLiveData = self:GetParamData();
  if not playerLiveData then
    playerLiveData = self:_GetTestPlayerLiveData();
  end
  self.m_viewModel = self:CreateViewModel(Act4funLiveData);
  self.m_viewModel:Load(playerLiveData);

  local PANEL_CONFIGS = 
  {
    { cls = Act4funLiveStagePanel, gameObject = self._stagePanel, container = nil},
    { cls = Act4funLivePhotoPanel, gameObject = self._photoPanel, container = nil},
    { cls = Act4funLivePlayPanel, gameObject = self._playPanel, container = nil},
    { cls = Act4funLiveCommentPanel, gameObject = self._commentPanelPrefab, container = self._commentPanelRoot},
    { cls = Act4funLiveValuePanel, gameObject = self._valuePanelPrefab, container = self._valuePanelContainer},

    { cls = Act4funLiveOnlinePanel, gameObject = self._onlinePanelPrefab, container = self._popupContainer},
    { cls = Act4funLiveCardShowPanel, gameObject = self._cardshowPanelPrefab, container = self._popupContainer},
    { cls = Act4funLiveEndPanel, gameObject = self._liveEndPanelPrefab, container = self._popupContainer},
    { cls = Act4funLiveOfflinePanel, gameObject = self._offlinePanelPrefab, container = self._popupContainer},
  };

  for _, panelCfg in ipairs(PANEL_CONFIGS) do
    
    local panel = nil;
    if panelCfg.container then
      panel = self:CreateWidgetByPrefab(panelCfg.cls, panelCfg.gameObject, panelCfg.container);
    else
      panel = self:CreateWidgetByGO(panelCfg.cls, panelCfg.gameObject);
    end
    panel:BindHost(self, self.m_viewModel);

  end
  
  self.m_viewModel:NotifyUpdate();
end


function Act4funLivePageDlg:ReqLiveEnd()
  self.m_reqEndTimes = 0;
  self:_DoReqLiveEnd();
end

function Act4funLivePageDlg:_DoReqLiveEnd()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end

  self.m_reqEndTimes = self.m_reqEndTimes + 1;
  local model = self.m_viewModel;
  local liveProc = model:GetLiveProcess();
  UISender.me:SendRequest(Act4funLiveServiceCode.LIVE_SETTLE,
  {
    liveId = model.liveId,
    process = liveProc,
  }, 
  {
    onProceed = Event.Create(self, self._HandleResponse);
    onBlock = Event.Create(self, self._HandleResponseFailed)
  });
end

function Act4funLivePageDlg:_HandleResponse(response)
  if self:IsDestroy() then
    return;
  end
  local ending = response.ending;
  if ending == nil or ending == "" then
    LogError("nil or empty ending");
    self:Close();
    return;
  end

  ActFun4MainDlg:LogTokenLevelUp()
  self.m_viewModel:CompleteReqEnd(ending);
end

function Act4funLivePageDlg:_HandleResponseFailed()
  if self.m_reqEndTimes > 1 then
    self:_ExitLiveDlg();
    return;
  end

  local conifg = {
    descText = self.m_viewModel.actData.constant.reconnectConfirmTxt;
    onPositive = Event.Create(self, self._DoReqLiveEnd);
    onNegative = Event.Create(self, self._ExitLiveDlg);
  };
  self.m_judgeDialogHandle:ShowDialog(conifg)
end

function Act4funLivePageDlg:_ExitLiveDlg()
  self:Close();
end


function Act4funLivePageDlg:_StopLive()
  local conifg = {
    descText = StringRes.ACTFUN_QUIT_LIVE,
    onPositive = Event.Create(self, self._DoStopLive);
  };
  self.m_judgeDialogHandle:ShowDialog(conifg);
end

function Act4funLivePageDlg:_DoStopLive()
  self.m_viewModel:SetupOffline();
end


function Act4funLivePageDlg:_GetTestPlayerLiveData()
  
  local ret = 
  {
    resp = 
    {
      liveId = "test",
      
      materials = {},
    },
  };
  local resp = ret.resp;

  local testSpMat = {
    "spLiveMat_01_2",
    "spLiveMat_01_1",
  }
  local testMat = {
    "liveMat_2",
    "liveMat_1",
    "liveMat_3",
    "liveMat_st_1",
  };
  
  local types = {CS.Torappu.Act4funStageAttributeType.POS, CS.Torappu.Act4funStageAttributeType.NEG}

  for idx, spMatId in ipairs(testSpMat) do
    
    local matData = {
      instId = 1000+idx,
      materialId = spMatId,
      materialType = 1;
      normalEffect = nil,
    };
    table.insert(resp.materials, matData);
  end

  for idx, matId in ipairs(testMat) do
    local count = RandomUtil.Range(1, 10);
    for instIdx = 1, count do
      local randIdx = RandomUtil.Range(1, 2);
      local attriType = types[randIdx];
      local addonSign = 1;
      if math.random() >= 0.5 then
        addonSign = -1;
      end
      
      local matData = {
        instId = idx * 100 +instIdx;
        materialId = matId,
        materialType = 0;
        normalEffect = 
        {
          sign = attriType,
          addon = RandomUtil.Range(10000, 50000) * addonSign;
        },
      };
      table.insert(resp.materials, matData);
    end
  end

  return ret;
end

Act4funLiveServiceCode = 
{
  LIVE_SETTLE = "/aprilFool/act4fun/liveSettle";
}
Readonly(Act4funLiveServiceCode);
















