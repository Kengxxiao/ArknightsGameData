require "GlobalConfig";
EntryTable = {}

if CS.Torappu.VersionCompat.CUR_FUNC_VER ~= GlobalConfig.CUR_FUNC_VER then
  print("The version of lua not compatible with current c#!", 
    CS.Torappu.VersionCompat.CUR_FUNC_VER, GlobalConfig.CUR_FUNC_VER);

  EntryTable.Init = function()
  end
  EntryTable.Dispose = function()
    CS.Torappu.Lua.LuaEntry.Init = nil;
    CS.Torappu.Lua.LuaEntry.Dispose = nil;
    print("Disposed");
  end
  CS.Torappu.Lua.LuaEntry.Init = EntryTable.Init;
  CS.Torappu.Lua.LuaEntry.Dispose = EntryTable.Dispose;
  return;
end

require "Base/BaseModule"
require "Feature/FeatureModule"
local eutil = CS.Torappu.Lua.Util

local function CleanLuaPreVersions()
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
end

local function Preprocess()
  local ok, error = xpcall(CleanLuaPreVersions, debug.traceback);
  if not ok then
    eutil.LogHotfixError(error);
  end
end

local function InitFeature()
  CS.Torappu.Lua.LuaUIContext.SetDialogMgr(DlgMgr);
  
  ModelMgr.Init();
  DlgMgr.Init(
    {
      layoutDir = "UI/",
      canvasPath = "UI/Main/LuaUIRoot",
    });

  TimerModel.me:BindSwitcher(Event.CreateStatic(function(open)
    CS.Torappu.Lua.LuaEntry.driveUpdate = open;
  end));
end

---This method must be invoked after DlgMgr.Init()
---since BattleModule depends on BattleMgr which is a Model.
local function InitBattle()
  if BattleMgr.me == nil then
    error('InitBattle() must be invoked after DlgMgr.Init()')
  end
  require "Battle/BattleModule"
end

local function DisposeFeature()
  DlgMgr.Clear();
  ModelMgr.Dispose();

  CS.Torappu.Lua.LuaUIContext.SetDialogMgr(nil);
end

EntryTable.Init = function ()
  print("Init");

  -- do hotfix
  Preprocess();
  local fixes = require ("Hotfixes/DefinedFix");
  HotfixProcesser.Do(fixes);

  -- feature
  local ok, error = xpcall(InitFeature, debug.traceback);
  if not ok then
    eutil.LogError("[InitFeature]" .. error);
  end

  -- battle
  local ok, error = xpcall(InitBattle, debug.traceback);
  if not ok then
    eutil.LogError("[InitBattle]" .. error);
  end
end

EntryTable.Dispose = function ()
  -- hotfix
  HotfixProcesser.Dispose();

  -- feature
  local ok, error = xpcall(DisposeFeature, debug.traceback);
  if not ok then
    eutil.LogError("[DisposeFeature]" .. error);
  end

  CS.Torappu.Lua.LuaEntry.Init = nil;
  CS.Torappu.Lua.LuaEntry.Update = nil;
  CS.Torappu.Lua.LuaEntry.Dispose = nil;
  print("Disposed");
end

EntryTable.Update = function(deltaTime)
  TimerModel.me:Update(deltaTime);
end

CS.Torappu.Lua.LuaEntry.Init = EntryTable.Init;
CS.Torappu.Lua.LuaEntry.Update = EntryTable.Update;
CS.Torappu.Lua.LuaEntry.Dispose = EntryTable.Dispose;