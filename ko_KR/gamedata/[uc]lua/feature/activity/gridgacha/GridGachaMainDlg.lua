local luaUtils = CS.Torappu.Lua.Util;




















































GridGachaMainDlg = Class("GridGachaMainDlg", DlgBase);

local GridGachaPackageView = require("Feature/Activity/GridGacha/GridGachaPackageView");
local GridGachaViewModel = require("Feature/Activity/GridGacha/GridGachaViewModel");
local GridGachaRuleView = require("Feature/Activity/GridGacha/GridGachaRuleView");
local GridGachaLineView = require("Feature/Activity/GridGacha/GridGachaLineView");

local DFT_POOL_COUNT = 100;
local DFT_POOL_VERTICAL_COUNT = 10;
local DFT_POOL_HORIZON_COUNT = 10;
local LINE_POS = {0, 53, 106, 159, 212, 264, 317, 370, 423, 476};
local LINE_RANDOM_FLASH_TIME = 0.16;
local LINE_FLASH_TIME = 0.4;
local RED_LINE_LENGTH = 554;
local BLACK_LINE_LENGTH = 528;
local SOUND_SIGNAL_SCAN = "ON_GRIDGACHA_SCAN";
local SOUND_SIGNAL_BLINK = "ON_GRIDGACHA_BLINK";
local SOUND_SIGNAL_LASER = "ON_GRIDGACHA_LASER";
local SOUND_SIGNAL_LOCATE = "ON_GRIDGACHA_LOCATE";
local SOUND_SIGNAL_POPUP = "ON_MSGBOX_POPUP";
local SOUND_SIGNAL_REWARD = "ON_BATTLE_END_ITEM_POPUP";
local SOUND_SIGNAL_TICK = "ON_NUMBER_TICK";

local function _SetActive(gameObj, isActive);
  luaUtils.SetActiveIfNecessary(gameObj, isActive);
end

local function _CreateSwitch(canvasGroup)
  local ret = CS.Torappu.UI.FadeSwitchTween(canvasGroup, 0.5)
  ret:Reset(false)
  return ret
end

local function CalculatePosition(row, column)
  return 10 * row + column + 1;
end


function GridGachaMainDlg:OnInit()
  self.m_gridGachaText = {}
  local actId = self.m_parent:GetData("actId");
  self:_InitFromGameData(actId);
  
  self.m_viewCache = {}
  self.m_viewModel = GridGachaViewModel.new();

  self.m_viewMap = {}
  self.m_horizonLineView = {}
  self.m_verticalLineView = {}

  self.m_confirmSwitch = _CreateSwitch(self._alphaConfirm);
  self.m_finishedSwitch = _CreateSwitch(self._alphaFinished);
  self.m_processSwitch = _CreateSwitch(self._alphaProcess);
  
  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnClose);
  self:AddButtonClickListener(self._btnClose, self.EventOnCloseClick);
  self:AddButtonClickListener(self._btnConfirm, self.EventOnConfirmClick);
  
  
  self.m_viewModel:InitData(actId, DFT_POOL_COUNT);
  self:_RefreshContent();
end 

function GridGachaMainDlg:_RefreshContent()
  local viewModel = self.m_viewModel
  if viewModel == nil then
    return
  end
  
  self:_RefreshBasicPacks()
  
  self:_RefreshTextsAndButtons()
end

function GridGachaMainDlg:CalPosition(index)
  local x = math.ceil(index / 10);
  local y = index % 10;
  if y == 0 then
    y = 10;
  end
  return {x, y};
end

