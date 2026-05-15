local AVGControllerHotfixer = Class("AVGControllerHotfixer", HotfixBase)

local TAG = "[AVGControllerHotfixer] "

local function _LogError(message)
  if LogError ~= nil then
    LogError(TAG .. tostring(message))
    return
  end
  if CS ~= nil and CS.UnityEngine ~= nil and CS.UnityEngine.Debug ~= nil then
    CS.UnityEngine.Debug.LogError(TAG .. tostring(message))
  end
end

local function _SafeBool(value)
  return value == true
end

local function _IsVideoOnly(controller)
  local ok, result = pcall(function()
    local story = controller.m_story
    return story ~= nil and story.isVideoOnly
  end)
  return ok and _SafeBool(result)
end

local function _ShouldEnableReaderMode(controller)
  if controller == nil then
    return false
  end

  return _SafeBool(controller.enableReader)
      and not _SafeBool(controller.isRunningTutorial)
      and not _SafeBool(controller.isTheaterMode)
      and not _IsVideoOnly(controller)
      and CS.Torappu.GameFlowController.CheckIsInStoryScene()
end

local function _OnStoryBegin(controller, story)
  controller:OnStoryBegin(story)

  if _IsVideoOnly(controller) then
    local settingBtn = controller._settingBtn
    if settingBtn ~= nil then
      settingBtn:SetActive(false)
    end
  end
end

local function _InstallWithHotfixBase(self)
  xlua.private_accessible(CS.Torappu.AVG.AVGController)

  local ok, err = pcall(function()
    self:Fix_ex(CS.Torappu.AVG.AVGController, "ShouldEnableReaderMode", function(controller)
      local ok, result = xpcall(_ShouldEnableReaderMode, debug.traceback, controller)
      if not ok then
        _LogError("ShouldEnableReaderMode fix failed: " .. tostring(result))
        return false
      end
      return result
    end)
  end)
  if not ok then
    _LogError("Install ShouldEnableReaderMode hotfix failed: " .. tostring(err))
  end

  ok, err = pcall(function()
    self:Fix_ex(CS.Torappu.AVG.AVGController, "OnStoryBegin", function(controller, story)
      local ok, err = xpcall(_OnStoryBegin, debug.traceback, controller, story)
      if not ok then
        _LogError("OnStoryBegin fix failed: " .. tostring(err))
      end
    end)
  end)
  if not ok then
    _LogError("Install OnStoryBegin hotfix failed: " .. tostring(err))
  end
end

function AVGControllerHotfixer:OnInit()
  _InstallWithHotfixBase(self)
end

function AVGControllerHotfixer:OnDispose()
end

return AVGControllerHotfixer
