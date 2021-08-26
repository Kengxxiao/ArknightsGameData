


DlgMgr = Class("DlgMgr");
DlgMgr.s_dialogCls = {};
DlgMgr.s_dlgCreateByCS = {};


function DlgMgr.Init(cfg)
  DlgMgr._cfg = cfg;
end



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






function DlgMgr.CreateDlg(dlgClass, parent)
  local layoutPath = DlgMgr._cfg.layoutDir .. dlgClass._layoutPath;
  local layout = parent:LoadLayout(layoutPath);
  assert(layout, "failed to load layout from:" .. layoutPath);

  local go = CS.UnityEngine.GameObject.Instantiate(layout.gameObject, parent:GetHookRoot());
  
  local dlg = dlgClass.new();
  dlg:Initialize(go, parent);
  return dlg;
end


function DlgMgr.ClearDlg(adlg)
  for idx, dlg in ipairs(DlgMgr.s_dlgCreateByCS) do
    if adlg == dlg then
      table.remove(DlgMgr.s_dlgCreateByCS, idx);
      return;
    end
  end
end

function DlgMgr.Clear()
  local temp = DlgMgr.s_dlgCreateByCS;
  DlgMgr.s_dlgCreateByCS = {};
  for _, dlg in ipairs(temp) do
    dlg:Dispose();
  end
end




function DlgMgr.DefineDialog(name, layoutPath, basetype)
  basetype = basetype or DlgBase;
  local dlgcls = Class(name, basetype);
  dlgcls._layoutPath = layoutPath;
  DlgMgr.s_dialogCls[name] = dlgcls;
  return dlgcls;
end


function DlgMgr.GetDialogCls(clsName)
  return DlgMgr.s_dialogCls[clsName]
end