function GridGachaMainDlg:_RefreshBasicPacks()
  local viewMap = self.m_viewMap;
  local models = self.m_viewModel.packageModels;
  for i = 1, DFT_POOL_COUNT do
    local model = models[i];
    if model ~= nil and (model.isGrandAward or model.isReward) then
      self:_CreateOrGetViewFromTable(viewMap, i, self._package, self._layout);
    end
  end
  for i = 1, DFT_POOL_HORIZON_COUNT do
    local view = self.m_horizonLineView[i];
    if view == nil then
      view = self:CreateWidgetByPrefab(GridGachaLineView, self._gachaLine, self._horizonLineLayout);
      view:OnInit();
      view._selfRect.localPosition = {x = LINE_POS[i], y = 0, z = 0 };
      table.insert(self.m_horizonLineView, i, view);
    end
    view:Render(false);
  end
  for i = 1, DFT_POOL_VERTICAL_COUNT do
    local view = self.m_verticalLineView[i];
    if view == nil then
      view = self:CreateWidgetByPrefab(GridGachaLineView, self._gachaLine, self._verticalLineLayout);
      view:OnInit();
      view._selfRect.localEulerAngles = {x = 0, y = 0, z = -90};
      view._selfRect.anchoredPosition = {x = 19, y = -LINE_POS[i], z = 0 };
      table.insert(self.m_verticalLineView, i, view);
    end
    view:Render(false);
  end
  if self.m_viewModel:HasGacha() then
    local position = self:CalPosition(self.m_viewModel.rewardModel);
    self.m_horizonLineView[position[2]]:Render(true);
    self.m_verticalLineView[position[1]]:Render(true);
  end

  for index, view in pairs(viewMap) do
    self:_RenderPackView(view, index);
  end

  self._panelSkip:SetActive(not self.m_viewModel.m_isFirstDay);
  self._skipCheckBox.isOn = (CS.Torappu.UI.UILocalCache.instance.GridGachaSkipAnimation == 1);
end

function GridGachaMainDlg:_InitSound(signal)
  CS.Torappu.TorappuAudio.PlayUI(signal);
end

function GridGachaMainDlg:_CreateOrGetViewFromTable(viewMap, index, prefab, container)
  local view = viewMap[index]
  if view == nil then
    view = self:CreateWidgetByPrefab(GridGachaPackageView, prefab, container);
    view:InitView(self, index);
    viewMap[index] = view;
  end
  return view;
end

function GridGachaMainDlg:_RenderPackView(packView, index)
  local packModel = self.m_viewModel.packageModels[index];
  packView:Render(packModel);
end

function GridGachaMainDlg:_RefreshTextsAndButtons()
  local viewModel = self.m_viewModel;
  local isFinish = viewModel.m_hasGacha;
  
  self.m_processSwitch:Reset(false);
  self.m_confirmSwitch:Reset(not isFinish);
  self.m_finishedSwitch:Reset(isFinish);

  self._textEndTime.text = viewModel.endTimeDesc;

  if self.m_viewModel:HasGacha() then
    self._imgFinish1.sizeDelta = {x = 192, y = 10};
    self._textGroup1.sizeDelta = {x = 200, y = 52};
    self._textGroup2.sizeDelta = {x = 200, y = 52};
    self._textGroup3.sizeDelta = {x = 200, y = 52};
    self._textGroup4.sizeDelta = {x = 200, y = 34};
    self._imgTri1.color = {r = 1, g = 1, b = 1, a = 1};
    self._rectTri1.anchoredPosition = { x = -72, y = 95, z = 0};
    self._imgTri2.color = {r = 1, g = 1, b = 1, a = 1};
    self._rectTri2.anchoredPosition = { x = -72, y = -151, z = 0};
    self._maskBanner.sizeDelta = {x = 0, y = 650};
    self._defaultText.color = {r = 0.26, g = 0.26, b = 0.26, a = 0};
    self._gachaText.color = {r = 0.75, g = 0.29, b = 0.25, a = 1};
    self._gachaText.text = self.m_gridGachaText[self.m_viewModel.openedType + 1];
    self._panelDiamond.sizeDelta = {x = 146, y = 45};
    self._redDiamondText.text = 0;
    self._redDiamondText.color = {r = 0.75, g = 0.29, b = 0.25, a = 0};
    self._blackDiamondText.color = {r = 0.06, g = 0.06, b = 0.06, a = 0.51};
    self._blackDiamondText.text = self.m_viewModel.rewards;
    self._imgScanLine.anchoredPosition = {x = 0, y = 0};
  else
    self._imgFinish1.sizeDelta = {x = 0, y = 10};
    self._textGroup1.sizeDelta = {x = 0, y = 52};
    self._textGroup2.sizeDelta = {x = 0, y = 52};
    self._textGroup3.sizeDelta = {x = 0, y = 52};
    self._textGroup4.sizeDelta = {x = 0, y = 34};
    self._imgTri1.color = {r = 1, g = 1, b = 1, a = 0};
    self._rectTri1.anchoredPosition = { x = -72, y = 110, z = 0};
    self._imgTri2.color = {r = 1, g = 1, b = 1, a = 0};
    self._rectTri2.anchoredPosition = { x = -72, y = -136, z = 0};
    self._maskBanner.sizeDelta = {x = 0, y = 650};
    self._defaultText.color = {r = 0.26, g = 0.26, b = 0.26, a = 1};
    self._gachaText.color = {r = 0.75, g = 0.29, b = 0.25, a = 0};
    self._defaultText.text = CS.Torappu.StringRes.GRID_GACHA_NO_REWARD;
    self._panelDiamond.sizeDelta = {x = 146, y = 45};
    self._redDiamondText.text = "";
    self._redDiamondText.color = {r = 0.75, g = 0.29, b = 0.25, a = 0};
    self._blackDiamondText.color = {r = 0.06, g = 0.06, b = 0.06, a = 0.51};
    self._blackDiamondText.text = "0";
    self._imgScanLine.anchoredPosition = {x = 0, y = 0};
  end
