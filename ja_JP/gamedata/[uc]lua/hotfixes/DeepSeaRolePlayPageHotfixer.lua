
local DeepSeaRolePlayPageHotfixer = Class("DeepSeaRolePlayPageHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util
local IntroStep = CS.Torappu.UI.DeepSeaRP.DeepSeaRPNodeDetailView.IntroStep

local function OnPlaceDiscoverFix(self, placeId)
  if self._mapContainer == nil or self._mapContainer.m_mapView == nil or self._mapContainer.m_mapView.isMapLock then
    return
  end

  self:_OnPlaceDiscover(placeId)

  if self._mapContainer ~= nil and self._mapContainer.m_mapView ~= nil then
    self._mapContainer.m_mapView.isMapLock = true
  end
end

local function PrepareFontSizeFix(self, textComp, desc)
  if textComp == nil then
    return
  end
  self:_PrepareFontSize(textComp, desc)
end

local function OnChoiceSelectedFix(self, choiceIdx, eventData)
  if self._view.status ~= IntroStep.IDLE then
    return
  end

  self:_OnChoiceSelected(choiceIdx, eventData)

  self._view.status = IntroStep.UI_TWEEN
end

local function OnBtnLeaveFix(self)
  if self._view.status ~= IntroStep.IDLE then
    return
  end

  self:OnBtnLeave()

  self._view.status = IntroStep.UI_TWEEN
end

function DeepSeaRolePlayPageHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.DeepSeaRP.DeepSeaRolePlayPage)
  xlua.private_accessible(CS.Torappu.UI.DeepSeaRP.DeepSeaRPZoneMapContainer)

  self:Fix_ex(CS.Torappu.UI.DeepSeaRP.DeepSeaRolePlayPage, "_OnPlaceDiscover", function(self, placeId)
    local ok, errorInfo = xpcall(OnPlaceDiscoverFix, debug.traceback, self, placeId)
    if not ok then
      eutil.LogError("[DeepSeaRolePlayPageHotfixer] OnPlaceDiscoverFix" .. errorInfo)
    end
  end)

  xlua.private_accessible(CS.Torappu.UI.DeepSeaRP.DeepSeaRPNodeDetailView)

  self:Fix_ex(CS.Torappu.UI.DeepSeaRP.DeepSeaRPNodeDetailView, "_PrepareFontSize", function(self, textComp, desc)
    local ok, errorInfo = xpcall(PrepareFontSizeFix, debug.traceback, self, textComp, desc)
    if not ok then
      eutil.LogError("[DeepSeaRolePlayPageHotfixer] PrepareFontSizeFix" .. errorInfo)
    end
  end)

  xlua.private_accessible(CS.Torappu.UI.DeepSeaRP.DeepSeaRPNodeDetailState)

  self:Fix_ex(CS.Torappu.UI.DeepSeaRP.DeepSeaRPNodeDetailState, "_OnChoiceSelected", function(self, choiceIdx, eventData)
    local ok, errorInfo = xpcall(OnChoiceSelectedFix, debug.traceback, self, choiceIdx, eventData)
    if not ok then
      eutil.LogError("[DeepSeaRolePlayPageHotfixer] OnChoiceSelectedFix" .. errorInfo)
    end
  end)

  self:Fix_ex(CS.Torappu.UI.DeepSeaRP.DeepSeaRPNodeDetailState, "OnBtnLeave", function(self)
    local ok, errorInfo = xpcall(OnBtnLeaveFix, debug.traceback, self)
    if not ok then
      eutil.LogError("[DeepSeaRolePlayPageHotfixer] OnBtnLeaveFix" .. errorInfo)
    end
  end)
end

function DeepSeaRolePlayPageHotfixer:OnDispose()
end

return DeepSeaRolePlayPageHotfixer