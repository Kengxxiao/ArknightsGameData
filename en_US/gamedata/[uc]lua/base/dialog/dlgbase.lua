
local LuaUIUtil = CS.Torappu.Lua.LuaUIUtil;

---@class DlgBase :UIBase
---@field _layoutPath string
---@field m_id number
---@field m_widgets Widget[]
---@field m_childDlgs DlgBase[]
DlgBase = Class("DlgBase", UIBase);
DlgBase.s_ids = 1;

---@protected
function DlgBase:OnInitialize()
  self.m_id = DlgBase.s_ids;
  DlgBase.s_ids = DlgBase.s_ids + 1;
  local closeBtn = self.m_layout.sysCloseButton;
  if closeBtn then
    self:AddButtonClickListener(closeBtn, self._HandleSysClose);
  end
  self.m_widgets = {};

  self:OnInit();
end

---@protected
function DlgBase:OnDispose()
  -- close all child
  if self.m_childDlgs then
    for _, child in ipairs(self.m_childDlgs) do
      child:ClosedByParent();
    end
    self.m_childDlgs = nil;
  end
  -- destroy all widgets
  for _, widget in ipairs(self.m_widgets) do
    widget:Dispose();
  end
  self:OnClose();

  DlgMgr.ClearDlg(self);
end

function DlgBase:Close()
  self.m_parent:RequestClose(self);
end

function DlgBase:_HandleSysClose()
  self:Close();
end

function DlgBase:IsClosed()
  return self:IsDestroy();
end

function DlgBase:Id()
  return self.m_id;
end


function DlgBase:CreateChildDlg(dlgCls)
  local child = DlgMgr.CreateDlg(dlgCls, self);
  if not self.m_childDlgs then
    self.m_childDlgs = {};
  end
  table.insert(self.m_childDlgs, child);
  return child;
end

function DlgBase:GetChildDlg(dlgCls)
  if not self.m_childDlgs then
    return nil;
  end
  for _, child in ipairs(self.m_childDlgs) do
    if child.class == dlgCls then
      return child;
    end
  end
  return nil;
end

function DlgBase:FetchChildDlg(dlgCls)
  local child = self:GetChildDlg(dlgCls);
  if not child then
    child = self:CreateChildDlg(dlgCls);
  end
  return child;
end

---由prefab创建一个窗口组件
---@generic T:Widget
---@param widgetCls T
---@param layout LuaLayout prefab
---@param parent Transfrom
function DlgBase:CreateWidgetByPrefab(widgetCls, layout, parent)
  local go = CS.UnityEngine.GameObject.Instantiate(layout.gameObject, parent);
  ---@type Widget
  local widget = widgetCls.new();
  widget:Initialize(go, self.m_parent);
  table.insert(self.m_widgets, widget);
  return widget;
end

---由场景上对象创建一个窗口组件
---@generic T:Widget
---@param widgetCls T
---@param layout LuaLayout 场景上对象
function DlgBase:CreateWidgetByGO(widgetCls, layout)
  ---@type Widget
  local widget = widgetCls.new();
  widget:Initialize(layout.gameObject, self.m_parent);
  table.insert(self.m_widgets, widget);
  return widget;
end


---@protected
function DlgBase:OnInit()
end
---@protected
function DlgBase:OnClose()
end


---ILuaDialog接口实现---

---供父窗口调用，请勿用
function DlgBase:ClosedByParent()
  self:Dispose();
end

---@return Transform
function DlgBase:GetHookRoot()
  return self.m_parent:GetHookRoot();
end

---@param key string
---@return string
function DlgBase:GetData(key)
  return self.m_parent:GetData(key);
end

---@param child ILuaDialog
function DlgBase:RequestClose(child)
  if self.m_childDlgs ~= nil then
    for idx, achild in ipairs(self.m_childDlgs) do
      if achild == child then
        table.remove(self.m_childDlgs, idx);
        child:ClosedByParent();
        return;
      end
    end
  end
  CS.Torappu.Lua.Util.LogError(string.format("[%s]not the child of this dialog[%s]", child, self) );
end

---@param path string
---@return GameObject
function DlgBase:LoadPrefab(path)
  return self.m_parent:LoadPrefab(path);
end

---@param path string
---@return LuaLayout
function DlgBase:LoadLayout( path)
  return self.m_parent:LoadLayout(path);
end