end


function GridGachaMainDlg:_InitFromGameData(actId)
  self.m_actId = actId;
  self.m_poolCount = DFT_POOL_COUNT;
  local dynActs = CS.Torappu.ActivityDB.data.dynActs;
  if actId == nil or dynActs == nil then
    return;
  end
  local suc, jObject = dynActs:TryGetValue(actId);
  if not suc then
    luaUtils.LogError("Activity not found in dynActs : "..actId);
    return;
  end
  local data = luaUtils.ConvertJObjectToLuaTable(jObject);
  for i = 1, #data.rule do
    self:_CreateRuleText(self._ruleText, self._ruleScrollView, data.rule[i]);
  end
  table.insert(self.m_gridGachaText, data.name3);
  table.insert(self.m_gridGachaText, data.name2);
  table.insert(self.m_gridGachaText, data.name1);
end 

function GridGachaMainDlg:_CreateRuleText(prefab, container, text) 
  if text == nil then
    return
  end
  local view = self:CreateWidgetByPrefab(GridGachaRuleView, prefab, container);
  view:Render(text);
end

function GridGachaMainDlg:EventOnCloseClick()
  local viewModel = self.m_viewModel;
  if viewModel ~= nil and viewModel:IsGacha() then
    return;
  end
  if self._skipCheckBox.isOn then
    CS.Torappu.UI.UILocalCache.instance.GridGachaSkipAnimation = 1;
  else
    CS.Torappu.UI.UILocalCache.instance.GridGachaSkipAnimation = 0;
  end
  self:Close();
end 

function GridGachaMainDlg:EventOnConfirmClick()
  local viewModel = self.m_viewModel
  if viewModel == nil or viewModel:HasGacha() then
    return;
  end
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end

  if self._skipCheckBox.isOn then
    CS.Torappu.UI.UILocalCache.instance.GridGachaSkipAnimation = 1;
  else
    CS.Torappu.UI.UILocalCache.instance.GridGachaSkipAnimation = 0;
  end
  
  if (not self.m_viewModel.m_isFirstDay) and self._skipCheckBox.isOn then
    UISender.me:SendRequest(GridGachaServerCode.GACHA,
      {
        activityId = self.m_actId;
      },
      {
        onProceed = Event.Create(self, self._OnGetRewardResponseNoAnime),
        hideMask = true
      }
    );
  else
    UISender.me:SendRequest(GridGachaServerCode.GACHA,
      {
        activityId = self.m_actId;
      },
      {
        onProceed = Event.Create(self, self._OnGetRewardResponse),
        hideMask = true
      }
    );
  end
