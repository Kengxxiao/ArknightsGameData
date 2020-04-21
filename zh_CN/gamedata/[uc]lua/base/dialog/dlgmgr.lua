---@class DlgMgr @static class for dialog manage
---@field private s_dialogCls table<string, DlgBase> @all dialog class defined
---@field s_dlgCreateByCS DlgBase[]
DlgMgr = Class("DlgMgr");
DlgMgr.s_dialogCls = {};
DlgMgr.s_dlgCreateByCS = {};

---@param cfg {layoutDir:string, canvasPath:string}
function DlgMgr.Init(cfg)
  DlgMgr._cfg = cfg;
end

---@param dlgClsName string
---@param parent ILuaDialog
function DlgMgr:CreateDlgByName(dlgClsName, parent)
  if not parent then
    return;
  end

  local dlgCls = DlgMgr.s_dialogCls[dlgClsName];
  if dlgCls then
    local dlg = DlgMgr.CreateDlg(dlgCls, parent);
    if dlg then
      table.insert(DlgMgr.s_dlgCreateByCS, dlg);
    end
    return dlg;
  else
    CS.Torappu.Lua.Util.LogError("Can't find dialog class:".. dlgClsName);
  end
  return nil;
end

---同步创建窗口
---@generic T:DlgBase
---@param dlgClass T
---@param parent ILuaDialog
---@return T @返回创建的窗口实例
function DlgMgr.CreateDlg(dlgClass, parent)
  local layoutPath = DlgMgr._cfg.layoutDir .. dlgClass._layoutPath;
  local layout = parent:LoadLayout(layoutPath);
  assert(layout, "failed to load layout from:" .. layoutPath);

  local go = CS.UnityEngine.GameObject.Instantiate(layout.gameObject, parent:GetHookRoot());
  ---@type DlgBase
  local dlg = dlgClass.new();
  dlg:Initialize(go, parent);
  return dlg;
end

---@param dlg DlgBase
function DlgMgr.ClearDlg(adlg)
  for idx, dlg in ipairs(DlgMgr.s_dlgCreateByCS) do
    if adlg == dlg then
      table.remove(DlgMgr.s_dlgCreateByCS, idx);
      return;
    end
  end
end

function DlgMgr.Clear()
  for _, dlg in ipairs(DlgMgr.s_dlgCreateByCS) do
    dlg:Dispose();
  end
end

---@generic T : DlgBase
---@param layoutPath string
---@return T
function DlgMgr.DefineDialog(name, layoutPath, basetype)
  basetype = basetype or DlgBase;
  local dlgcls = Class(name, basetype);
  dlgcls._layoutPath = layoutPath;
  DlgMgr.s_dialogCls[name] = dlgcls;
  return dlgcls;
end