local AutoChessUtilHotfixer = Class("AutoChessUtilHotfixer", HotfixBase)

local AutoChessUtil = CS.Torappu.UI.AutoChess.AutoChessUtil
local DateTimeUtil = CS.Torappu.DateTimeUtil

local function CheckModeTypeTrackPointFix(actId, modeType)
  local actData = AutoChessUtil.GetActAutoChessData(actId)
  if actData == nil or actData.modeDataDict == nil then
    return false
  end
  for modeId, modeData in pairs(actData.modeDataDict) do
    if modeData ~= nil and modeData.modeType == modeType then
      if modeData.startTime <= DateTimeUtil.timeStampNow then
        if AutoChessUtil.CheckModeTrackPoint(actId, modeData.modeId) then
          return true
        end
      end
    end
  end
  return false
end

function AutoChessUtilHotfixer:OnInit()
  self:Fix_ex(AutoChessUtil, "CheckModeTypeTrackPoint", function(actId, modeType)
    local ok, result = xpcall(CheckModeTypeTrackPointFix, debug.traceback, actId, modeType)
    if not ok then
      LogError("[AutoChessUtilHotfixer] CheckModeTypeTrackPoint fix error: " .. tostring(result))
      return false
    end
    return result
  end)
end

return AutoChessUtilHotfixer