end 


function GridGachaMainDlg:_OnGetRewardResponse(response)
  if self.m_viewModel == nil then
    return
  end
  local openedPosition = response.openedPosition;
  local addGrandPosition = response.addGrandPosition;
  local horizonLine = self.m_horizonLineView[openedPosition[2] + 1];
  local verticalLine = self.m_verticalLineView[openedPosition[1] + 1];
  local openedType = response.openedType;
  local reward = response.rewards[1]["count"];
  local pack = nil;
  local scanShineImage = nil;

  self.m_viewModel:InitData(self.m_actId, self.m_poolCount);
  self.m_viewModel:MarkGachaStart();
  self.m_confirmSwitch.isShow = false;
  self.m_processSwitch.isShow = true;
  
  
  self:Interval(0.05, 1, function()
    self._imgScanLine:DOAnchorPos({x = 584, y = 0}, 0.8);
    self:_InitSound(SOUND_SIGNAL_SCAN);
  end);
  
  if openedType ~= 2 then
    self:_CreateOrGetViewFromTable(self.m_viewMap, CalculatePosition(openedPosition[1], openedPosition[2]),
     self._package, self._layout);
  end

  pack = self.m_viewMap[CalculatePosition(openedPosition[1], openedPosition[2])];
  if openedType ~= 2 then
    scanShineImage = pack._panelScanShine;
  else
    scanShineImage = pack._panelGrandScanShine;
  end

  local timeDelta = 0.8 * (openedPosition[2] + 1)/ DFT_POOL_VERTICAL_COUNT;
  if timeDelta > 0.85 then
    timeDelta = 0.85;
  end
  self:Interval(0.05 + timeDelta, 1, function()
    scanShineImage:DOFade(1, 0.4);
  end);
  
  
  self:Interval(1.17, 1, function()
    self:_SwitchFlash(horizonLine.gachaRandomSwitch, 2, true, SOUND_SIGNAL_BLINK);
  end);
  self:Interval(1.81, 1, function()
    self:_SwitchFlash(verticalLine.gachaRandomSwitch, 2, true, SOUND_SIGNAL_BLINK);
  end);
  
  self:Interval(2.13, 1, function()
    self:_ShowTriangle(horizonLine);
  end);
  self:Interval(2.77, 1, function()
    self:_ShowTriangle(verticalLine);
  end);
  
  self:Interval(2.29, 1, function()
    self:_InitSound(SOUND_SIGNAL_LASER);
    horizonLine._rectRedLine:DOSizeDelta({x = 1, y = RED_LINE_LENGTH}, 0.8);
    scanShineImage:DOFade(0, 0.2);
  end);
  self:Interval(2.93, 1, function()
    self:_InitSound(SOUND_SIGNAL_LASER);
    verticalLine._rectRedLine:DOSizeDelta({x = 1, y = RED_LINE_LENGTH}, 0.8);
  end);
  
  self:Interval(2.8, 1, function()
    self:_SwitchFlash(horizonLine.lineEndSwitch, 2, true, SOUND_SIGNAL_BLINK);
  end);
  self:Interval(3.44, 1, function()
    self:_SwitchFlash(verticalLine.lineEndSwitch, 2, true, SOUND_SIGNAL_BLINK);
  end);
  
  self:Interval(3.6, 1, function()
    horizonLine._rectRedLine.anchorMin = {x = 0, y = 0};
    horizonLine._rectRedLine.anchorMax = {x = 0, y = 0};
    horizonLine._rectRedLine.pivot = {x = 0, y = 0};
    horizonLine._rectRedLine:DOSizeDelta({x = 1, y = 0}, 0.8);
  end);
  self:Interval(4.24, 1, function()
    verticalLine._rectRedLine.pivot = {x = 0, y = 0};
    verticalLine._rectRedLine.anchorMin = {x = 0, y = 0};
    verticalLine._rectRedLine.anchorMax = {x = 0, y = 0};
    verticalLine._rectRedLine:DOSizeDelta({x = 1, y = 0}, 0.8);
  end);
  
  self:Interval(3.6, 1, function()
    horizonLine._rectBlackLine.sizeDelta = {x = 1, y = BLACK_LINE_LENGTH};
  end);
  self:Interval(4.24, 1, function()
    verticalLine._rectBlackLine.sizeDelta = {x = 1, y = BLACK_LINE_LENGTH};
  end);
  
  self:Interval(4.41, 1, function()
    self:_SwitchFlash(horizonLine.lineEndSwitch, 2, false, SOUND_SIGNAL_BLINK);
  end);
  self:Interval(5.04, 1, function()
    self:_SwitchFlash(verticalLine.lineEndSwitch, 2, false, SOUND_SIGNAL_BLINK);
  end);
  self:Interval(4.65, 1, function()
    horizonLine.triangleSwitch.isShow = false;
  end);
  self:Interval(5.28, 1, function()
    verticalLine.triangleSwitch.isShow = false;
  end);

  if(openedType ~= 2) then
    pack._imgCritical.color = {r = 1, g = 1, b = 1, a = 0};
    pack._panelReward.alpha = 0;
    pack._shineRect.anchoredPosition = {x = 0, y = 15.6, z = 0};
    pack._rewardRect.anchoredPosition = {x = 0, y = 12, z = 0};
    self:Interval(3.6 + 0.8 * (openedPosition[1] - 1) / DFT_POOL_VERTICAL_COUNT, 1, function() 
      self:_InitSound(SOUND_SIGNAL_LOCATE);
      pack._panelReward:DOFade(1, 0.3);
      pack._shineRect:DOAnchorPos({x = 0, y = 0, z = 0}, 0.3);
      pack._rewardRect:DOAnchorPos({x = 0, y = 0, z = 0}, 0.3);
    end);

    
    if(openedType == 1) then
      self:Interval(5.32, 1, function()
        pack._panelCritical.anchoredPosition = {x = 0, y = 12, z = 0};
        pack._imgCritical:DOFade(1, 0.3);
        pack._panelCritical:DOAnchorPos({x = 0, y = 0, z = 0}, 0.3);
      end);
    end
  
  elseif openedType == 2 then
    self:Interval(5.32, 1, function()
      self:_InitSound(SOUND_SIGNAL_LOCATE);
      pack._panelCritical.anchoredPosition = {x = 0, y = 12, z = 0};
      pack._imgCritical:DOFade(1, 0.3);
      pack._panelCritical:DOAnchorPos({x = 0, y = 0, z = 0}, 0.3);
    end);
    self:Interval(5.65, 1, function()
      pack._panelGrandShine:DOSizeDelta({x = 171, y = 171}, 0.3);
    end);
  end

  
  self._bannerText.text = self.m_gridGachaText[openedType + 1];
  if openedType == 0 then
    self._panelBannerNormal:SetActive(true);
  elseif openedType == 1 then
    self._panelBannerCritical:SetActive(true);
  else
    self._panelBannerGrand:SetActive(true);
  end
  self:Interval(6, 1, function()
    self:_InitSound(SOUND_SIGNAL_POPUP);
    self._maskBanner:DOSizeDelta({x = 1206, y = 650}, 0.3);
  end);
  
  self:Interval(6.8, 1, function()
    self._defaultText.color = {r = 0, g = 0, b = 0, a = 0};
    self._gachaText.text = self.m_gridGachaText[openedType + 1];
    self._bannerGroup.anchorMin = {x = 0, y = 0.5};
    self._bannerGroup.anchorMax = {x = 0, y = 0.5};
    self._bannerGroup.anchoredPosition = {x = 0, y = -136, z = 0};
    self._maskBanner.pivot = {x = 0, y = 1};
    self._maskBanner.anchoredPosition = {x = 0, y = 0, z = 0};
    self._maskBanner:DOSizeDelta({x = 0, y = 650}, 0.3);
  end);
  
  self:Interval(7.05, 1, function()
    self._gachaText:DOFade(1, 0.3);
  end);
  
  self:Interval(7.2, 1, function()
    self:_InitSound(SOUND_SIGNAL_REWARD);
    self._imgTri1:DOFade(1, 0.3);
    self._rectTri1:DOAnchorPos({x = -72, y = 95, z = 0}, 0.3);
    self._textGroup1:DOSizeDelta({x = 192, y = 52, z = 0}, 0.6);
  end);
  self:Interval(7.5, 1, function()
    self._imgFinish1:DOSizeDelta({x = 192, y = 10, z = 0}, 0.6);
  end);
  self:Interval(7.8, 1, function()
    self:_InitSound(SOUND_SIGNAL_REWARD);
    self._textGroup2:DOSizeDelta({x = 192, y = 52, z = 0}, 0.6);
  end);
  self:Interval(8.1, 1, function()
    self:_InitSound(SOUND_SIGNAL_REWARD);
    self._textGroup3:DOSizeDelta({x = 192, y = 52, z = 0}, 0.6);
  end);
  self:Interval(8.4, 1, function()
    self:_InitSound(SOUND_SIGNAL_REWARD);
    self._textGroup4:DOSizeDelta({x = 192, y = 34, z = 0}, 0.6);
  end);
  self:Interval(8.7, 1, function()
    self._imgTri2:DOFade(1, 0.3);
    self._rectTri2:DOAnchorPos({x = -72, y = -151, z = 0}, 0.3);
  end);
  
  self:Interval(9.0, 1, function()
    self:_InitSound(SOUND_SIGNAL_TICK);
    self._panelImgDiamond:DOSizeDelta({x = 145, y = 35}, 0.5);
  end);
  self:Interval(9.5, 1, function()
    self._redDiamondText.text = reward;
    self._redDiamondText.color = {r = 0.75, g = 0.29, b = 0.25, a = 1};
    self._blackDiamondText.text = reward;
    self._blackDiamondText.color = {r = 0.06, g = 0.06, b = 0.06, a = 0.51};
    self._panelImgDiamond.pivot = {x = 1, y = 1};
    self._panelImgDiamond.anchoredPosition = {x = 145, y = -7.5, z = 0};
    self._panelImgDiamond:DOSizeDelta({x = 0, y = 35}, 0.3);
  end);
  self:Interval(10.0, 1, function()
    self._redDiamondText:DOFade(0, 0.3);
    self._blackDiamondText:DOFade(0.51, 0.3);
  end);

  self:Interval(10.8, 1, function()
    CS.Torappu.Activity.ActivityUtil.DoShowGainedItems(response.rewards);
  end);
  self:Interval(10.9, 1, function()
    self.m_processSwitch.isShow = false;
    self.m_finishedSwitch.isShow = true;
    self.m_viewModel:MarkGachaFinish();
    self:_RefreshContent();
  end);
