local DeepSeaRPBattlePreviewStateHotfixer = Class("DeepSeaRPBattlePreviewStateHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util
 
local function OnBtnStartBattleClickFix(self)
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  self:OnBtnStartPracticeClick();
end

local function OnBtnStartPracticeClickFix(self)
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  self:OnBtnStartPracticeClick();
end

local function ShowFix(self, param)
  self:Show(param);
end
 
function DeepSeaRPBattlePreviewStateHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.DeepSeaRP.DeepSeaRPBattlePreviewState)
  self:Fix_ex(CS.Torappu.UI.DeepSeaRP.DeepSeaRPBattlePreviewState, "OnBtnStartBattleClick", function(self)
    local ok, errorInfo = xpcall(OnBtnStartBattleClickFix, debug.traceback, self)
    if not ok then
      eutil.LogError("[DeepSeaRPBattlePreviewStateHotfixer] fix" .. errorInfo)
    end
  end);
  self:Fix_ex(CS.Torappu.UI.DeepSeaRP.DeepSeaRPBattlePreviewState, "OnBtnStartPracticeClick", function(self)
    local ok, errorInfo = xpcall(OnBtnStartPracticeClickFix, debug.traceback, self)
    if not ok then
      eutil.LogError("[DeepSeaRPBattlePreviewStateHotfixer] fix" .. errorInfo)
    end
  end);

  xlua.private_accessible(CS.Torappu.UI.DeepSeaRP.DeepSeaRPSquadHomeTechTreePluginView)
  self:Fix_ex(CS.Torappu.UI.DeepSeaRP.DeepSeaRPSquadHomeTechTreePluginView, "Show", function(self, param)
    local ok, errorInfo = xpcall(ShowFix, debug.traceback, self, param)
    if not ok then
      eutil.SetActiveIfNecessary(self.gameObject, false);
    end
  end);
end
 
function DeepSeaRPBattlePreviewStateHotfixer:OnDispose()
end
 
return DeepSeaRPBattlePreviewStateHotfixer