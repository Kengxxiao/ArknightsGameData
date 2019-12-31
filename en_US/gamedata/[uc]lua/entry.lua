require "Base/BaseModule"
require "Feature/FeatureModule"
local eutil = CS.Torappu.Lua.Util

function CleanLuaPreVersions()
  -- clean V001 hotfix func by xlua.hotfix a nil func
  xlua.hotfix(CS.Torappu.UI.CharacterInfo.CharacterInfoPotentialLvlUpState, 'OnUpgradeConfirmClick',nil)
  xlua.hotfix(CS.Torappu.Activity.Act0D5.Act0D5Entry, 'OnEnter',nil)
  xlua.hotfix(CS.Torappu.UI.Shop.ShopRecommendStateBean, 'RefreshData',nil)
  xlua.hotfix(CS.Torappu.UI.Recruit.RecruitSlideState, '_EventOnGacha',nil)
  xlua.hotfix(CS.Torappu.Activity.Act1.ActivityFirstShopView, 'RenderData',nil)
  xlua.hotfix(CS.Torappu.Activity.Act1.ActivityFirstShopObject, 'InitData',nil)
  -- clean V002 hotfix funcs
  xlua.hotfix(CS.Torappu.Building.UI.Workshop.BuildingWorkshopHomeState, "OnEnter", nil)
  xlua.hotfix(CS.Torappu.Building.UI.Float.BuildingFloatVisitState, "_UpdateSocialPoint", nil)
  xlua.hotfix(CS.Torappu.DataConvertUtil, "_LoadStagePredefinedSquad", nil)
  xlua.hotfix(CS.Torappu.UI.Squad.SquadAssistCardView, "RenderCard", nil)
end

function Preprocess()
  local ok, error = xpcall(CleanLuaPreVersions, debug.traceback);
  if not ok then
    eutil.LogHotfixError(error);
  end
end

local luaEntry = CS.Torappu.Lua.LuaEntry;

luaEntry.Init = function ()
  print("Init");

  -- do hotfix
  Preprocess();
  local fixes = require ("Hotfixes/DefinedFix");
  HotfixProcesser.Do(fixes);

  -- feature
  local ok, error = xpcall(InitFeature, debug.traceback);
  if not ok then
    eutil.LogError(error);
  end

end

luaEntry.Dispose = function ()
  -- hotfix
  HotfixProcesser.Dispose();

  -- feature
  local ok, error = xpcall(DisposeFeature, debug.traceback);
  if not ok then
    eutil.LogError(error);
  end

  luaEntry.Init = nil;
  luaEntry.Dispose = nil;
  luaEntry.Update = nil;
  print("Disposed");
end

luaEntry.Update = function(deltaTime)
  TimerModel.me:Update(deltaTime);
end

function InitFeature()
  ModelMgr.Init();
  DlgMgr.Init(
    {
      layoutDir = "UI/",
      canvasPath = "UI/Main/LuaUIRoot",
    });

  local contextHandler = CS.Torappu.Lua.LuaUIContextHandler();
  contextHandler.Open = DlgMgr.OpenContext;
  contextHandler.Close = DlgMgr.CloseContext;
  contextHandler.ActiveChange = DlgMgr.ActiveContext;
  CS.Torappu.Lua.LuaUIContext.Init(contextHandler);

  TimerModel.me:BindSwitcher(Event.CreateStatic(function(open)
    luaEntry.driveUpdate = open;
  end));
end

function DisposeFeature()
  DlgMgr.CloseAllDlg();
  ModelMgr.Dispose();

  CS.Torappu.Lua.LuaUIContext.Dispose();
end