end

function GridGachaMainDlg:_ShowTriangle(line)
  line.triangleSwitch.isShow = true;
  line._rectTri:DOAnchorPos({x = 15.5, y = 5, z = 0}, 0.16);
end

function GridGachaMainDlg:_SwitchFlash(switch, times, flag, signal)
  for i = 1, times - 1 do
    self:Interval(i * LINE_FLASH_TIME, 1, function()
      if signal ~= nil and flag then
        self:_InitSound(signal);
      end
      switch.isShow = flag;
    end);
    self:Interval(i * LINE_FLASH_TIME + LINE_FLASH_TIME / 2, 1, function()
      if signal ~= nil and not flag then
        self:_InitSound(signal);
      end
      switch.isShow = not flag;
    end);
  end
  self:Interval(times * LINE_FLASH_TIME, 1, function()
    if signal ~= nil and flag then
      self:_InitSound(signal);
    end
    switch.isShow = flag;
  end);
end

function GridGachaMainDlg:_HorizonLineRandom(times)
  for i = 1, times do
    local pos = CS.Torappu.RandomUtil.Range(1, DFT_POOL_HORIZON_COUNT);
    local line = self.m_horizonLineView[pos];
    self:Interval(i * LINE_RANDOM_FLASH_TIME, 1, function()
      line.gachaRandomSwitch.isShow = true;
    end);
    self:Interval(i * LINE_RANDOM_FLASH_TIME + LINE_RANDOM_FLASH_TIME / 2, 1, function()
      line.gachaRandomSwitch.isShow = false;
    end);
  end
