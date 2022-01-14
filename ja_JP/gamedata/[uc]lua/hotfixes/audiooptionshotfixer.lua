local xutil = require('xlua.util')
local eutil = CS.Torappu.Lua.Util


local AudioOptionsHotfixer = Class("AudioOptionsHotfixer", HotfixBase)

local function _UnloadDynMixer(options)
  if options == nil then
    return
  end
  if options.m_dynHolder ~= nil then
    CS.Torappu.Resource.ResourceManager.UnloadAsset(options.m_dynHolder)
    options.m_dynHolder = nil
  end
end

local function _UpdateSetting()
  _UnloadDynMixer(CS.Torappu.Audio.AudioOptions.instance)
  CS.Torappu.AudioManager.instance:_OnSettingChange(
      CS.Torappu.Setting.SettingConstVars.SettingType.ALL)
end

local function _ActivityAssetMap_ForceReload(self)
  self:ForceReload()
  local ok, error = xpcall(_UpdateSetting, debug.traceback)
  if not ok then
    eutil.LogError(error)
  end
end

local function _AudioOptions_ReloadResImpl(self)
  _UnloadDynMixer(self)
end

function AudioOptionsHotfixer:OnInit()
   xlua.private_accessible(CS.Torappu.AudioManager)
   xlua.private_accessible(CS.Torappu.Audio.AudioOptions)

   self:Fix_ex(CS.Torappu.Activity.ActivityAssetMap, "ForceReload", _ActivityAssetMap_ForceReload)
   self:Fix_ex(CS.Torappu.Audio.AudioOptions, "_ReloadResImpl", _AudioOptions_ReloadResImpl)
end

function AudioOptionsHotfixer:OnDispose()
end

return AudioOptionsHotfixer