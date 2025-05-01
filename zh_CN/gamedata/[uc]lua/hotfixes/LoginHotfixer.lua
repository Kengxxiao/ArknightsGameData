



local LoginHotfixer = Class("LoginHotfixer", HotfixBase)

local UIAssetLoader = CS.Torappu.UI.UIAssetLoader
local function _InjectLoginBkg(self)
  if self.isResumedFromStack then
    return
  end
  local bkg = CS.Torappu.Lua.LuaUIUtil.GetImage(self.gameObject, "image_bkg_back")
  if bkg == nil then
    return
  end
  local loadAsset_generic = xlua.get_generic_method(UIAssetLoader, "LoadAsset")
  local loadAssetFunc = loadAsset_generic(CS.UnityEngine.Sprite)
  local sprite = loadAssetFunc(UIAssetLoader.instance, "Arts/UI/Login/image_white")
  if sprite == nil then
    return
  end
  bkg.sprite = sprite
  bkg.color = CS.UnityEngine.Color.white
end

local function SetMoviePath(self, path)
  local status = self:GetCurrentStatus()
  if CS.Torappu.GameFlowController.currentScene == "hot_update" then
    local isTargetMovie = string.find(path, "MT01")  
    if isTargetMovie then
      local size = self._rect.sizeDelta;
      size.x = 1560
      size.y = 720
      self._rect.sizeDelta = size
    end
    if status == CS.Torappu.Video.AbstractMediaPlayerHolder.Status.PLAYEND and isTargetMovie then
      self:Play()
      return
    end
    self:SetPath(path)
    self:Play()
    return
  end
  self:SetPath(path)
end

local function OnApplicationPause(self ,status)
  return
end

function LoginHotfixer:OnInit()
  self:Fix_ex(CS.Torappu.UI.Login.LoginInitState, "OnResume", function(self)
    local ok, err = xpcall(_InjectLoginBkg, debug.traceback, self)
    if not ok then
      LogError("Failed to InjectLoginBkg : " .. err)
    end
    self:OnResume()
  end)
  xlua.private_accessible(typeof(CS.Torappu.Video.SofdecMediaPlayer))
  self:Fix_ex(CS.Torappu.Video.SofdecMediaPlayer, "SetPath", function(self,path)
    local ok, err = xpcall(SetMoviePath, debug.traceback, self,path)
    if not ok then
      self:SetPath(path)
      LogError("Failed to SetMoviePath : " .. err)
    end
  end)
  xlua.private_accessible(typeof(CS.Torappu.UI.HotUpdate.HotUpdaterPreMainMediaView))
  self:Fix_ex(CS.Torappu.UI.HotUpdate.HotUpdaterPreMainMediaView, "OnApplicationPause", function(self,status)
    local ok, err = xpcall(OnApplicationPause, debug.traceback, self,status)
    if not ok then
      LogError("Failed to OnApplicationPause : " .. err)
    end
  end)
end

return LoginHotfixer