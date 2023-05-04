local luaUtils = CS.Torappu.Lua.Util;










































GridGachaV2MainDlg = Class("GridGachaV2MainDlg", DlgBase);

local GridGachaV2ViewModel = require("Feature/Activity/GridGachaV2/GridGachaV2ViewModel");
local GridGachaV2SegmentView = require("Feature/Activity/GridGachaV2/GridGachaV2SegmentView");
local GridGachaV2ItemView = require("Feature/Activity/GridGachaV2/GridGachaV2ItemView");

local DFT_ITEM_COUNT = 100;
local DFT_GRAND_SEGMENT_COUNT = 3;

local RED_LINE_POS = {0, 53, 106, 159, 212, 264, 317, 370, 423, 476};

local function _SetActive(gameObj, isActive)
  luaUtils.SetActiveIfNecessary(gameObj, isActive);
end

local function _CreateSwitch(canvasGroup, time, defaultState)
  local ret = CS.Torappu.UI.FadeSwitchTween(canvasGroup, time);
  ret:Reset(defaultState);
  return ret;
end

local function _InitSound(signal)
  CS.Torappu.TorappuAudio.PlayUI(signal);
end


function GridGachaV2MainDlg:OnInit()
  local actId = self.m_parent:GetData("actId");
  self:_InitFromGameData(actId);

  self.m_itemViewMap = {};
  self.m_grandRewardSegmentView = {};
  self.m_viewModel = GridGachaV2ViewModel.new();

  self._animRightPanel:InitIfNot();
  self.m_rulePanelSwitchTween = _CreateSwitch(self._alphaRuleDetail, 0.2, false);

  self.m_viewModel:InitData(actId, DFT_ITEM_COUNT);
  self:_RefreshContent();

  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnClose);
  self:AddButtonClickListener(self._btnShowRule, self.EventOnShowRuleBtnClick);
  self:AddButtonClickListener(self._btnHideRule, self.EventOnHideRuleBtnClick);
  self:AddButtonClickListener(self._btnStart, self.EventOnConfirmClick);
  self:AddButtonClickListener(self._btnClose, self.EventOnCloseClick);
end

function GridGachaV2MainDlg:_InitFromGameData(actId)
  self.m_actId = actId;
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
  self._textRuleTitle.text = data.ruleTitle;
  self._textRuleContent.text = data.ruleText;
  self._textNormalCount.text = data.normalCount;
  self._textCriticalCount.text = data.criticalCount;
  self._textGrandCount.text = data.grandCount;
end

function GridGachaV2MainDlg:_RefreshContent()
  if self.m_viewModel == nil then
    return;
  end
  self:_RefreshBasicItems();
  self:_RefreshTextsAndButtons();
end

function GridGachaV2MainDlg:_RefreshBasicItems()
  local itemViewMap = self.m_itemViewMap;
  local models = self.m_viewModel.itemModels;
  for i = 1, DFT_ITEM_COUNT do 
    local model = models[i];
    if model ~= nil and (model.isGrand or model.isReward) then
      self:_CreateOrGetItemViewFromTable(i);
    end
  end
  for index, view in pairs(itemViewMap) do
    view:Render(self.m_viewModel.itemModels[index]);
  end
end

function GridGachaV2MainDlg:_RefreshTextsAndButtons()
  local viewModel = self.m_viewModel;
  local isFinish = viewModel:HasGacha();

  self.m_rulePanelSwitchTween:Reset(false);
  
  self._textEndTime.text = viewModel.endTimeDesc;

  for i = 1, #viewModel.grandSegmentStatus do
    local view = self.m_grandRewardSegmentView[i];
    if view == nil then
      view = self:CreateWidgetByPrefab(GridGachaV2SegmentView, self._prefabSegment, self._segmentContainer);
      self.m_grandRewardSegmentView[i] = view;
    end
    view:Render(viewModel.grandSegmentStatus[i]);
  end

  self._textPercent.text = tostring(math.floor(viewModel.grandPercent * 100));
  self._textDiamondCount.text = tostring(viewModel.rewards);

  if viewModel:HasGacha() then
    _SetActive(self._panelStartBtn, false);
    _SetActive(self._panelEndBtn, true);
    _SetActive(self._animBanner.gameObject, false);
    self._animRightPanel:SampleClipAtEnd(GridGachaV2AnimationName.RIGHT_PANEL_2);
  else
    _SetActive(self._panelStartBtn, true);
    _SetActive(self._panelEndBtn, false);
    _SetActive(self._animBanner.gameObject, true);
    self._animRightPanel:SampleClipAtBegin(GridGachaV2AnimationName.RIGHT_PANEL_1);
  end
end

function GridGachaV2MainDlg:_CreateOrGetItemViewFromTable(index)
  local view = self.m_itemViewMap[index];
  if view == nil then
    view = self:CreateWidgetByPrefab(GridGachaV2ItemView, self._prefabItem, self._itemContainer);
    view:InitView(self, index);
    self.m_itemViewMap[index] = view;
  end
  return view;
end

function GridGachaV2MainDlg:CalPosition(index)
  local x = math.ceil(index / 10);
  local y = index % 10;
  if y == 0 then
    y = 10;
  end
  return {x, y};
end

