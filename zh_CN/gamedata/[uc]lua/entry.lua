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

  
  Preprocess();
  local fixes = require ("Hotfixes/DefinedFix");
  HotfixProcesser.Do(fixes);

  
  local ok, error = xpcall(InitFeature, debug.traceback);
  if not ok then
    eutil.LogError("[InitFeature]" .. error);
  end

  
  local ok, error = xpcall(InitBattle, debug.traceback);
  if not ok then
    eutil.LogError("[InitBattle]" .. error);
  end
end

EntryTable.Dispose = function ()
  
  HotfixProcesser.Dispose();

  
  local ok, error = xpcall(DisposeFeature, debug.traceback);
  if not ok then
    eutil.LogError("[DisposeFeature]" .. error);
  end

  CS.Torappu.Lua.LuaEntry.Init = nil;
  CS.Torappu.Lua.LuaEntry.Update = nil;
  CS.Torappu.Lua.LuaEntry.Dispose = nil;
  print("Disposed");
end

EntryTable.Update = function(unscaledDeltaTime, deltaTime)
  TimerModel.me:Update(unscaledDeltaTime, deltaTime);
end

CS.Torappu.Lua.LuaEntry.Init = EntryTable.Init;
CS.Torappu.Lua.LuaEntry.Update = EntryTable.Update;
CS.Torappu.Lua.LuaEntry.Dispose = EntryTable.Dispose;