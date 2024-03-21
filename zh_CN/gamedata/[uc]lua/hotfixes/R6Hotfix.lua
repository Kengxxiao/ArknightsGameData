local R6Hotfix = Class("R6Hotfix", HotfixBase)

local function _Fix_RefreshStatus(self)
    self:RefreshStatus()
    self.hideFlag = self.hideFlag and not self.isUnlocked
end


function R6Hotfix:OnInit()
    xlua.private_accessible(CS.Torappu.UI.Home.HomeThemeItemModel)
    self:Fix_ex(CS.Torappu.UI.Home.HomeThemeItemModel, "RefreshStatus", function(self, manager)
        local ok, ret = xpcall(_Fix_RefreshStatus, debug.traceback, self, manager)
        if not ok then
          LogError("[Hotfix] failed to RefreshStatus : ".. ret)
          return self:RefreshStatus(manager)
        else
          return ret
        end
      end)
    end

return R6Hotfix