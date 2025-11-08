
local HomeThemeChangeStateHotfixer = Class("HomeThemeChangeStateHotfixer", HotfixBase)

local function OnResumeFix(self)
  pcall(CS.Torappu.UI.Home.HomeReplaceableState.OnResume, self)
  if self.isResumedFromStack then
    local homePage = self:GetPage()
    if homePage == nil then
      return
    end

    local presetInstId = self.m_stateBean.presetInstId
    if presetInstId == nil or presetInstId == "" then
      return
    end

    local playerCharRotation = CS.Torappu.PlayerData.instance.data.charRotation
    if playerCharRotation == nil or playerCharRotation.presets == nil or playerCharRotation.presets.Count == 0 then
      return
    end

    local ok, playerPreset = playerCharRotation.presets:TryGetValue(presetInstId)
    if (not ok) or playerPreset == nil then
      return
    end

    local bgId = playerPreset.background
    local param = CS.Torappu.UI.Home.MultiFormLoadParam()
    param.compType = CS.Torappu.UI.Home.HomeDisplayCompType.BACKGROUND
    param.mainId = bgId

    local pageSingleMethod = xlua.get_generic_method(CS.Torappu.UI.UIPage, "SingleComponent")
    local singleComponentOfHomeDisplay = pageSingleMethod(CS.Torappu.UI.Home.HomeDisplayController)
    local displayController = singleComponentOfHomeDisplay(homePage)

    if displayController == nil then
      return
    end

    local overrideFormId = displayController:GetActiveMultiformId(param)
    displayController:LoadHomeBackgroundInEditMode(bgId, overrideFormId, true)
    
    self.m_stateBean.themeChangeProperty:NotifyUpdate()
  end
end

function HomeThemeChangeStateHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.Home.HomeThemeChangeState)
  self:Fix_ex(CS.Torappu.UI.Home.HomeThemeChangeState, "OnResume", function(self)
    local ok, result = xpcall(OnResumeFix, debug.traceback, self)
    if not ok then
      LogError("[HomeThemeChangeStateHotfixer] fix" .. result)
    end
  end)
end

function HomeThemeChangeStateHotfixer:OnDispose()
end

return HomeThemeChangeStateHotfixer