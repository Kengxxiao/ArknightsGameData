local UICommentedTextHotfixer = Class("UICommentedTextHotfixer", HotfixBase)

local function _UICommentedTextHandleTerminate(self, stringIndex, xOffset, yOffset, buttonBoundInit, buttonBound)
  local cachedClickableTextData = self.m_cachedClickableTextData
  if cachedClickableTextData == nil then
    return false
  end
  if cachedClickableTextData:GetEndIndex() ~= stringIndex then
    return false
  end
  if buttonBoundInit then
    buttonBound.x = buttonBound.x + xOffset
    buttonBound.y = buttonBound.y + yOffset
    buttonBound.z = buttonBound.z + xOffset
    buttonBound.w = buttonBound.w + yOffset
    cachedClickableTextData:AddBound(buttonBound)
  end
  self.m_cachedClickableTextData = nil
  return true
end

local function _FixCalculateClickableTextBound(self, clickableTextData, buttonBound, buttonBoundInit, lastCharMinY, xOffset, yOffset, stringIndex)
  local ok, ret = xpcall(_UICommentedTextHandleTerminate, debug.traceback, self, stringIndex, xOffset, yOffset, buttonBoundInit, buttonBound)
  if ok and ret then
    buttonBoundInit = false
    return buttonBound, buttonBoundInit, lastCharMinY
  elseif not ok then
    LogError("[UICommentedTextFixer] " .. ret)
  end

  return self:_CalculateClickableTextBound(clickableTextData, buttonBound, buttonBoundInit, lastCharMinY, xOffset, yOffset, stringIndex)
end

local function _CheckIfSimulator()
  local platform = CS.Torappu.Network.NetworkUtil.GetPlatformKey():GetHashCode()
  if platform ~= 1 then
    return false
  end
  local processor = CS.UnityEngine.SystemInfo.processorType
  if processor == nil then
    return false
  end
  return string.find(processor, "^x86") ~= nil
end

local function _FixRuntimeAtlasManagerOnInit(self)
  self:OnInit()
  if _CheckIfSimulator() then
    self._enableRuntimeAtlas = false
  end
end

local function _FixHotUpdateResumeBGM(self)
  self:_ResumeBGM()
  local atlasMgr = CS.Torappu.UI.RuntimeAtlasManager.instanceOrNull
  if atlasMgr ~= nil and _CheckIfSimulator() then
    atlasMgr._enableRuntimeAtlas = false
  end
end

local function _FixAudioCreateSoundForAVG(self, path, loop)
  local sound = self:CreateSoundForAVG(path, loop)
  local info = sound.info
  if info ~= nil then
    info.loop = loop
  end
  return sound
end

function UICommentedTextHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.UICommentedText)
  self:Fix_ex(CS.Torappu.UI.UICommentedText, "_CalculateClickableTextBound", _FixCalculateClickableTextBound)

  xlua.private_accessible(CS.Torappu.UI.RuntimeAtlasManager)
  self:Fix_ex(CS.Torappu.UI.RuntimeAtlasManager, "OnInit", function(self)
    local ok, ret = xpcall(_FixRuntimeAtlasManagerOnInit, debug.traceback, self)
    if not ok then
      LogError("[FixRuntimeAtlasManager] ".. ret)
    end
  end)

  xlua.private_accessible(CS.Torappu.UI.HotUpdate.HotUpdateViewController)
  self:Fix_ex(CS.Torappu.UI.HotUpdate.HotUpdateViewController, "_ResumeBGM", function(self)
    local ok, ret = xpcall(_FixHotUpdateResumeBGM, debug.traceback, self)
    if not ok then
      LogError("[FixHotUpdateResumeBGM] " .. ret)
    end
  end)

  xlua.private_accessible(CS.Torappu.Audio.Engine.AudioEngine)
  self:Fix_ex(CS.Torappu.Audio.Engine.AudioEngine, "CreateSoundForAVG", function(self, path, loop)
    local ok, ret = xpcall(_FixAudioCreateSoundForAVG, debug.traceback, self, path, loop)
    if not ok then
      LogError("[FixAudioCreateSoundForAVG] " .. ret)
      return self:CreateSoundForAVG(path, loop)
    end
    return ret
  end)
end

return UICommentedTextHotfixer