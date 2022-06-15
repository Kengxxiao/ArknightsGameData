local UIItemDescFloatStageDropDetailHotfixer = Class("UIItemDescFloatStageDropDetailHotfixer", HotfixBase);
local eutil = CS.Torappu.Lua.Util;
 
local function RenderClimbTowerFixer(self, enableDropRoute)
  self:RenderClimbTower(enableDropRoute);
  local lockedToast = CS.Torappu.UI.ClimbTower.ClimbTowerUtil.GetClimbTowerFuncLockedToast();
  local isClimbTowerOpen = lockedToast == nil or lockedToast == "";
  if isClimbTowerOpen then
    self:_SetButtonsGotoMode();
  else
    self:_SetButtonsUnlockMode();
  end
end
 
function UIItemDescFloatStageDropDetailHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.UIItemDescFloatStageDropDetail);

  self:Fix_ex(CS.Torappu.UI.UIItemDescFloatStageDropDetail, "RenderClimbTower", function(self, enableDropRoute)
    local ok, errorInfo = xpcall(RenderClimbTowerFixer, debug.traceback, self, enableDropRoute);
    if not ok then
      eutil.LogError("[UIItemDescFloatStageDropDetailHotfixer] fix" .. errorInfo);
    end
  end)
end
 
function UIItemDescFloatStageDropDetailHotfixer:OnDispose()
end
 
return UIItemDescFloatStageDropDetailHotfixer;