local Ease = CS.DG.Tweening.Ease

local BlessOnlyBlessListHorizontalItem = require("Feature/Activity/BlessOnly/BlessOnlyBlessListHorizontalItem")
local BlessOnlyBlessListVerticalItem = require("Feature/Activity/BlessOnly/BlessOnlyBlessListVerticalItem")
local BlessOnlyBlessListSliderItemView = require("Feature/Activity/BlessOnly/BlessOnlyBlessListSliderItemView")
local FadeSwitchTween = CS.Torappu.UI.FadeSwitchTween;










































local BlessOnlyBlessListView = Class("BlessOnlyBlessListView", UIPanel);

local PANEL_HIDE_DURATION = 0.16;

local PANEL_ENTRY = "act1blessing_list_entry";
local MOVE_LEFT_OUT = "act1blessing_list_switch_prev_hide";
local MOVE_LEFT_IN = "act1blessing_list_switch_prev_entry";
local MOVE_RIGHT_OUT = "act1blessing_list_switch_next_hide";
local MOVE_RIGHT_IN = "act1blessing_list_switch_next_entry";

function BlessOnlyBlessListView:OnInit()
  self:AddButtonClickListener(self._leftArrowBtn, self._OnClickLeftArrowBtn);
  self:AddButtonClickListener(self._rightArrowBtn, self._OnClickRightArrowBtn);
  self:AddButtonClickListener(self._closeBtn, self._OnCloseBlessList);
  self:AddButtonClickListener(self._fullScreenBtn, self._OnCloseBlessList);
  self:AddButtonClickListener(self._btnSwitch, self._OnSwitchBtnClick);
  self:AddButtonClickListener(self._btnConfirm, self._OnConfirmBtnClick);
  self:AddButtonClickListener(self._btnShare, self._OnShareBtnClick);
  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._closeBtn);

  self.m_blessOnlyBlessListHorizontalItem = self:CreateWidgetByGO(BlessOnlyBlessListHorizontalItem, self._blessOnlyBlessListHorizontalItem);
  self.m_blessOnlyBlessListVerticalItem = self:CreateWidgetByGO(BlessOnlyBlessListVerticalItem, self._blessOnlyBlessListVerticalItem);

  self.m_horFadeTween = FadeSwitchTween(self._horCanvasGroup);
  self.m_horFadeTween:Reset(false);
  self.m_verFadeTween = FadeSwitchTween(self._verCanvasGroup);
  self.m_verFadeTween:Reset(false);
  
  self.m_sliderAdapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._sliderContent,
      self._CreateSliderItemView, self._GetSliderItemCount, self._UpdateSliderItemView)
      
  SetGameObjectActive(self._selfObject, false);
end


