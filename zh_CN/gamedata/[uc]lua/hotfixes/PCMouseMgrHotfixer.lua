
local PCMouseMgrHotfixer = Class("PCMouseMgrHotfixer", HotfixBase)
local SceneConsts = CS.Torappu.SceneConsts;
local SDKHelper = CS.Torappu.SDK.SDKHelper;

local function _OnSceneChangedFix(self, scene, mode)
  if scene.name ~= SceneConsts.HOME then
    return
  end
  if not SDKHelper.hasInstance then
    return
  end
  SDKHelper.instance:ClearSdkViewState();
end

function PCMouseMgrHotfixer:OnInit()
  self:Fix_ex(CS.Torappu.UI.PCMouseMgr, "OnSceneChanged", function(self, scene, mode)
    self:OnSceneChanged(scene, mode)
    _OnSceneChangedFix(self, scene, mode)
  end)
end

return PCMouseMgrHotfixer
