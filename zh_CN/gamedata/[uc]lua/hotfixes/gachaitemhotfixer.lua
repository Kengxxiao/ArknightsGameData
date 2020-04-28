local eutil = CS.Torappu.Lua.Util

---@class GahcaItemHotfixer:HotfixBase
local GahcaItemHotfixer = Class("GahcaItemHotfixer", HotfixBase)

local function _CheckIfCanCheckInAndResync()
  local canCheckin = CS.Torappu.PlayerData.instance.data.checkIn.canCheckIn
  if canCheckin then
    CS.Torappu.UI.UINotification.TextToast(CS.Torappu.StringRes.ALERT_SYNC_STATUS_NEED_CROSS_DAY, 0--[[delay]], true--[[useDeduplicate]])
    CS.Torappu.UI.UISyncDataUtil.instance:_RouteToHomeToResync()
  end
  return canCheckin
end

local function _FixRecruitOnce(self)
  if _CheckIfCanCheckInAndResync() then
    return
  end
  self:OnRecruitOnce()
end

local function _FixRecruitTen(self)
  if _CheckIfCanCheckInAndResync() then
    return
  end
  self:OnRecruitTen()
end

function GahcaItemHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.Recruit.RecruitGachaItemView)
  xlua.private_accessible(CS.Torappu.UI.UISyncDataUtil)
  self:Fix_ex(CS.Torappu.UI.Recruit.RecruitGachaItemView, "OnRecruitOnce", function(self)
    local ok, error = xpcall(_FixRecruitOnce, debug.traceback, self)
    if not ok then
      eutil.LogError("[FixRecruitGachaOnce] " .. error)
    end
  end)
  self:Fix_ex(CS.Torappu.UI.Recruit.RecruitGachaItemView, "OnRecruitTen", function(self)
    local ok, error = xpcall(_FixRecruitTen, debug.traceback, self)
    if not ok then
      eutil.LogError("[FixRecruitGachaTen] " .. error)
    end
  end)
end

function GahcaItemHotfixer:OnDispose()
end

return GahcaItemHotfixer