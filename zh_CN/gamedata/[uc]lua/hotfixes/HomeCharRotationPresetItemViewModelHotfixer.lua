local HomeCharRotationPresetItemViewModelHotfixer = Class("HomeCharRotationPresetItemViewModelHotfixer", HotfixBase)

local function LoadDataFix(self, instId, playerData)
    self:LoadData(instId, playerData)
    self.profileSkinId = self.profileSkinTag
end

function HomeCharRotationPresetItemViewModelHotfixer:OnInit()
    xlua.private_accessible(typeof(CS.Torappu.UI.Home.HomeCharRotationPresetItemViewModel))

    self:Fix_ex(typeof(CS.Torappu.UI.Home.HomeCharRotationPresetItemViewModel), "LoadData", function(self, instId, playerData)
        local ok, errorInfo = xpcall(LoadDataFix, debug.traceback, self, instId, playerData)
        if not ok then
            LogError("[HomeCharRotationPresetItemViewModelHotfixer] fix" .. errorInfo)
            self:LoadData(instId, playerData)
        end
    end)
end

function HomeCharRotationPresetItemViewModelHotfixer:OnDispose()
end

return HomeCharRotationPresetItemViewModelHotfixer