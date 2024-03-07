local eutil = CS.Torappu.Lua.Util
local CSPageController = CS.Torappu.UI.UIPageController
local CSPageFinder = CS.Torappu.UI.UIPageFinder
local CSSandboxUtil = CS.Torappu.UI.SandboxPerm.SandboxV2.SandboxV2Util
local CSAnimSwitchTween = CS.Torappu.UI.AnimationSwitchTween
local CSAnimSwitchTweenBuilder = CSAnimSwitchTween.Builder
local CSAnimLocation = CS.Torappu.UI.UIAnimationLocation
local CSTweenEase = CS.DG.Tweening.Ease
local CSActivityDB = CS.Torappu.ActivityDB

local CSCustomDialogMgr = CS.Torappu.UI.UICustomDialogMgr
local CSDynDialogParam = CSCustomDialogMgr.DynDialogParam

local CSSandboxV2HomeController = CS.Torappu.UI.SandboxPerm.SandboxV2.SandboxV2HomeController
local CSSandboxConfirmDialog = CS.Torappu.UI.SandboxPerm.SandboxV2.SandboxV2ConfirmDialog
local CSSandboxConfirmDialogOptions = CSSandboxConfirmDialog.Options
local CSSandboxV2ConfirmIconType = CS.Torappu.SandboxV2ConfirmIconType
local CSSandboxV2ConfirmDialogConfirmVisualType = CS.Torappu.UI.SandboxPerm.SandboxV2.SandboxV2ConfirmDialogConfirmVisualType
local CSSandboxV2ToastType = CS.Torappu.UI.SandboxPerm.SandboxV2.SandboxV2Const.SandboxV2ToastType

local TOPIC_SANDBOX_1 = "sandbox_1"
local SD1_MODE_PREFAB_PATH = "SandboxPerm/Topics/[UC]sandbox_1/Home/mode_view"
local SD1_BUFF_KEY_TMPL = "EXPLORE_BUFF_{0}"
local NORMAL_MODE_NAME_KEY = "NORMAL_MODE_NAME"
local HARD_MODE_NAME_KEY = "HARD_MODE_NAME"

local SRV_CODE_EXPLORE_MODE = "/sandboxPerm/sandboxV2/exploreMode"

local function _IsUEObjectDestroyed(obj)
  return eutil.IsDestroyed(obj)
end

local s_ShowSandboxV2ConfirmDialog = nil
local function _GetShowSandboxV2ConfirmDialog()
  if s_ShowSandboxV2ConfirmDialog ~= nil then
    return s_ShowSandboxV2ConfirmDialog
  end
  s_ShowSandboxV2ConfirmDialog = xlua.get_generic_method(CSCustomDialogMgr, "Show")
  s_ShowSandboxV2ConfirmDialog = s_ShowSandboxV2ConfirmDialog(CSSandboxConfirmDialog, CSSandboxConfirmDialogOptions)
  return s_ShowSandboxV2ConfirmDialog
end

















SandboxV2DiffDialog = DlgMgr.DefineDialog("SandboxV2DiffDialog", SD1_MODE_PREFAB_PATH, DlgBase)

xlua.private_accessible(CSSandboxV2HomeController)

function SandboxV2DiffDialog:OnInit()
  self.m_tweenExploreOn = self:_CreateAnimSwitch(self._clipExploreOn)
  self.m_tweenExploreOn:Reset(false)
  self.m_tweenExploreOff = self:_CreateAnimSwitch(self._clipExploreOff)
  self.m_tweenExploreOff:Reset(false)
  self.m_isDisposed = false
  
  self.m_enableExploreTween = false
  self.m_pageInterface = CSPageFinder():Current(self.m_layout);

  
  self:AddButtonClickListener(self._btnSwitch, self.EventOnModeButtonClicked)

  
  self.m_propBinder = self:CreateCustomComponent(LuaDataBinder, Event.Create(self, self.OnValueChanged))
  local controller = self.m_layout.transform:GetComponentInParent(typeof(CSSandboxV2HomeController))
  if controller ~=nil then
    self.m_prop = controller.m_prop
    self.m_propBinder:BindToProperty(controller.m_prop)
  end
end

function SandboxV2DiffDialog:OnClose()
  self.m_isDisposed = true
end


function SandboxV2DiffDialog:OnValueChanged(model)
  
  self.m_exploreMode = model.isExploreMode
  self.m_isNotGuide = not model.isGuide
  self.m_topicId = model.topicId

  
  local isActive = self:IsModuleActive()
  eutil.SetActiveIfNecessary(self.m_root, isActive)
  if not isActive then
    return
  end

  if self.m_exploreMode then
    self:_SetExploreSwitchTween(self.m_tweenExploreOn, self.m_tweenExploreOff)
  else
    self:_SetExploreSwitchTween(self.m_tweenExploreOff, self.m_tweenExploreOn)
  end
end



