local eutil = CS.Torappu.Lua.Util
local CSPageController = CS.Torappu.UI.UIPageController
local CSPageFinder = CS.Torappu.UI.UIPageFinder
local CSPageInterface = CSPageFinder.Interface
local CSSandboxUtil = CS.Torappu.UI.SandboxPerm.SandboxV2.SandboxV2Util
local CSPlayerData = CS.Torappu.PlayerData
local CSJObjectWrapper = CS.Torappu.JObjectWrapper
local CSUEObject = CS.UnityEngine.Object
local CSAnimSwitchTween = CS.Torappu.UI.AnimationSwitchTween
local CSAnimSwitchTweenBuilder = CSAnimSwitchTween.Builder
local CSAnimLocation = CS.Torappu.UI.UIAnimationLocation
local CSTweenEase = CS.DG.Tweening.Ease
local CSActivityDB = CS.Torappu.ActivityDB

local CSCustomDialogMgr = CS.Torappu.UI.UICustomDialogMgr
local CSDynDialogParam = CSCustomDialogMgr.DynDialogParam

local CSSandboxConfirmDialog = CS.Torappu.UI.SandboxPerm.SandboxV2.SandboxV2ConfirmDialog
local CSSandboxConfirmDialogOptions = CSSandboxConfirmDialog.Options
local CSSandboxV2ConfirmIconType = CS.Torappu.SandboxV2ConfirmIconType
local CSSandboxV2ConfirmDialogConfirmVisualType = CS.Torappu.UI.SandboxPerm.SandboxV2.SandboxV2ConfirmDialogConfirmVisualType
local CSSandboxV2ToastType = CS.Torappu.UI.SandboxPerm.SandboxV2.SandboxV2Const.SandboxV2ToastType

local TOPIC_SANDBOX_1 = "sandbox_1"
local SD1_MODE_PREFAB_PATH = "UI/SandboxPerm/Topics/[UC]sandbox_1/Home/mode_view"
local SD1_BUFF_KEY_TMPL = "EXPLORE_BUFF_{0}"
local NORMAL_MODE_NAME_KEY = "NORMAL_MODE_NAME"
local HARD_MODE_NAME_KEY = "HARD_MODE_NAME"

local SRV_CODE_EXPLORE_MODE = "/sandboxPerm/sandboxV2/exploreMode"

local function _IsUEObjectDestroyed(obj)
  return eutil.IsDestroyed(obj)
end

local s_modeModules = {}

local s_ShowSandboxV2ConfirmDialog = nil
local function _GetShowSandboxV2ConfirmDialog()
  if s_ShowSandboxV2ConfirmDialog ~= nil then
    return s_ShowSandboxV2ConfirmDialog
  end
  s_ShowSandboxV2ConfirmDialog = xlua.get_generic_method(CSCustomDialogMgr, "Show")
  s_ShowSandboxV2ConfirmDialog = s_ShowSandboxV2ConfirmDialog(CSSandboxConfirmDialog, CSSandboxConfirmDialogOptions)
  return s_ShowSandboxV2ConfirmDialog
end


local SandboxV2ModeModule = Class("SandboxV2ModeModule")




















local SD1ModeModule = Class("SD1ModeModule")



function SandboxV2ModeModule.InitModeOnEntry(topicId, hostLayout)
	if topicId == TOPIC_SANDBOX_1 then
		s_modeModules[topicId] = SD1ModeModule.InitIfNot(topicId, hostLayout, s_modeModules[topicId])
	end
end


function SandboxV2ModeModule.NotifyRefresh(topicId)
  if topicId == TOPIC_SANDBOX_1 then
		local module = s_modeModules[topicId]
    SD1ModeModule.NotifyRefresh(module)
	end
end




function SD1ModeModule.InitIfNot(topicId, hostLayout, existInst)
  
  if hostLayout == nil then
    LogError("valid hostLayout must be provided")
    return nil
  end
  local hostCtrls = {}
  hostLayout:TraverseCtrlDefines(function(key, ctrl)
    hostCtrls[key] = ctrl
  end)
  local container = hostCtrls.modeContainer

  if existInst ~= nil and existInst.parent ~= container then
    existInst:DestroyModule()
    existInst = nil
  end
  if existInst ~= nil then
    return existInst
  end

  
  if _IsUEObjectDestroyed(container) then
    LogError("valid modeContainer should be configed on hostLayout: ".. hostLayout.gameObject.name)
    return nil
  end
  local pageFinder = CSPageFinder()
  local pageInterface = pageFinder:Current(container)
  local assetLoader = pageInterface:GetAssetLoader()
  if assetLoader == nil then
    return nil
  end
  local goPrefab = assetLoader:LoadAsset(SD1_MODE_PREFAB_PATH)
  if goPrefab == nil then
    return nil
  end

  local gameObject = CS.UnityEngine.GameObject.Instantiate(goPrefab, container)
  local layout = UIBase.GetLuaLayout(gameObject)
  if layout == nil then
    LogError(SD1_MODE_PREFAB_PATH .. " is not LuaLayout")
    gameObject:Destroy()
    return nil
  end

  local inst = SD1ModeModule.new(topicId, gameObject, layout, pageInterface)
  inst.parent = container

  inst:_Init()
  inst:_Refresh()
  return inst
end


function SD1ModeModule.NotifyRefresh(module)
  if module == nil or module.class ~= SD1ModeModule then
    return
  end
  module:_Refresh()
end





