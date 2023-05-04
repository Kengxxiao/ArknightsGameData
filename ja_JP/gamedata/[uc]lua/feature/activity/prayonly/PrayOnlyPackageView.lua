


















local PrayOnlyPackageView = Class("PrayOnlyPackageView", UIWidget)

local ALPHA_FULL = 1
local ALPHA_SELECT = 0.75
local ALPHA_UNSELECTABLE = 0.35
local ALPHA_HIDE = 0.15
local COLOR_CNT_DFT = "#333333ff"

local ANIM_KEY_UNFOLD = "anim_unfold"
local ANIM_KEY_SLIDE_IN = "anim_slide_in"
local ANIM_KEY_SLIDE_OUT = "anim_slide_out"


local ANIM_UNFOLD_DUR = 0.56
local DELAY_SLIDE_IN = 0.23
local DELAY_SLIDE_OUT = 0.08
PrayOnlyPackageView.EFFECT_DURATION = 1.15

local PRAYING_PHASE_NONE = 0
local PRAYING_PHASE_UNFOLD = 1
local PRAYING_PHASE_SLIDE = 2

local STATE_NONE              = 0
local STATE_ACTIVE            = 1
local STATE_SELECT            = 2
local STATE_REWARD            = 3
local STATE_OPEN_HIDE         = 4
local STATE_UNSELECTABLE      = 5
local STATE_CLOSE_HIDE        = 6



local function _ClacTargetViewState(packModel)
  if packModel == nil then
    return STATE_NONE
  end
  if packModel.hasPrayed then
    
    if packModel.isConfirmedReward then
      return STATE_REWARD
    elseif packModel.isSelected then
      return STATE_OPEN_HIDE
    else
      return STATE_CLOSE_HIDE
    end
  
  else 
    if packModel.isSelected then
      return STATE_SELECT
    elseif not packModel.canSelectMore then
      return STATE_UNSELECTABLE
    else
      return STATE_ACTIVE
    end
  end

  return STATE_NONE
end


local function _CheckIfValueDirty(cache, target)
  if cache == nil or cache ~= target then
    return true
  end
  return false
end

local _SetActive = CS.Torappu.Lua.Util.SetActiveIfNecessary


function PrayOnlyPackageView:InitView(mainDlg, index)
  self.m_mainDlg = mainDlg
  self.m_viewState = STATE_NONE
  self:AddButtonClickListener(self._btnClick, self._OnClick)
  self.m_index = index
  self.m_viewCache = {}
  self._animWrapper:InitIfNot()

  local alphaOptions = CS.Torappu.UI.CanvasAlphaTweenSetter.Options()
  self.m_mainAlphaSetter = CS.Torappu.UI.CanvasAlphaTweenSetter(self._mainAlpha, alphaOptions)
  
end


function PrayOnlyPackageView:Render(packModel)
  local mainDlg = self.m_mainDlg
  if mainDlg == nil then
    return
  end
  self.m_viewModel = packModel
  local viewCache = self.m_viewCache

  local targetState = _ClacTargetViewState(packModel)
  
  local curState = self.m_viewState
  if curState == STATE_NONE or curState ~= targetState or 
      _CheckIfValueDirty(viewCache.isPraying, packModel.isPraying) then
    self.m_viewState = targetState
    viewCache.isPraying = packModel.isPraying
    self:_RenderStateRelated(targetState, packModel.isPraying)
  end
  if targetState == STATE_NONE then
    return
  end
  
  if _CheckIfValueDirty(viewCache.reward, packModel.reward) then
    self._textReward.text = tostring(packModel.reward)
    viewCache.reward = packModel.reward
  end
end

function PrayOnlyPackageView:GetPosTransform()
  return self._posAnchor
end

function PrayOnlyPackageView:IsActive()
  return self.m_viewState ~= STATE_NONE
end

function PrayOnlyPackageView:_OnClick()
  if self.m_viewModel == nil or self.m_mainDlg == nil then
    return
  end
  self.m_mainDlg:EventOnPackViewClicked(self.m_index)
end

function PrayOnlyPackageView:_SetActive(isActive)
  _SetActive(self:RootGameObject(), isActive)
end