end

function GridGachaMainDlg:_VerticalLineRandom(times)
  for i = 1, times do
    local pos = CS.Torappu.RandomUtil.Range(1, DFT_POOL_VERTICAL_COUNT);
    local line = self.m_verticalLineView[pos];
    self:Interval(i * LINE_RANDOM_FLASH_TIME, 1, function()
      line.gachaRandomSwitch.isShow = true;
    end);
    self:Interval(i * LINE_RANDOM_FLASH_TIME + LINE_RANDOM_FLASH_TIME / 2, 1, function()
      line.gachaRandomSwitch.isShow = false;
    end);
  end
end

function GridGachaMainDlg:_OnGetRewardResponseNoAnime(response)
  if self.m_viewModel == nil then
    return
  end
  local openedPosition = response.openedPosition;
  local addGrandPosition = response.addGrandPosition;
  local horizonLine = self.m_horizonLineView[openedPosition[2] + 1];
  local verticalLine = self.m_verticalLineView[openedPosition[1] + 1];
  local openedType = response.openedType;
  local reward = response.rewards[1]["count"];
  local pack = nil;
  local scanShineImage = nil;

  self.m_viewModel:InitData(self.m_actId, self.m_poolCount);
  self.m_viewModel:MarkGachaStart();
  self.m_confirmSwitch.isShow = false;
  self.m_processSwitch.isShow = true;

  
  self:Interval(0.05, 1, function()
    self._imgScanLine:DOAnchorPos({x = 584, y = 0}, 0.6);
    self:_InitSound(SOUND_SIGNAL_SCAN);
  end);
  
  if openedType ~= 2 then
    self:_CreateOrGetViewFromTable(self.m_viewMap, CalculatePosition(openedPosition[1], openedPosition[2]),
     self._package, self._layout);
  end

  pack = self.m_viewMap[CalculatePosition(openedPosition[1], openedPosition[2])];
  if openedType ~= 2 then
    scanShineImage = pack._panelScanShine;
  else
    scanShineImage = pack._panelGrandScanShine;
  end

  local timeDelta = 0.6 * (openedPosition[2] + 1)/ DFT_POOL_VERTICAL_COUNT;
  if timeDelta > 0.62 then
    timeDelta = 0.62;
  end
  self:Interval(0.05 + timeDelta, 1, function()
    scanShineImage:DOFade(1, 0.1);
  end);
  
  
  self:Interval(0.8, 1, function()
    self:_SwitchFlash(horizonLine.gachaRandomSwitch, 1, true, SOUND_SIGNAL_BLINK);
    self:_SwitchFlash(verticalLine.gachaRandomSwitch, 1, true, SOUND_SIGNAL_BLINK);
  end);
  
  self:Interval(0.96, 1, function()
    self:_ShowTriangle(horizonLine);
    self:_ShowTriangle(verticalLine);
  end);
  
  self:Interval(1.12, 1, function()
    self:_InitSound(SOUND_SIGNAL_LASER);
    horizonLine._rectRedLine:DOSizeDelta({x = 1, y = RED_LINE_LENGTH}, 0.4);
    verticalLine._rectRedLine:DOSizeDelta({x = 1, y = RED_LINE_LENGTH}, 0.4);
    scanShineImage:DOFade(0, 0.2);
  end);
  
  self:Interval(1.62, 1, function()
    self:_SwitchFlash(horizonLine.lineEndSwitch, 1, true);
    self:_SwitchFlash(verticalLine.lineEndSwitch, 1, true);
  end);
  
  self:Interval(1.8, 1, function()
    horizonLine._rectRedLine.anchorMin = {x = 0, y = 0};
    horizonLine._rectRedLine.anchorMax = {x = 0, y = 0};
    horizonLine._rectRedLine.pivot = {x = 0, y = 0};
    horizonLine._rectRedLine:DOSizeDelta({x = 1, y = 0}, 0.4);
    
    verticalLine._rectRedLine.pivot = {x = 0, y = 0};
    verticalLine._rectRedLine.anchorMin = {x = 0, y = 0};
    verticalLine._rectRedLine.anchorMax = {x = 0, y = 0};
    verticalLine._rectRedLine:DOSizeDelta({x = 1, y = 0}, 0.4);
  end);
  
  self:Interval(1.9, 1, function()
    horizonLine._rectBlackLine.sizeDelta = {x = 1, y = BLACK_LINE_LENGTH};
    verticalLine._rectBlackLine.sizeDelta = {x = 1, y = BLACK_LINE_LENGTH};
  end);
  
  self:Interval(2.3, 1, function()
    self:_SwitchFlash(horizonLine.lineEndSwitch, 1, false);
    self:_SwitchFlash(verticalLine.lineEndSwitch, 1, false);
  end);
  self:Interval(2.46, 1, function()
    horizonLine.triangleSwitch.isShow = false;
    verticalLine.triangleSwitch.isShow = false;
  end);

  if(openedType ~= 2) then
    pack._imgCritical.color = {r = 1, g = 1, b = 1, a = 0};
    pack._panelReward.alpha = 0;
    pack._shineRect.anchoredPosition = {x = 0, y = 15.6, z = 0};
    pack._rewardRect.anchoredPosition = {x = 0, y = 12, z = 0};
    self:Interval(1.8 + 0.4 * (openedPosition[1] - 1) / DFT_POOL_VERTICAL_COUNT, 1, function() 
      self:_InitSound(SOUND_SIGNAL_LOCATE);
      pack._panelReward:DOFade(1, 0.15);
      pack._shineRect:DOAnchorPos({x = 0, y = 0, z = 0}, 0.15);
      pack._rewardRect:DOAnchorPos({x = 0, y = 0, z = 0}, 0.15);
    end);

    
    if(openedType == 1) then
      self:Interval(2.3, 1, function()
        pack._panelCritical.anchoredPosition = {x = 0, y = 12, z = 0};
        pack._imgCritical:DOFade(1, 0.3);
        pack._panelCritical:DOAnchorPos({x = 0, y = 0, z = 0}, 0.15);
      end);
    end
  
  elseif openedType == 2 then
    self:Interval(2.3, 1, function()
      self:_InitSound(SOUND_SIGNAL_LOCATE);
      pack._panelCritical.anchoredPosition = {x = 0, y = 12, z = 0};
      pack._imgCritical:DOFade(1, 0.3);
      pack._panelCritical:DOAnchorPos({x = 0, y = 0, z = 0}, 0.15);
    end);
    self:Interval(2.6, 1, function()
      pack._panelGrandShine:DOSizeDelta({x = 171, y = 171}, 0.15);
    end);
  end

  
  self._bannerText.text = self.m_gridGachaText[openedType + 1];
  if openedType == 0 then
    self._panelBannerNormal:SetActive(true);
  elseif openedType == 1 then
    self._panelBannerCritical:SetActive(true);
  else
    self._panelBannerGrand:SetActive(true);
  end
  self:Interval(2.85, 1, function()
    self:_InitSound(SOUND_SIGNAL_POPUP);
    self._maskBanner:DOSizeDelta({x = 1206, y = 650}, 0.2);
  end);

  self:Interval(3.45, 1, function()
    CS.Torappu.Activity.ActivityUtil.DoShowGainedItems(response.rewards);
  end);
  self:Interval(3.5, 1, function()
    self.m_processSwitch.isShow = false;
    self.m_finishedSwitch.isShow = true;
    self.m_viewModel:MarkGachaFinish();
    self:_RefreshContent();
  end);
end 