local ScreenshotManager = CS.Torappu.ScreenshotManager
local TorappuAudio = CS.Torappu.TorappuAudio
local eutil = CS.Torappu.Lua.Util


local ScreenshotManagerHotfixer = Class("ScreenshotManagerHotfixer", HotfixBase)

local SCREENSHOT_BTN_CLICK = "ON_SCREENSHOT_BTN_CLICK"

local function _PlayAcceptedCaptureSfx(accepted)
  if accepted then
    TorappuAudio.PlayUI(SCREENSHOT_BTN_CLICK)
  end
end

function ScreenshotManagerHotfixer:OnInit()
  self:Fix_ex(ScreenshotManager, "RequestCapture", function(self)
    local accepted = self:RequestCapture()
    local ok, err = xpcall(_PlayAcceptedCaptureSfx, debug.traceback, accepted)
    if not ok then
      eutil.LogHotfixError("[ScreenshotManagerHotfixer] RequestCapture: " .. err)
    end
    return accepted
  end)
end

function ScreenshotManagerHotfixer:OnDispose()
end

return ScreenshotManagerHotfixer
