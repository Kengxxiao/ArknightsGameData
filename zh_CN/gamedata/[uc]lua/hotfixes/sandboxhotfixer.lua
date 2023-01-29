



local SandboxHotfixer = Class("SandboxHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util
local SandboxBattleFinishView = CS.Torappu.UI.Sandbox.SandboxBattleFinishView

local function PlayAnimFadeIn(self, nodeViewModel, node, bossPer, nestPer)
  self:_PlayAnimFadeIn(nodeViewModel, node, bossPer, nestPer);
  if (nodeViewModel.nodeType == CS.Torappu.SandboxNodeType.HOME) then
    local homeCount = node.baseInfo.Count;
    if (homeCount > 0) then
      self.m_sequence:Append(self._rewardGroup:DOFade(1, TWEEN_MOVE_DURATION));
    end
  end
end

local function Render_Fixed(self, nodeViewModel, dungeonViewModel)
  self:Render(nodeViewModel, dungeonViewModel)
  if nodeViewModel.unlocked then
	local weatherData = nodeViewModel.nodeWeatherData
	local weatherIcon = CS.Torappu.UI.Sandbox.SandboxUtil.LoadWeatherTypeIcon(self.bindDungeonMapView.bindController:GetPage(), weatherData.weatherId)
	self._imgWeatherIcon.sprite = weatherIcon
  end
end

function SandboxHotfixer:OnInit()
  xlua.private_accessible(SandboxBattleFinishView)
  self:Fix_ex(SandboxBattleFinishView, "_PlayAnimFadeIn", function(self, nodeViewModel, node, bossPer, nestPer)
    local ok, ret = xpcall(PlayAnimFadeIn, debug.traceback, self, nodeViewModel, node, bossPer, nestPer)
    if not ok then
      eutil.LogError("[PlayAnimFadeIn] fix" .. ret)
    end
  end)

  xlua.private_accessible(CS.Torappu.UI.Sandbox.SandboxNodeView)
  self:Fix_ex(CS.Torappu.UI.Sandbox.SandboxNodeView, "Render", function(self, nodeViewModel, dungeonViewModel)
    local ok, errorInfo = xpcall(Render_Fixed, debug.traceback, self, nodeViewModel, dungeonViewModel)
    if not ok then
      eutil.LogError("[SandboxDungeonNodeViewWeatherIconHotfixer] fix" .. errorInfo)
    end
  end)

end

function SandboxHotfixer:OnDispose()
end

return SandboxHotfixer