function SD1ModeModule:ctor(topicId, gameObject, layout, pageInterface)
  self.m_isDisposed = false
  self.m_topicId = topicId
  self.m_buttons = {}
  self.m_gameObject = gameObject
  self.m_layout = layout
  self.m_pageInterface = pageInterface
  self.m_exploreMode = false
  local this = self
  layout:BindLayoutEventListener(self)
	layout:TraverseCtrlDefines(function(name, ctrl)
    this["_"..name] = ctrl
  end);
  layout:TraverseValueDefines(function(name, value)
    this["_"..name] = value
  end)
end


function SD1ModeModule:DestroyModule()
  if not _IsUEObjectDestroyed(self.m_gameObject) then
    CSUEObject.Destroy(self.m_gameObject)
  else
    self:Dispose()
  end
end


function SD1ModeModule:AddButtonClickListener(btn, func, ...)
  if (not btn) or self.m_isDisposed then
      return;
  end
  local args = {...};
  local this = self;
  btn.onClick:AddListener(function()
      func(this, table.unpack(args));
  end);
  if self.m_buttons == nil then
    self.m_buttons = {}
  end
  table.insert(self.m_buttons, btn)
end


function SD1ModeModule:Dispose()
  self.m_isDisposed = true
  if self.m_buttons ~=nil then
    for i, btn in ipairs(self.m_buttons) do
      if not _IsUEObjectDestroyed(btn) then
        btn.onClick:RemoveAllListeners()
        btn.onClick:Invoke()
      end
    end
    self.m_buttons = nil
  end
  if self.m_layout ~= nil then
    self.m_layout:BindLayoutEventListener(nil)
    self.m_layout = nil
  end
  self.m_gameObject = nil

  if s_modeModules[self.m_topicId] == self then
    s_modeModules[self.m_topicId] = nil
  end

  self.m_tweenExploreOn:Release()
  self.m_tweenExploreOff:Release()
end


function SD1ModeModule:OnEnable()
end

function SD1ModeModule:OnDisable()
end

function SD1ModeModule:OnDestroy()
  self:Dispose()
end

function SD1ModeModule:OnResume()
end

function SD1ModeModule:OnExit()
end

function SD1ModeModule:OnTransInEnd()
end

function SD1ModeModule:OnTransOutEnd()
end


function SD1ModeModule:_Init()
  self:AddButtonClickListener(self._btnSwitch, self.OnModeButtonClicked)
  self.m_tweenExploreOn = self:_CreateAnimSwitch(self._clipExploreOn)
  self.m_tweenExploreOn:Reset(false)
  self.m_tweenExploreOff = self:_CreateAnimSwitch(self._clipExploreOff)
  self.m_tweenExploreOff:Reset(false)
  
  self.m_enableExploreTween = false
end


function SD1ModeModule:_Refresh()
  self:_UpdateData()

  local isActive = self:IsModuleActive()
  eutil.SetActiveIfNecessary(self.m_gameObject, isActive)
  if not isActive then
    return
  end

  if self.m_exploreMode then
    self:_SetExploreSwitchTween(self.m_tweenExploreOn, self.m_tweenExploreOff)
  else
    self:_SetExploreSwitchTween(self.m_tweenExploreOff, self.m_tweenExploreOn)
  end
end



function SD1ModeModule:_SetExploreSwitchTween(enable, disable)
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


function SD1ModeModule:OnModeButtonClicked()
  if not self:IsModuleActive() then
    return
  end
  self:_OpenJudgeDialog()
end


function SD1ModeModule:IsPageStable()
  return (not CSPageController.isTransiting) and (self.m_pageInterface:IsSamePage(CSPageController.activePage))
end



function SD1ModeModule:IsModuleActive()
  if self.m_isDisposed then
    return false
  end
  
  if not self.m_isNotGuide then
    return false
  end
  return true
end


function SD1ModeModule:_UpdateData()
  local this = self
  local ok, ret = xpcall(function()
    xlua.private_accessible(CSPlayerData)
    local statusObj = CSPlayerData.instance.m_rawData:GetValue("sandboxPerm"):GetValue("template"):GetValue("SANDBOX_V2"):
        GetValue(this.m_topicId):GetValue("status")
    local statusWrapper = CSJObjectWrapper(statusObj)

    this.m_exploreMode = statusWrapper:GetBool("exploreMode")
    local isGuide = statusWrapper:GetBool("isGuide")
    this.m_isNotGuide = not isGuide
  end, debug.traceback)
  if not ok then
    LogError("[_UpdateData] ".. ret)
    self.m_exploreMode = false
    self.m_isNotGuide = false
  end
end



function SD1ModeModule:_CreateAnimSwitch(clip)
  local animLocation = CSAnimLocation()
  animLocation.animationWrapper = self._anim
  animLocation.animationName = clip.name
  local builder = CSAnimSwitchTweenBuilder(animLocation)
  builder.ease = CSTweenEase.Linear
  builder.inactivateTargetIfHide = false
  return builder:Build()
end


function SD1ModeModule:_OpenJudgeDialog()
  if not self:IsPageStable() then
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



function SD1ModeModule:_ReadFromActStringMap(key)
  local ret = CSActivityDB.instance:GetStringRes(self.m_topicId, key)
  if ret == nil then
    return ""
  end
  return ret
end


function SD1ModeModule:_HandleSwitchExploreResp(response)
  self:_Refresh()
  
  local modeName;
  if self.m_exploreMode then
    modeName = self:_ReadFromActStringMap(NORMAL_MODE_NAME_KEY)
  else
    modeName = self:_ReadFromActStringMap(HARD_MODE_NAME_KEY)
  end
  CSSandboxUtil.ShowSandboxTextToast(self.m_pageInterface:GetAssetLoader(), CSSandboxV2ToastType.COMMON,
    eutil.Format(StringRes.SANDBOX_V2_EXPLORE_MODE_TOAST, modeName))
end

function SD1ModeModule:_SendExploreModeService()
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

return SandboxV2ModeModule