function GridGachaV2MainDlg:_OnGetAward(response)
  if self.m_viewModel == nil then
    return;
  end

  self.m_viewModel:InitData(self.m_actId, DFT_ITEM_COUNT);
  if not self.m_viewModel:HasGacha() then
    return;
  end

  if self.m_viewModel == nil then
    return;
  end

  local rewardModelId = self.m_viewModel.rewardModelId;
  local openedType = self.m_viewModel.openedType;
  local rewardPos = self:CalPosition(rewardModelId);
  local lineNum = rewardPos[1];
  local itemStartTime = 0.1 * (10 - lineNum) - 0.05;
  local itemAnimationType = GridGachaV2AnimationName.NORMAL;

  self.m_viewModel:MarkGachaStart();

  self._textDiamondCount.text = tostring(self.m_viewModel.rewards);
  _SetActive(self._imgBannerNormal, openedType == 0);
  _SetActive(self._imgBannerCritical, openedType == 1);
  _SetActive(self._imgBannerGrand, openedType == 2);

  if openedType ~= 2 then
    self:_CreateOrGetItemViewFromTable(rewardModelId);
  end

  if openedType == 1 then
    itemAnimationType = GridGachaV2AnimationName.CRITICAL;
  elseif openedType == 2 then
    itemAnimationType = GridGachaV2AnimationName.GRAND;
  end

  self._animButton:Play(GridGachaV2AnimationName.BUTTON);
  self._animRightPanel:Play(GridGachaV2AnimationName.RIGHT_PANEL_1);

  if self.m_viewModel:IsSegment() then
    self._rectHorizonLine.anchoredPosition = {x = -264, y = -RED_LINE_POS[rewardPos[1]], z = 0};
    self._rectVerticalLine.anchoredPosition = {x = RED_LINE_POS[rewardPos[2]], y = -264.57, z = 0};
    for index, view in pairs(self.m_itemViewMap) do
      view._anim:Play(GridGachaV2AnimationName.RED_CIRCLE);
    end
    _InitSound(GridGachaV2SoundName.BLINK);
    self:Interval(0.9, 1, function()
      _InitSound(GridGachaV2SoundName.LASER);
      self._animRedScanLine:Play(GridGachaV2AnimationName.RED_SCAN_LINE, {isFillAfter = false, isInverse = false});
    end);
    self:Interval(0.7 + itemStartTime, 1, function()
      _InitSound(GridGachaV2SoundName.LOCATE);
      self.m_itemViewMap[rewardModelId]._anim:Play(GridGachaV2AnimationName.SEGMENT);
    end);
    self:Interval(itemStartTime + 1.9, 1, function()
      self._animRightPanel:Play(GridGachaV2AnimationName.RIGHT_PANEL_2);
    end);
    self:Interval(itemStartTime + 3.9, 1, function()
      _InitSound(GridGachaV2SoundName.TICK);
    end);
    self:Interval(itemStartTime + 2.2, 1, function()
      _InitSound(GridGachaV2SoundName.BANNER);
      self._animBanner:Play(GridGachaV2AnimationName.BANNER);
    end);
    self:Interval(itemStartTime + 4.1, 1, function()
      self._textPercent.text = tostring(math.floor(self.m_viewModel.grandPercent * 100));
    end);
    self:Interval(itemStartTime + 4.5, 1, function()
      CS.Torappu.Activity.ActivityUtil.DoShowGainedItems(response.items);
    end);
    self:Interval(itemStartTime + 4.55, 1, function()
      self.m_viewModel:MarkGachaFinish();
      self:_RefreshContent();
    end);
  else
    _InitSound(GridGachaV2SoundName.SCAN);
    self._animScanLine:Play(GridGachaV2AnimationName.SCAN_LINE, {isFillAfter = false, isInverse = false});
    self:Interval(itemStartTime, 1, function()
      _InitSound(GridGachaV2SoundName.BLINK);
      self.m_itemViewMap[rewardModelId]._anim:Play(itemAnimationType);
    end);
    self:Interval(itemStartTime + 1.2, 1, function()
      self._animRightPanel:Play(GridGachaV2AnimationName.RIGHT_PANEL_2);
    end);
    self:Interval(itemStartTime + 3.2, 1, function()
      _InitSound(GridGachaV2SoundName.TICK);
    end);
    self:Interval(itemStartTime + 1.5, 1, function()
      _InitSound(GridGachaV2SoundName.BANNER);
      self._animBanner:Play(GridGachaV2AnimationName.BANNER);
    end);
    self:Interval(itemStartTime + 3.4, 1, function()
      self._textPercent.text = tostring(math.floor(self.m_viewModel.grandPercent * 100));
    end);
    self:Interval(itemStartTime + 3.8, 1, function()
      CS.Torappu.Activity.ActivityUtil.DoShowGainedItems(response.items);
    end);
    self:Interval(itemStartTime + 3.85, 1, function()
      self.m_viewModel:MarkGachaFinish();
      self:_RefreshContent();
    end);
  end
end


function GridGachaV2MainDlg:EventOnConfirmClick()
  local viewModel = self.m_viewModel;
  if viewModel == nil or viewModel:HasGacha() then
    return;
  end
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end

  UISender.me:SendRequest(GridGachaV2ServerCode.GACHA,
    {
      activityId = self.m_actId,
    },
    {
      onProceed = Event.Create(self, self._OnGetAward)
    }
  );
end

function GridGachaV2MainDlg:EventOnCloseClick()
  local viewModel = self.m_viewModel;
  if viewModel ~= nil and viewModel:IsShowing() then
    return;
  end
  self:Close();
end

function GridGachaV2MainDlg:EventOnShowRuleBtnClick()
  self.m_rulePanelSwitchTween.isShow = true;
end

function GridGachaV2MainDlg:EventOnHideRuleBtnClick()
  self.m_rulePanelSwitchTween.isShow = false;
end