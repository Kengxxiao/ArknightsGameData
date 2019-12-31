
local LuaUIUtil = CS.Torappu.Lua.LuaUIUtil;

---@class DlgBase :UIBase
---@field _layoutPath string
---@field m_id number
---@field m_widgets Widget[]
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
function DlgBase:OnDestroy()
  -- destroy all widgets
  for _, widget in ipairs(self.m_widgets) do
    widget:Destroy();
  end
  self:OnClose();
  DlgMgr._PerformCleanup(self);
end

function DlgBase:Close()
  self:Destroy();
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

---由prefab创建一个窗口组件
---@generic T:Widget
---@param widgetCls T
---@param layout LuaLayout prefab
---@param parent Transfrom
function DlgBase:CreateWidgetByPrefab(widgetCls, layout, parent)
  local go = CS.UnityEngine.GameObject.Instantiate(layout.gameObject, parent);
  ---@type Widget
  local widget = widgetCls.new();
  widget:Initialize(go, self.m_context);
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
  widget:Initialize(layout.gameObject, self.m_context);
  table.insert(self.m_widgets, widget);
  return widget;
end


---@protected
function DlgBase:OnInit()
end
---@protected
function DlgBase:OnClose()
end