local DIYPageHotfixer = Class("DIYPageHotfixer", HotfixBase)
 
local function _DoCameraTransFix(self, progress, isCeilingDir)
    curIsOrtho = self._diyRoom.mainCamera.orthographic;
    if isCeilingDir and curIsOrtho then
        return
    end
    if not isCeilingDir and not curIsOrtho then
        return
    end
    if not self.m_cachedMatrix then 
        self:_CacheOrthoPersMatrix(curIsOrtho)
        self.m_cachedMatrix = true
    end
    self._diyRoom:UpdateMaterialOutlineIfNeeded(not(isCeilingDir), progress)
    self._diyRoom.mainCamera.orthographic = curIsOrtho
    if CS.Torappu.MathUtil.LT(progress, 1) then
        if curIsOrtho then
            self._diyRoom.mainCamera.projectionMatrix = self:MatrixLerp(self.m_orthoMatrix, self.m_persMatrix, progress * progress)
        else
            self._diyRoom.mainCamera.projectionMatrix = self:MatrixLerp(self.m_persMatrix, self.m_orthoMatrix, CS.UnityEngine.Mathf.Sqrt(progress))
        end
    else
        self._diyRoom.mainCamera.orthographic = not(curIsOrtho);
        self._diyRoom.mainCamera:ResetProjectionMatrix()
    end
end

local function _FixOpenPage(self, pageName, openType, options)
  if pageName == "building_buy_labor" then
    pageName = "dyn_building_buy_labor"
  end
  self:_OpenPage(pageName, openType, options)
end
 
function DIYPageHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Building.UI.DIYPage)
    xlua.private_accessible(CS.Torappu.UI.UIPageController)

    self:Fix_ex(CS.Torappu.Building.UI.DIYPage, "_DoCameraPerspectiveTransIfNeeded", function(self, progress, isCeilingDir)
        local ok, errorInfo = xpcall(_DoCameraTransFix, debug.traceback, self, progress, isCeilingDir)
        if not ok then
            CS.UnityEngine.DLog.LogError(errorInfo)
        end
    end)

    self:Fix_ex(CS.Torappu.UI.UIPageController, "_OpenPage", _FixOpenPage)
end
 
function DIYPageHotfixer:OnDispose()
end
 
return DIYPageHotfixer