function BlessOnlyBlessListView:OnViewModelUpdate(data)
  if data == nil then
    return;
  end
  self.m_cachedViewModel = data;
  
  local isEnter = not(self.m_cachedIsShow) and data.isBlessListState;
  if isEnter then
    CS.Torappu.UI.UIPopupWindow.ShotBlurredImage(self._bgBlur);
  end
  
  if self.m_cachedIsShow ~= data.isBlessListState then
    if data.isBlessListState then 
      self:_ShowEntry();
    else
      self:_ShowHide();
    end
    self.m_cachedIsShow = data.isBlessListState;
  end
  
  local packetModel = data.openPacketModel;
  if not data.isBlessListState or packetModel == nil then
    return;
  end

  if isEnter or self.m_cachedIndex == packetModel.curIndex then
    self:_Render(data);
  else
    if self.m_switchBlessSequence ~= nil and self.m_switchBlessSequence:IsPlaying() then
      self.m_switchBlessSequence:Kill();
    end
    local outAnimName = "";
    local inAnimName = "";
    if self:_CheckIsMoveLeft(packetModel.curIndex, #packetModel.blessItemList) then
      
      outAnimName = MOVE_LEFT_OUT;
      inAnimName = MOVE_LEFT_IN;
    else
      
      outAnimName = MOVE_RIGHT_OUT;
      inAnimName = MOVE_RIGHT_IN;
    end
    self._animWrapper:InitIfNot();
    self._animWrapper:SampleClipAtBegin(outAnimName);
    self.m_switchBlessSequence = CS.DG.Tweening.DOTween.Sequence();
    self.m_switchBlessSequence:Append(self._animWrapper:PlayWithTween(outAnimName));
    self.m_switchBlessSequence:AppendCallback(function()
      self:_Render(data);
      self._animWrapper:SampleClipAtBegin(inAnimName);
    end);
    self.m_switchBlessSequence:Append(self._animWrapper:PlayWithTween(inAnimName));
  end

  return;
end


function BlessOnlyBlessListView:_Render(data)
  local packetModel = data.openPacketModel;
  if packetModel == nil then
    return;
  end
  self.m_cachedPacketModel = packetModel;
  self.m_cachedIndex = packetModel.curIndex;
  self.m_sliderAdapter:NotifyDataSetChanged();
  
  self.m_horFadeTween.isShow = data.blessListState == BlessOnlyBlessListState.HORIZONTAL;
  self.m_verFadeTween.isShow = data.blessListState == BlessOnlyBlessListState.VERTICAL;
  if data.blessListState == BlessOnlyBlessListState.HORIZONTAL then
    self.m_blessOnlyBlessListHorizontalItem:Render(data, self.illustLoader);
  elseif data.blessListState == BlessOnlyBlessListState.VERTICAL then
    self.m_blessOnlyBlessListVerticalItem:Render(data, self.illustLoader);
  end
  
  SetGameObjectActive(self._switchHorBtnPanel, data.blessListState == BlessOnlyBlessListState.VERTICAL);
  SetGameObjectActive(self._switchVerBtnPanel, data.blessListState == BlessOnlyBlessListState.HORIZONTAL);

  SetGameObjectActive(self._btnShare.gameObject, CS.Torappu.UI.CrossAppShare.CrossAppShareUtil.CheckBtnInTimeByMissionId(data.shareMissionId, false));
end

function BlessOnlyBlessListView:_ShowEntry()
  if self.m_entryHideTween ~= nil and self.m_entryHideTween:IsPlaying() then
    self.m_entryHideTween:Kill();
  end
  SetGameObjectActive(self._selfObject, true);
  self._animWrapper:InitIfNot();
  self._animWrapper:SampleClipAtBegin(PANEL_ENTRY);
  self.m_entryHideTween = self._animWrapper:PlayWithTween(PANEL_ENTRY):SetEase(Ease.Linear);;
end

function BlessOnlyBlessListView:_ShowHide()
  if self.m_entryHideTween ~= nil and self.m_entryHideTween:IsPlaying() then
    self.m_entryHideTween:Kill();
  end
  self.m_entryHideTween = self._canvasGroup:DOFade(0, PANEL_HIDE_DURATION):OnComplete(function()
    SetGameObjectActive(self._selfObject, false);
  end);;
end



function BlessOnlyBlessListView:_CreateSliderItemView(gameObj)
  local itemView = self:CreateWidgetByGO(BlessOnlyBlessListSliderItemView, gameObj);
  return itemView;
end


function BlessOnlyBlessListView:_GetSliderItemCount()
  if self.m_cachedPacketModel == nil or self.m_cachedPacketModel.blessItemList == nil then
    return 0
  end
  return #self.m_cachedPacketModel.blessItemList;
end



function BlessOnlyBlessListView:_UpdateSliderItemView(index, view)
  if self.m_cachedPacketModel == nil then
    return;
  end
  view:Render(self.m_cachedPacketModel.curIndex == index + 1);
end

function BlessOnlyBlessListView:_OnClickLeftArrowBtn()
  if self:_CheckIsSwitchSeqenceTweening() or self:_CheckIsFadeSwitchTweening() then
    return;
  end
  if self.onLeftArrowClick == nil then
    return;
  end
  Event.Call(self.onLeftArrowClick);
end

function BlessOnlyBlessListView:_OnClickRightArrowBtn()
  if self:_CheckIsSwitchSeqenceTweening() or self:_CheckIsFadeSwitchTweening() then
    return;
  end
  if self.onRightArrowClick == nil then
    return;
  end
  Event.Call(self.onRightArrowClick);
end

function BlessOnlyBlessListView:_OnCloseBlessList()
  if self.onCloseBtnClick == nil then
    return;
  end
  Event.Call(self.onCloseBtnClick);
end

function BlessOnlyBlessListView:_OnSwitchBtnClick()
  if self.m_entryHideTween ~= nil and self.m_entryHideTween:IsPlaying() then
    return;
  end
  if self:_CheckIsSwitchSeqenceTweening() then
    return;
  end
  if self.onSwitchBtnClick == nil then
    return;
  end
  Event.Call(self.onSwitchBtnClick);
end

function BlessOnlyBlessListView:_OnConfirmBtnClick()
  if self.onConfirmBtnClick == nil then
    return;
  end
  Event.Call(self.onConfirmBtnClick);
end

function BlessOnlyBlessListView:_CheckIsFadeSwitchTweening()
  return (self.m_entryHideTween ~= nil and self.m_entryHideTween:IsPlaying()) or
          self.m_horFadeTween ~= nil and self.m_horFadeTween.isTweening or
          self.m_verFadeTween ~= nil and self.m_verFadeTween.isTweening
end

function BlessOnlyBlessListView:_CheckIsSwitchSeqenceTweening()
  return self.m_switchBlessSequence ~= nil and self.m_switchBlessSequence:IsPlaying();
end

local UIPageController = CS.Torappu.UI.UIPageController;
function BlessOnlyBlessListView:_OnShareBtnClick()
  if self:_CheckIsSwitchSeqenceTweening() or self:_CheckIsFadeSwitchTweening() then
    return;
  end
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end

  if UIPageController.isTransiting then
    return;
  end

  local prefab, collector;
  if self.m_cachedViewModel.blessListState == BlessOnlyBlessListState.HORIZONTAL then
    local horizontalPrefabPath = CS.Torappu.ResourceUrls.GetAct1BlessingRemakeHorizontalItemPath();
    collector = self.m_blessOnlyBlessListHorizontalItem:CreateRemakeCollector();
    prefab = self:LoadPrefab(horizontalPrefabPath):GetComponent("Torappu.UI.CrossAppShare.CrossAppShareRemakeController");
  elseif self.m_cachedViewModel.blessListState == BlessOnlyBlessListState.VERTICAL then
    if self.m_blessOnlyBlessListVerticalItem:CheckIsShareIllustModelNil() then
      return;
    end
    local verticalPrefabPath = CS.Torappu.ResourceUrls.GetAct1BlessingRemakeVerticalItemPath();
    collector = self.m_blessOnlyBlessListVerticalItem:CreateRemakeCollector();
    prefab = self:LoadPrefab(verticalPrefabPath):GetComponent("Torappu.UI.CrossAppShare.CrossAppShareRemakeController");
  end

  local option = CS.Torappu.UI.UIPageOption();
  local inputParam = CS.Torappu.UI.CrossAppShare.CrossAppSharePage.InputParam();
  inputParam.remakePrefab = prefab;
  inputParam.additionModel = nil;
  inputParam.modelCollector = collector;
  inputParam.shareMissionId = self.m_cachedViewModel.shareMissionId;
  inputParam.effectType = CS.Torappu.UI.CrossAppShare.CrossAppShareDisplayEffects.EffectType.CAMERA_SIZE_TWEEN;

  option.args = inputParam;

  self:OpenPage3(CS.Torappu.UI.UIPageNames.CROSS_APP_SHARE_PAGE, option);
end




function BlessOnlyBlessListView:_CheckIsMoveLeft(curIndex, blessItemCnt)
  local index = self.m_cachedIndex - 1;
  if index < 1 then 
    index = blessItemCnt;
  end
  return curIndex == index;
end

return BlessOnlyBlessListView