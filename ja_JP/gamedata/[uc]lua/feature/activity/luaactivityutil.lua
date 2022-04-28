
LuaActivityUtil = ModelMgr.DefineModel("LuaActivityUtil")

local eutils = CS.Torappu.Lua.Util

function LuaActivityUtil:OnInit()
  CS.Torappu.UI.LuaActivityUtil.BindInterface(self)
end

function LuaActivityUtil:OnDispose()
  CS.Torappu.UI.LuaActivityUtil.BindInterface(nil)
end

local HOME_WEIGHT_DAILY_PRAY = 500
local HOME_WEIGHT_GRID_GACHA = 510
local HOME_WEIGHT_GRID_GACHA_V2 = 520



local function _FindValidPrayOnlyActs(validActs, uncompleteActs)
  local actList = CS.Torappu.UI.ActivityUtil.FindValidPrayOnlyActs()
  if actList == nil then
    return
  end
  for i = 0, actList.Count - 1 do 
    local actId = actList[i]
    local validAct = CS.Torappu.SortableString(actId, HOME_WEIGHT_DAILY_PRAY)
    validActs:Add(validAct)
    if CS.Torappu.UI.ActivityUtil.CheckIfPrayOnlyActUncomplete(actId) then
      uncompleteActs:Add(validAct)
    end
  end
end



local function _FindValidGridGachaActs(validActs, uncompleteActs)
  local actList = CS.Torappu.UI.ActivityUtil.FindValidGridGachaActs()
  if actList == nil then
    return
  end
  for i = 0, actList.Count - 1 do
    local actId = actList[i]
    local validAct = CS.Torappu.SortableString(actId, HOME_WEIGHT_GRID_GACHA)
    validActs:Add(validAct)
    if CS.Torappu.UI.ActivityUtil.CheckIfGridGachaActUncomplete(actId) then
      uncompleteActs:Add(validAct)
    end
  end
end



function LuaActivityUtil:_FindValidGridGachaV2Acts(validActs, uncompleteActs)
  local actList = {};

  local actList = CS.Torappu.UI.ActivityUtil.FindValidActs(CS.Torappu.ActivityType.GRID_GACHA_V2);
  if actList == nil then
    return;
  end
  for i = 0, actList.Count - 1 do
    local actId = actList[i];
    local validAct = CS.Torappu.SortableString(actId, HOME_WEIGHT_GRID_GACHA_V2);
    validActs:Add(validAct);
    if self:CheckIfActivityUncomplete(CS.Torappu.ActivityType.GRID_GACHA_V2, actId) then
      uncompleteActs:Add(validAct);
    end
  end
end




function LuaActivityUtil:FindValidHomeActs(validActs, uncompleteActs)
  
  _FindValidPrayOnlyActs(validActs, uncompleteActs)
  _FindValidGridGachaActs(validActs, uncompleteActs)
  self:_FindValidGridGachaV2Acts(validActs, uncompleteActs);
end


local DEFINE_CLS_FUNCS = {
  COLLECTION = function(clsName, config)
    DlgMgr.DefineDialog(clsName, config.dlgPath, CollectionMainDlg)
  end,
  LOGIN_ONLY = function(clsName, config)
    DlgMgr.DefineDialog(clsName, config.dlgPath, LoginOnlyDlg)
  end,
  PRAY_ONLY = function(clsName, config)
    DlgMgr.DefineDialog(clsName, config.dlgPath, PrayOnlyMainDlg)
  end,
  TYPE_ACT17D7 = function(clsName, config)
    DlgMgr.DefineDialog(clsName, config.dlgPath, Act17D7MainDlg)
  end,
  GRID_GACHA = function(clsName, config)
    DlgMgr.DefineDialog(clsName, config.dlgPath, GridGachaMainDlg)
  end,
  GRID_GACHA_V2 = function(clsName, config)
    DlgMgr.DefineDialog(clsName, config.dlgPath, GridGachaV2MainDlg)
  end,
}






local function _DefineActDialogCls(clsName, config)
  local overrideBaseCls = config.overrideBaseCls
  if overrideBaseCls ~= nil and overrideBaseCls ~= "" then
    
    local baseCls = DlgMgr.GetDialogCls(overrideBaseCls)
    if baseCls == nil then
      eutils.LogError("Couldn't find lua cls " .. overrideBaseCls)
      return false
    end
    DlgMgr.DefineDialog(clsName, config.dlgPath, baseCls)
    return true
  end
  
  local createFunc = DEFINE_CLS_FUNCS[config.actType]
  if createFunc == nil then
    return false
  end
  createFunc(clsName, config)
  return true
end



function LuaActivityUtil:EnsureActivityDialogClass(config)
  local targetClsName = eutils.Format("{0}Dlg", string.upper(config.actId))
  local existCls = DlgMgr.GetDialogCls(targetClsName)
  if existCls ~= nil then
    return targetClsName
  end
  
  if _DefineActDialogCls(targetClsName, config) then
    return targetClsName
  end

  return nil
end




function LuaActivityUtil:CheckIfActivityUncomplete(type, actId)
  if type == nil or actId == nil then
    return false;
  end
  
  if type == CS.Torappu.ActivityType.GRID_GACHA_V2 then
    return self:_CheckIfGridGachaV2Uncomplete(actId);
  else
    return false;
  end
end

function LuaActivityUtil:_CheckIfGridGachaV2Uncomplete(actId)
  local actList = CS.Torappu.PlayerData.instance.data.activity.gridGachaV2ActivityList;
  if actList == nil then
    return false;
  end
  local success, actData = actList:TryGetValue(actId);
  if not success then
    return false;
  end
  local data = eutils.ConvertJObjectToLuaTable(actData);
  return data.today.done == 0;
end