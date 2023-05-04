local luaUtils = CS.Torappu.Lua.Util;































PrayOnlyMainDlg = Class("PrayOnlyMainDlg", DlgBase)

local PrayOnlyPackageView = require("Feature/Activity/PrayOnly/PrayOnlyPackageView")
local PrayOnlyViewModel = require("Feature/Activity/PrayOnly/PrayOnlyViewModel")

local DFT_POOL_COUNT = 12;


local function _CheckIfValueDirty(cache, target)
  if cache == nil or cache ~= target then
    return true
  end
  return false
end

local function _SetActive(gameObj, isActive)
  luaUtils.SetActiveIfNecessary(gameObj, isActive)
end

local function _CreateSwitch(canvasGroup)
  local ret = CS.Torappu.UI.FadeSwitchTween(canvasGroup)
  ret:Reset(false)
  return ret
end


function PrayOnlyMainDlg:OnInit()
  local actId = self.m_parent:GetData("actId")
  self:_InitFromGameData(actId)

  self.m_downPacks = {}
  self.m_upPacks = {}
  self.m_basicViewMap = {}
  self.m_selectViewMap = {}
  self.m_viewModel = PrayOnlyViewModel.new()
  self.m_viewCache = {}

  self.m_confirmSwtich = _CreateSwitch(self._alphaCanConfirm)
  self.m_prayedSwitch = _CreateSwitch(self._alphaPrayed)
  self.m_selectMoreSwitch = _CreateSwitch(self._alphaSelectMore)

  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnClose)
  self:AddButtonClickListener(self._btnClose, self.EventOnCloseClick)
  self:AddButtonClickListener(self._btnConfirm, self.EventOnConfirmClick)

  self.m_viewModel:InitData(actId, self.m_poolCount)
  self:_RefreshContent()
end


function PrayOnlyMainDlg:_InitFromGameData(actId)
  self.m_actId = actId
  self.m_poolCount = DFT_POOL_COUNT
  local dynActs = CS.Torappu.ActivityDB.data.dynActs;
  if actId == nil or dynActs == nil then
    return
  end
  local suc, jObject = dynActs:TryGetValue(actId)
  if not suc then
    luaUtils.LogError("Activity not found in dynActs : "..actId)
    return
  end
  local data = luaUtils.ConvertJObjectToLuaTable(jObject)
  local poolCount = tonumber(data.poolCount)
  if poolCount then
    self.m_poolCount = poolCount
  end
  if data.rule1 ~= nil then
    self._textRule1.text = data.rule1
  end
  if data.rule2 ~= nil then
    self._textRule2.text = data.rule2
  end
end

function PrayOnlyMainDlg:GetHilightColor()
  return self._colorHilight
end

function PrayOnlyMainDlg:_RefreshContent()
  local viewModel = self.m_viewModel
  if viewModel == nil then
    return
  end
  
  self:_RefreshBasicPacks()
  
  self:_RefreshTextsAndButtons()
end

function PrayOnlyMainDlg:_RefreshTextsAndButtons()
  local viewCache = self.m_viewCache
  local viewModel = self.m_viewModel
  if _CheckIfValueDirty(viewCache.endTimeDesc, viewModel.endTimeDesc) then
    self._textEndTime.text = viewModel.endTimeDesc
    viewCache.endTimeDesc = viewModel.endTimeDesc
  end

  local isPraying = viewModel:IsPraying()
  local hasPrayed = viewModel:HasPrayed()
  local canConfirm = viewModel:CheckIfCanGetReward()
  local selectMore = not hasPrayed and not canConfirm
  self.m_prayedSwitch.isShow = hasPrayed
  self.m_confirmSwtich.isShow = canConfirm
  self.m_selectMoreSwitch.isShow = selectMore

  local selectCount = viewModel:GetSelectCount()
  local maxCount = viewModel:GetMaxSelectCount()
  local remainCount = maxCount - selectCount
  if _CheckIfValueDirty(viewCache.remainCount, remainCount) then
    viewCache.remainCount = remainCount
    self._textRemainCnt.text = tostring(remainCount)
  end
  if _CheckIfValueDirty(viewCache.maxCount, maxCount) then
    self._textTotalCnt.text = luaUtils.Format("/{0}", maxCount)
  end

  local extraCnt = viewModel.extraCount
  local showExtraCnt = not isPraying and hasPrayed and 
      extraCnt > 0 and viewModel:HasChanceNextDay()
  _SetActive(self._panelExtraCnt, showExtraCnt)
  if _CheckIfValueDirty(viewCache.extraCnt, extraCnt) then
    viewCache.extraCnt = extraCnt
    self._textExtraCnt.text = luaUtils.Format(StringRes.ALERT_PRAY_ONLY_EXTRA_COUNT, extraCnt)
  end
