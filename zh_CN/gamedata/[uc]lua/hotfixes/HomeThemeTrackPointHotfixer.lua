local HomeDisplayController = CS.Torappu.UI.Home.HomeDisplayController
local HomePage = CS.Torappu.UI.Home.HomePage
local HomeMainState = CS.Torappu.UI.Home.HomeMainState
local HomeThemeTrackPointHotfixer = Class("HomeThemeTrackPointHotfixer", HotfixBase)

local function _FixLoadHomeTheme(self, themeId)
  self:LoadHomeTheme(themeId)

  local homePage = self:GetPage()
  local stateEngine = homePage.stateEngine
  if stateEngine == nil then
    return
  end

  local homeMainState = stateEngine.defaultState
  if homeMainState == nil or homeMainState:GetType() ~= typeof(HomeMainState) then
    return
  end

  local homeMainStateBean = homeMainState._stateBean
  if homeMainStateBean == nil then
    return
  end
  homeMainStateBean:OnPlayerDataChanged()
end

function HomeThemeTrackPointHotfixer:OnInit()
  xlua.private_accessible(HomeDisplayController)
  xlua.private_accessible(HomePage)
  xlua.private_accessible(HomeMainState)

  self:Fix_ex(HomeDisplayController, "LoadHomeTheme", function(self, themeId)
    local ok, ret = xpcall(_FixLoadHomeTheme, debug.traceback, self, themeId)
    if not ok then
      LogError("[HomeThemeTrackPointHotfixer] _FixLoadHomeTheme" .. ret)
    end
  end)
end

return HomeThemeTrackPointHotfixer