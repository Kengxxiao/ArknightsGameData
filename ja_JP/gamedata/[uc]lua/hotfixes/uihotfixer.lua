
local UIHotfixer = Class("UIHotfixer", HotfixBase)

local function _ProcessDataBeforeEnteringMainGame()
  CS.Torappu.CharWord.VoiceLangManager.instance:UpdateGlobalVoiceLangWithPlayerData()
end

local function _HomePageOnCreate(self, savedInst)
  self:OnCreate(savedInst)

  local sceneBundle = CS.Torappu.GameFlowController.currentSceneBundle
  if sceneBundle ~= nil and sceneBundle.fromScene == "login" and sceneBundle.toScene == "home" then
    CS.Torappu.LocalTrackStore.NotifyEnteringMainGame()
  end
end

function UIHotfixer:OnInit()
  self:Fix_ex(CS.Torappu.UI.Login.LoginViewController, "_ProcessDataBeforeEnteringMainGame", _ProcessDataBeforeEnteringMainGame)
  self:Fix_ex(CS.Torappu.UI.Home.HomePage, "OnCreate", _HomePageOnCreate)
end

function UIHotfixer:OnDispose()
end

return UIHotfixer