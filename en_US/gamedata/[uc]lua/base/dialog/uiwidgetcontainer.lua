---@class UIWidgetContainer
---@field m_parent UIBase
---@field m_widgets UIWidget[]
UIWidgetContainer = Class("UIWidgetContainer")

function UIWidgetContainer:ctor(parent)
  self.m_parent = parent;
  self.m_widgets = {}
end

function UIWidgetContainer:Clear()
  -- destroy all widgets
  local temp = self.m_widgets;
  self.m_widgets = {}
  for _, widget in ipairs(temp) do
    widget:Dispose();
  end
end


---由prefab创建一个窗口组件
---@generic T:Widget
---@param widgetCls T
---@param layout LuaLayout prefab
---@param parent Transfrom
function UIWidgetContainer:CreateWidgetByPrefab(widgetCls, layout, parent)
  if not self:_CheckWdigetClass(widgetCls) then
    return nil;
  end

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
function UIWidgetContainer:CreateWidgetByGO(widgetCls, layout)
  if not self:_CheckWdigetClass(widgetCls) then
    return nil;
  end

  ---@type Widget
  local widget = widgetCls.new();
  widget:Initialize(layout.gameObject, self.m_parent);
  table.insert(self.m_widgets, widget);
  return widget;
end

function UIWidgetContainer:_CheckWdigetClass(widgetCls)
  if not widgetCls then
    LogError("Param widgetCls can't be nil!")
    return false;
  end
  if not IsSubclassOf(widgetCls, UIWidget) then
    LogError(widgetCls.__cname .. " not the subclass of UIWidget")
    return false;
  end
  return true;
end