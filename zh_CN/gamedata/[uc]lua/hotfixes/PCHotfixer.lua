local PCHotfixer = Class("PCHotfixer", HotfixBase)

local HotUpdateMgr = CS.Torappu.Resource.HotUpdateMgr
local ResPreferenceController = CS.Torappu.Resource.ResPreferenceController
local LoginViewController = CS.Torappu.UI.Login.LoginViewController

local function _Fix_ResetBeforeLoginStart()
  LoginViewController._ResetBeforeLoginStart()
  HotUpdateMgr.SetUpdate(ResPreferenceController.TYPE_VIDEO, true)
  local isFull = ResPreferenceController.IsFullHotupdatePreference()
  if not isFull then
    ResPreferenceController.MarkHotupdatePreference(true)
  end
end

function PCHotfixer:OnInit()
  
  if CS.Torappu.DeviceInfoUtil:IsPCMode() then
    xlua.private_accessible(LoginViewController)
    self:Fix_ex(LoginViewController, "_ResetBeforeLoginStart", function()
      local ok, err = xpcall(_Fix_ResetBeforeLoginStart, debug.traceback)
      if not ok then
        LogError("[PCHotfixer] _ResetBeforeLoginStart fix: " .. tostring(err))
        LoginViewController._ResetBeforeLoginStart()
      end
    end)
  end
end

function PCHotfixer:OnDispose()
end

return PCHotfixer