end

function PrayOnlyMainDlg:_CreateOrGetViewFromTable(packs, index, prefab, container)
  local view = packs[index]
  if view == nil then 
    view = self:CreateWidgetByPrefab(PrayOnlyPackageView, prefab, container)
    view:InitView(self, index)
    packs[index] = view
  end
  return view
end


function PrayOnlyMainDlg:_RefreshBasicPacks()
  local viewMap = self.m_basicViewMap
  local models = self.m_viewModel.packageModels
  local packageCount = self.m_viewModel.packageCount
  for i = 1, packageCount do 
    local prefab = nil
    local container = nil
    if PrayOnlyViewModel.IsUpView(i) then
      prefab = self._packUp
      container = self._layoutUp
    else
      prefab = self._packDown
      container = self._layoutDown
    end
    local view = self:_CreateOrGetViewFromTable(viewMap, i, prefab, container)
  end
  for index, view in pairs(self.m_basicViewMap) do 
    self:_RenderPackView(view, index)
  end
end 

function PrayOnlyMainDlg:_RenderPackView(packView, index)
  local packModel = self.m_viewModel.packageModels[index]
  
  packView:Render(packModel)
end

function PrayOnlyMainDlg:EventOnPackViewClicked(packIndex)
  if self.m_viewModel == nil then
    return
  end
  if self.m_viewModel:TryToggleSelectModel(packIndex) then
    self:_RefreshContent()
  end
end

function PrayOnlyMainDlg:EventOnCloseClick()
  local viewModel = self.m_viewModel
  if viewModel ~= nil and viewModel:IsPraying() then
    
    return
  end
  self:Close()
end

function PrayOnlyMainDlg:EventOnConfirmClick()
  local viewModel = self.m_viewModel
  if viewModel == nil or viewModel:HasPrayed() then
    return
  end
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return
  end

  if not viewModel:CheckIfCanGetReward() then
    return
  end
  local selectedIds = viewModel:GetSelectedIds()
  
  local requestIndexList = {}
  for i, luaIndex in ipairs(selectedIds) do
    table.insert(requestIndexList, luaIndex - 1)
  end
  UISender.me:SendRequest(PrayOnlyServiceCode.GET_REWARD,
  {
    activityId = self.m_actId,
    prayArray = requestIndexList
  }, 
  {
    onProceed = Event.Create(self, self._OnGetRewardResponse)
  });
end


function PrayOnlyMainDlg:_OnGetRewardResponse(response)
  if self.m_viewModel == nil then
    return
  end
  self.m_viewModel:InitData(self.m_actId, self.m_poolCount)
  self.m_viewModel:MarkPrayingStart()
  self:_RefreshContent()
  local this = self
  self:Interval(PrayOnlyPackageView.EFFECT_DURATION, 1, function()
    CS.Torappu.Activity.ActivityUtil.DoShowGainedItems(response.rewards)
    self.m_viewModel:MarkPrayingFinish()
    self:_RefreshContent()
  end)
end