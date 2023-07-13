



local SandboxHotfixer = Class("SandboxHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util
local SandboxBattleFinishView = CS.Torappu.UI.Sandbox.SandboxBattleFinishView
local SandboxStaminaPotViewModel = CS.Torappu.UI.Sandbox.SandboxStaminaPotViewModel;

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

local function _AddPreviewMapState_Fixed(self)
  if self.m_controller == nil then
    return
  end
  local model = self.m_controller.dungeonProperty:GetValueNotNull()
  local selectedNodeModel = model:GetSelectedNodeViewModel()
  if selectedNodeModel == nil then
    return
  end
  self:_AddPreviewMapState()
end

local function _AddPreviewUpgradeState_Fixed(self)
  if self.m_controller == nil then
    return
  end
  local model = self.m_controller.dungeonProperty:GetValueNotNull()
  local selectedNodeModel = model:GetSelectedNodeViewModel()
  if selectedNodeModel == nil then
    return
  end
  self:_AddPreviewUpgradeState()
end

local function _AddPreviewRewardState_Fixed(self)
  if self.m_controller == nil then
    return
  end
  local model = self.m_controller.dungeonProperty:GetValueNotNull()
  local selectedNodeModel = model:GetSelectedNodeViewModel()
  if selectedNodeModel == nil then
    return
  end
  self:_AddPreviewRewardState()
end

local function RefreshPlayerDataFixer(self)
  if self.foodDict ~= nil then
    for key, value in pairs(self.foodDict) do
      if value ~= nil then
        value.instList:Clear();
      end
    end
  end
  self:RefreshPlayerData();
end

local function OnBtnHudClicked_Fixed(self)
  if CS.Torappu.UI.UIPageController.isTransiting then
    return
  end
  self:OnBtnHudClicked()
end

local function _QuitAndSaveSquad_Fixed(self)
  if CS.Torappu.UI.UIPageController.isTransiting then
    return
  end
  self:_QuitAndSaveSquad()
end

local function OnViewModelRefresh_Fixed(self, viewModel)
  self:OnViewModelRefresh(viewModel)
  if self.m_viewModel == nil then
    return
  end
  eutil.SetActiveIfNecessary(self._giveUpWithBlackBox, self.m_viewModel.gameStatus == CS.Torappu.Activity.Act1sandbox.Act1sandboxGameLifeCycleViewModel.GameDetailStatus.ACTIVE_WITH_BLACKBOX)
  eutil.SetActiveIfNecessary(self._giveUpWithOutBlackBox, self.m_viewModel.gameStatus == CS.Torappu.Activity.Act1sandbox.Act1sandboxGameLifeCycleViewModel.GameDetailStatus.ACTIVE_WITHOUT_BLACKBOX)
end

local function FixItemListViewModel(viewModel)
  if viewModel.type == CS.Torappu.UI.Sandbox.SandboxItemListViewModel.Type.BLACKBOX_SELECT then
    viewModel.itemsSelected:Clear()
	local success, buildingAndTaticals = viewModel.itemsBlackBoxInBag:TryGetValue(CS.Torappu.UI.Sandbox.SandboxItemListViewModel.ItemGroupType.BUILDINGANDTACTICAL)
	if success then
	  local List_SandboxInventoryViewModel = CS.System.Collections.Generic.List(CS.Torappu.UI.Sandbox.SandboxInventoryViewModel)
      local list_inst = List_SandboxInventoryViewModel()
	  for index, item in pairs(buildingAndTaticals) do
	    if item.count > 0 then
		  list_inst:Add(item)
		end
	  end
	  viewModel.itemsBlackBoxInBag[CS.Torappu.UI.Sandbox.SandboxItemListViewModel.ItemGroupType.BUILDINGANDTACTICAL] = list_inst
	end
  end
end

local function InitItems_Fixed(self, actId)
  local viewModel = self.property:GetValueNotNull()
  viewModel:InitData(actId)
  FixItemListViewModel(viewModel)
  self.property:NotifyUpdate()
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

  xlua.private_accessible(CS.Torappu.UI.Sandbox.SandboxDungeonState)
  self:Fix_ex(CS.Torappu.UI.Sandbox.SandboxDungeonState, "_AddPreviewMapState", function(self)
    local ok, errorInfo = xpcall(_AddPreviewMapState_Fixed, debug.traceback, self)
    if not ok then
      eutil.LogError("[SandboxDungeonDetailHotfixer] fix" .. errorInfo)
    end
  end)
  
  xlua.private_accessible(CS.Torappu.UI.Sandbox.SandboxDungeonState)
  self:Fix_ex(CS.Torappu.UI.Sandbox.SandboxDungeonState, "_AddPreviewUpgradeState", function(self)
    local ok, errorInfo = xpcall(_AddPreviewUpgradeState_Fixed, debug.traceback, self)
    if not ok then
      eutil.LogError("[SandboxDungeonDetailHotfixer] fix" .. errorInfo)
    end
  end)
  
  xlua.private_accessible(CS.Torappu.UI.Sandbox.SandboxDungeonState)
  self:Fix_ex(CS.Torappu.UI.Sandbox.SandboxDungeonState, "_AddPreviewRewardState", function(self)
    local ok, errorInfo = xpcall(_AddPreviewRewardState_Fixed, debug.traceback, self)
    if not ok then
      eutil.LogError("[SandboxDungeonDetailHotfixer] fix" .. errorInfo)
    end
  end)
  
  xlua.private_accessible(SandboxStaminaPotViewModel);
  self:Fix_ex(SandboxStaminaPotViewModel, "RefreshPlayerData", function(self)
    local ok, errorInfo = xpcall(RefreshPlayerDataFixer, debug.traceback, self);
    if not ok then
      eutil.LogError("[Sandbox.SandboxStaminaPotViewModelHotfixer] fix" .. errorInfo);
    end
  end);
  
  xlua.private_accessible(CS.Torappu.UI.Sandbox.SandboxDungeonState)
  self:Fix_ex(CS.Torappu.UI.Sandbox.SandboxDungeonState, "OnBtnHudClicked", function(self)
    local ok, errorInfo = xpcall(OnBtnHudClicked_Fixed, debug.traceback, self)
    if not ok then
      eutil.LogError("[SandboxDungeonCrossDayHotfixer] fix" .. errorInfo)
    end
  end)
  
  xlua.private_accessible(CS.Torappu.UI.Sandbox.SandboxInitSupplementState)
  self:Fix_ex(CS.Torappu.UI.Sandbox.SandboxInitSupplementState, "_QuitAndSaveSquad", function(self)
    local ok, errorInfo = xpcall(_QuitAndSaveSquad_Fixed, debug.traceback, self)
    if not ok then
      eutil.LogError("[SandboxDungeonCrossDayHotfixer] fix" .. errorInfo)
    end
  end)
  
  xlua.private_accessible(CS.Torappu.Activity.Act1sandbox.Act1sandboxActivityGameLifeCyclePlugin)
  self:Fix_ex(CS.Torappu.Activity.Act1sandbox.Act1sandboxActivityGameLifeCyclePlugin, "OnViewModelRefresh", function(self, viewModel)
    local ok, errorInfo = xpcall(OnViewModelRefresh_Fixed, debug.traceback, self, viewModel)
    if not ok then
      eutil.LogError("[SandboxActivityGiveUpButtonHotfixer] fix" .. errorInfo)
    end
  end)
  
  xlua.private_accessible(CS.Torappu.UI.Sandbox.SandboxInventoryStateBean)
  self:Fix_ex(CS.Torappu.UI.Sandbox.SandboxInventoryStateBean, "InitItems", function(self, actId)
    local ok, errorInfo = xpcall(InitItems_Fixed, debug.traceback, self, actId)
    if not ok then
      eutil.LogError("[SandboxInventoryStateHotfixer] fix" .. errorInfo)
    end
  end)
end

function SandboxHotfixer:OnDispose()
end

return SandboxHotfixer