function SandboxV2DiffDialog:_SetExploreSwitchTween(enable, disable)
  local isInitialRendering = (not enable.isShow) and (not disable.isShow)
  
  local skipTween = isInitialRendering or (not self.m_enableExploreTween)
  
  
  disable:Reset(false)
  if skipTween then
    enable:Reset(true)
    return
  end
  
  
  if (not enable.isShow) or enable.isTweening then
    enable:Reset(false)
    enable:Show()
  end
end


function SandboxV2DiffDialog:EventOnModeButtonClicked()
  if not self:IsModuleActive() then
    return
  end
  self:_OpenJudgeDialog()
end


function SandboxV2DiffDialog:IsPageStable()
  return (not CSPageController.isTransiting) and (self.m_pageInterface:IsSamePage(CSPageController.activePage))
end



function SandboxV2DiffDialog:IsModuleActive()
  if self.m_isDisposed then
    return false
  end
  
  if not self.m_isNotGuide then
    return false
  end
  return true
end



function SandboxV2DiffDialog:_CreateAnimSwitch(clip)
  local animLocation = CSAnimLocation()
  animLocation.animationWrapper = self._anim
  animLocation.animationName = clip.name
  local builder = CSAnimSwitchTweenBuilder(animLocation)
  builder.ease = CSTweenEase.Linear
  builder.inactivateTargetIfHide = false
  return builder:Build()
end


function SandboxV2DiffDialog:_OpenJudgeDialog()
  if not self:IsPageStable() then
    return
  end
  if self.m_topicId == nil then
    return 
  end

  local toExploreMode = not self.m_exploreMode 

  local options = CSSandboxConfirmDialogOptions.COMMON_OPTIONS
  options.iconId = CSSandboxUtil.LoadConfirmDialogIconId(self.m_topicId, CSSandboxV2ConfirmIconType.COMMON)
  options.confirmStr = StringRes.SANDBOX_V2_EXPLORE_MODE_CONFIRM
  options.confirmVisualType = CSSandboxV2ConfirmDialogConfirmVisualType.GREEN
  local dialogParam = CSDynDialogParam()
  dialogParam.resPath = CS.Torappu.ResourceUrls.GetSandboxV2ConfirmDialogPath()
  dialogParam.forceSingleInst = true

  if toExploreMode then
    options.titleStr = eutil.Format(StringRes.SANDBOX_V2_EXPLORE_MODE_ON_TITLE, self:_ReadFromActStringMap(NORMAL_MODE_NAME_KEY)) 
  else
    options.titleStr = eutil.Format(StringRes.SANDBOX_V2_EXPLORE_MODE_OFF_TITLE, self:_ReadFromActStringMap(HARD_MODE_NAME_KEY))
  end

  local descList = {}
  local descIndexValid = false
  local descIndex = 1
  repeat
    local key = eutil.Format(SD1_BUFF_KEY_TMPL, descIndex)
    local descItem = self:_ReadFromActStringMap(key)

    descIndexValid = descItem ~= nil and descItem ~= ""
    
    if descIndexValid then
      descItem = eutil.FormatRichTextFromData(descItem)
      table.insert(descList, descItem)
    end

    descIndex = descIndex + 1
  until not descIndexValid
  options.descStr = table.concat(descList, '\n')

  local this = self
  options.callback = function()
    this:_SendExploreModeService()
  end

  _GetShowSandboxV2ConfirmDialog()(CSCustomDialogMgr.instance, dialogParam, options)
end



function SandboxV2DiffDialog:_ReadFromActStringMap(key)
  local ret = CSActivityDB.instance:GetStringRes(self.m_topicId, key)
  if ret == nil then
    return ""
  end
  return ret
end


function SandboxV2DiffDialog:_HandleSwitchExploreResp(response)
  local model = nil
  if self.m_prop ~= nil and self.m_topicId ~= nil then
    model = self.m_prop:GetValueNotNull()
    model:Load(self.m_topicId)
    self.m_prop:NotifyUpdate()
  end

  if model == nil then
    return
  end
  
  local modeName;
  if model.isExploreMode then
    modeName = self:_ReadFromActStringMap(NORMAL_MODE_NAME_KEY)
  else
    modeName = self:_ReadFromActStringMap(HARD_MODE_NAME_KEY)
  end
  CSSandboxUtil.ShowSandboxTextToast(self.m_parent, CSSandboxV2ToastType.COMMON,
    eutil.Format(StringRes.SANDBOX_V2_EXPLORE_MODE_TOAST, modeName))
end

function SandboxV2DiffDialog:_SendExploreModeService()
  if not self:IsModuleActive() then
    return
  end
  local targetOpen = not self.m_exploreMode 
  local openVal
  if targetOpen then
    openVal = 1
  else
    openVal = 0
  end
  UISender.me:SendRequest(SRV_CODE_EXPLORE_MODE,
  {
    topicId = self.m_topicId,
    open = openVal
  },
  {
    onProceed = Event.Create(self, self._HandleSwitchExploreResp)
  })
end