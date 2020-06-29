---@class DlgMgr @static class for dialog manage
---@field private s_dialogCls table<string, DlgBase> @all dialog class defined
---@field private s_dlgs table<string, DlgBase[]> @all dialog keep alive
---@field private s_contexts {ctx:LuaUIContext, dlgs:DlgBase[]}[] @stack of contexts
---@field private s_cleanTimer number
---@field private s_cleanup Event
DlgMgr = Class("DlgMgr");
DlgMgr.s_dialogCls = {};
DlgMgr.s_dlgs = {};
DlgMgr.s_contexts = {};

---@param cfg {layoutDir:string, canvasPath:string}
function DlgMgr.Init(cfg)
  DlgMgr._cfg = cfg;
end

function DlgMgr.OpenContext(context)
  if not context then
    return;
  end
  table.insert(DlgMgr.s_contexts, {ctx=context, dlgs={}});
  local dlgCls = DlgMgr.s_dialogCls[context.mainDialog];
  if dlgCls then
    DlgMgr.CreateDlg(dlgCls);
  else
    CS.Torappu.Lua.Util.LogError("Can't fine dialog class:".. context.mainDialog);
  end
end

function DlgMgr.CloseContext(context)
  if not context then
      return;
  end
  
  for idx = #DlgMgr.s_contexts, 1, -1 do
    local cur = DlgMgr.s_contexts[idx];
    for didx = #cur.dlgs, 1, -1 do
      local dlg = cur.dlgs[didx];
      dlg:Close();
    end
    table.remove(DlgMgr.s_contexts);
    if cur == context then
      break;
    end
  end
end

function DlgMgr.ActiveContext(context)
  if context.active then
    local len = #DlgMgr.s_contexts;
    if len <= 1 then
      return;
    end
    local last = DlgMgr.s_contexts[len];
    if last.ctx == context then
      return;
    end
    for idx = len-1, 1, -1 do
      if DlgMgr.s_contexts[idx].ctx == context then
        local v = table.remove(DlgMgr.s_contexts, idx);
        table.insert(DlgMgr.s_contexts, v);--move to end
        return;
      end
    end
  end
end

---同步创建窗口
---@generic T:DlgBase
---@param dlgClass T
---@return T @返回创建的窗口实例
function DlgMgr.CreateDlg(dlgClass)
  local context = DlgMgr.s_contexts[#DlgMgr.s_contexts];
  assert(context, "need a context" );

  local layoutPath = DlgMgr._cfg.layoutDir .. dlgClass._layoutPath;
  local layout = context.ctx:LoadLayout(layoutPath);
  assert(layout, "failed to load layout from:" .. layoutPath);

  local go = CS.UnityEngine.GameObject.Instantiate(layout.gameObject, context.ctx.root);
  ---@type DlgBase
  local dlg = dlgClass.new();
  dlg:Initialize(go, context.ctx);
  DlgMgr._AddDlg(dlg);
  table.insert(context.dlgs, dlg);
  return dlg;
end

---关闭窗口
---@generic T:DlgBase
---@param dlgClass T 窗口类型
function DlgMgr.CloseDlg(dlgClass)
  local dlg = DlgMgr.GetDlg(dlgClass);
  if dlg then
    dlg:Close();
  end
end

---关闭指定类型的所有窗口
---@generic T:DlgBase
---@param dlgClass T 窗口类型
function DlgMgr.CloseAll(dlgClass)
  
end

function DlgMgr.CloseAllDlg()
  for type, list in pairs(DlgMgr.s_dlgs) do
    for _, dlg in ipairs(list) do
      dlg:Close();
    end
  end
  DlgMgr.s_dlgs = {};
end

---获取窗口实例，若无返回nil
function DlgMgr.GetDlg(dlgClass)
  local list = DlgMgr.s_dlgs[dlgClass.__cname];
  if not list then
    return nil;
  end
  for _, v in ipairs(list) do
    if not v:IsClosed() then
      return v;
    end
  end
  return nil;
end

---获取窗口实例，若无则创建一个新的
function DlgMgr.FetchDlg(dlgClass)
  local dlg = DlgMgr.GetDlg(dlgClass);
  if dlg then
    return dlg;
  end
  return DlgMgr.CreateDlg(dlgClass);
end

---@private
---@param dlg DlgBase
function DlgMgr._AddDlg(dlg)
  local clsName = dlg.__cname;
  local list = DlgMgr.s_dlgs[clsName];
  if not list then
    list = {dlg};
    DlgMgr.s_dlgs[clsName] = list;
  else
    table.insert(list, dlg);
  end
end

---@private
---@param dlg DlgBase
function DlgMgr._PerformCleanup(dlg)
  if not DlgMgr.s_cleanTimer then
    if not DlgMgr.s_cleanup then
      DlgMgr.s_cleanup = Event.CreateStatic(DlgMgr._DoCleanup);
    end
    DlgMgr.s_cleanTimer = TimerModel.me:NextFrame(DlgMgr.s_cleanup);
  end

  for _, context in ipairs(DlgMgr.s_contexts) do
    if context.ctx.mainDialog == dlg.__cname then
      context.ctx:RequestClose();
    end
  end
end

---@private
function DlgMgr._DoCleanup()
  DlgMgr.s_cleanTimer = TimerModel.me:Destroy(DlgMgr.s_cleanTimer);
  for type, list in pairs(DlgMgr.s_dlgs) do
    local pos = 1;
    for idx = 1, #list do
      local dlg = list[idx];
      list[pos] = dlg;
      
      if not dlg:IsClosed() then
        pos = pos + 1;
      end
    end
    for idx = pos, #list do
      table.remove(list);
    end
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