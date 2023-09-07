


local CSHandBookMissionTrackPoint = CS.Torappu.UI.HandBook.HandBookV2MissionTrackPoint
local CRITICAL_TEAM = "action4"


local HandbookHotfixer = Class("HandbookHotfixer", HotfixBase)

local function _ResetHandbookFavorPoint(self)
  self:_RefreshData()
  local succ1,favorModel = self.m_forceId2FavorModelMap:TryGetValue(CRITICAL_TEAM)
  local succ2,favorCharModel = self.m_forceId2CharDataListMap:TryGetValue(CRITICAL_TEAM)
  if (not succ1 or not succ2) then
    return
  end
  favorModel.charCount = 0
  favorModel.favorSum = 0
  for _,v in pairs(favorCharModel) do
    local playerChar = CS.Torappu.CharacterUtil.GetPlayerInstByCharId(v.charId);
    if playerChar then
      favorModel.charCount = favorModel.charCount + 1
      local favorData = CS.Torappu.FavorDB.instance:GetFavorData(playerChar.favorPoint);
      if (favorData~=nil) then
        favorModel.favorSum = favorModel.favorSum + favorData.percent
      end
    end
  end
end

local function _CalcCharFavorPercent(charId)
  local playerChar = CS.Torappu.CharacterUtil.GetPlayerInstByCharId(charId);
  if playerChar == nil then
    return 0
  end
  local favorData = CS.Torappu.FavorDB.instance:GetFavorData(playerChar.favorPoint)
  if favorData == nil then
    return 0
  end
  return favorData.percent
end
local function _FixForceId2FavorSumMap(favorSumMap)
  if favorSumMap == nil then
    return
  end
  local found, favorSum = favorSumMap:TryGetValue(CRITICAL_TEAM)
  if not found then
    return
  end
  local favorToExclude = _CalcCharFavorPercent("char_1030_noirc2") + _CalcCharFavorPercent("char_1029_yato2")
  favorSum = favorSum - favorToExclude
  if favorSum < 0 then
    favorSum = 0
  end
  favorSumMap:Remove(CRITICAL_TEAM)
  favorSumMap:Add(CRITICAL_TEAM, favorSum)
end
local function _FixMissionTrackUpdateState(self, param)
  if self.m_forceId2FavorSumMap == nil then
    self.m_forceId2FavorSumMap = CS.System.Collections.Generic.Dictionary(CS.System.String, CS.System.Int32)()
    CSHandBookMissionTrackPoint._RefreshFavorSumMap(self.m_forceId2FavorSumMap)
    _FixForceId2FavorSumMap(self.m_forceId2FavorSumMap)
  end
  self.m_availFlag = CSHandBookMissionTrackPoint._GetTrackPointStateUsingMap(self.m_forceId2FavorSumMap)
end
local function _FixGetMissionTrackPointState()
  local favorMap = CS.System.Collections.Generic.Dictionary(CS.System.String, CS.System.Int32)()
  CSHandBookMissionTrackPoint._RefreshFavorSumMap(favorMap)
  local ok, errorInfo = xpcall(_FixForceId2FavorSumMap, debug.traceback, favorMap)
  if not ok then
    LogError("[Handbook] _FixGetMissionTrackPointState : " .. errorInfo)
    return false
  end
  return CSHandBookMissionTrackPoint._GetTrackPointStateUsingMap(favorMap)
end


local function _CheckIfBadVersionForRogueWeb()
  if CS.Torappu.Network.NetworkUtil.GetPlatformKey() ~= CS.Torappu.PlatformKey.ANDROID then
    return false
  end
  if CS.UnityEngine.Application.version ~= "1.9.81" then
    return false
  end
  if CS.U8.SDK.U8SDKInterface.Instance.worldId ~= 2 then
    return false
  end
  return true
end
local function _FixRoguelikeTopicButtonClicked(self)
  
  if _CheckIfBadVersionForRogueWeb() then
    CS.Torappu.UI.UINotification.TextToast("相关功能优化中，请等待后续开放") 
    return
  end

  self:EventOnClicked()
end

function HandbookHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.HandBook.HandBookV2FavorMissionStateBean)
  self:Fix_ex(CS.Torappu.UI.HandBook.HandBookV2FavorMissionStateBean, "_RefreshData",
  function(self)
    local ok, errorInfo = xpcall(_ResetHandbookFavorPoint, debug.traceback, self)
    if not ok then
      LogError("[Handbook] ResetHandbookFavorPoint fix :" .. errorInfo)
    end
  end)

  self:Fix_ex(CSHandBookMissionTrackPoint, "UpdateState", function(self, param)
    local ok, errorInfo = xpcall(_FixMissionTrackUpdateState, debug.traceback, self, param)
    if not ok then
      LogError("[Handbook] CSHandBookMissionTrackPoint UpdateState :" .. errorInfo)
    end
  end)
  self:Fix_ex(CSHandBookMissionTrackPoint, "GetTrackPointState", _FixGetMissionTrackPointState)

  self:Fix_ex(CS.Torappu.UI.RoguelikeTopic.RoguelikeTopicWebButton, "EventOnClicked", function(self)
    local ok, error = xpcall(_FixRoguelikeTopicButtonClicked, debug.traceback, self)
    if not ok then
      LogError("[RogueWeb] Failed to fix rogue web entry :" .. error)
    end
  end)
end

function HandbookHotfixer:OnDispose()
end

return HandbookHotfixer