function PrayOnlyPackageView:_RenderStateRelated(targetState, isPraying)
  if targetState == STATE_NONE then
    self:_SetActive(false)
    return
  else
    self:_SetActive(true)
  end

  local viewModel = self.m_viewModel
  local isClickable = targetState == STATE_ACTIVE or targetState == STATE_SELECT
  self._btnClick.interactable = isClickable
  self._raycaster.raycastTarget = isClickable

  _SetActive(self._panelShadow, targetState == STATE_ACTIVE)
  
  local isLighted = targetState == STATE_REWARD
  _SetActive(self._panelLight, isLighted)

  local showConfirmPanel = targetState == STATE_REWARD and (not isPraying)
  _SetActive(self._panelConfirmed, showConfirmPanel)

  local isOpend = targetState == STATE_OPEN_HIDE or targetState == STATE_REWARD
  _SetActive(self._panelInner, isOpend)

  _SetActive(self._panelSelectActive, targetState == STATE_SELECT)

  local isHilight = targetState == STATE_REWARD
  local rewardColor = nil
  if isHilight then
    rewardColor = self.m_mainDlg:GetHilightColor()
  end
  if rewardColor == nil then
    rewardColor = COLOR_CNT_DFT
  end
  self._textReward.color = CS.Torappu.ColorRes.TweenHtmlStringToColor(rewardColor)

  if isPraying then
    self:_TriggerPrayingEffect(self:_GetEffectAnimInfos(targetState, viewModel))
  elseif viewModel.hasPrayed then
    self:_SamplePrayedEffect(self:_GetEffectAnimInfos(targetState, viewModel))
  else 
    self:_SyncPrayingPhase(PRAYING_PHASE_NONE)
  end
end

function PrayOnlyPackageView:_SyncMainAlpha()
  local viewModel = self.m_viewModel
  local viewCache = self.m_viewCache
  local prayingPhase = PRAYING_PHASE_NONE
  if viewCache ~= nil and viewCache.prayingPhase ~= nil then
    prayingPhase = viewCache.prayingPhase
  end
  local curState = self.m_viewState

  
  local alpha = nil
  if prayingPhase == PRAYING_PHASE_UNFOLD then
    if viewModel.isSelected then
      alpha = ALPHA_FULL
    end
  elseif prayingPhase == PRAYING_PHASE_SLIDE then
    if not viewModel.isConfirmedReward then 
      alpha = ALPHA_HIDE
    end
  end

  if alpha == nil then 
    if curState == STATE_SELECT then
      alpha = ALPHA_SELECT
    elseif curState == STATE_OPEN_HIDE or curState == STATE_CLOSE_HIDE then
      alpha = ALPHA_HIDE 
    elseif curState == STATE_UNSELECTABLE then
      alpha = ALPHA_UNSELECTABLE
    else
      alpha = ALPHA_FULL 
    end
  end

  self.m_mainAlphaSetter:SetValue(alpha)
end




function PrayOnlyPackageView:_GetEffectAnimInfos(targetState, viewModel)
  local unfoldAnimKey = nil
  local slideAnimKey = nil
  local slideDelay = 0
  if viewModel.isSelected then
    unfoldAnimKey = ANIM_KEY_UNFOLD
  end
  if viewModel.isConfirmedReward then
    slideAnimKey = ANIM_KEY_SLIDE_OUT
    slideDelay = DELAY_SLIDE_OUT
  else 
    slideAnimKey = ANIM_KEY_SLIDE_IN
    slideDelay = DELAY_SLIDE_IN
  end
  return unfoldAnimKey, slideAnimKey, slideDelay
end


function PrayOnlyPackageView:_TriggerPrayingEffect(unfoldAnimKey, slideAnimKey, slideDelay)
  local viewCache = self.m_viewCache
  if viewCache.isAnimating then
    return
  end
  viewCache.isAnimating = true
  self:_SyncPrayingPhase(PRAYING_PHASE_UNFOLD)
  if unfoldAnimKey ~= nil then
    self._animWrapper:PlayWithTween(unfoldAnimKey)
  end
  local this = self
  local delay = ANIM_UNFOLD_DUR + slideDelay
  self:Interval(delay, 1, function()
    self:_SyncPrayingPhase(PRAYING_PHASE_SLIDE)
    this._animWrapper:PlayWithTween(slideAnimKey)
  end)
end


function PrayOnlyPackageView:_SamplePrayedEffect(unfoldAnimKey, slideAnimKey)
  local viewCache = self.m_viewCache
  viewCache.isAnimating = false
  local animWrapper = self._animWrapper
  if unfoldAnimKey ~= nil then
    animWrapper:SampleClipAtEnd(unfoldAnimKey)
  end
  animWrapper:SampleClipAtEnd(slideAnimKey)
  self:_SyncPrayingPhase(PRAYING_PHASE_SLIDE)
end

function PrayOnlyPackageView:_SyncPrayingPhase(prayingPhase)
  self.m_viewCache.prayingPhase = prayingPhase
  self:_SyncMainAlpha()
end

return PrayOnlyPackageView