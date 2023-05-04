


UIWidgetContainer = Class("UIWidgetContainer")

function UIWidgetContainer:ctor(parent)
  self.m_parent = parent;
  self.m_widgets = {}
end

function UIWidgetContainer:Clear()
  
  local temp = self.m_widgets;
  self.m_widgets = {}
  for _, widget in ipairs(temp) do
    widget:Dispose();
  end
end







function UIWidgetContainer:CreateWidgetByPrefab(widgetCls, layout, parent)
  if not self:_CheckWdigetClass(widgetCls) then
    return nil;
  end

  local go = CS.UnityEngine.GameObject.Instantiate(layout.gameObject, parent);
  
  local widget = widgetCls.new();
  widget:Initialize(go, self.m_parent);
  table.insert(self.m_widgets, widget);
  return widget;
end





function UIWidgetContainer:CreateWidgetByGO(widgetCls, layout)
  if not self:_CheckWdigetClass(widgetCls) then
    return nil;
  end

  
  local widget = widgetCls.new();
  widget:Initialize(layout.gameObject, self.m_parent);
  table.insert(self.m_widgets, widget);
  return widget;
end

function UIWidgetContainer:_CheckWdigetClass(widgetCls)
  if not widgetCls then
    LogError("Param widgetCls can't be nil!"..debug.traceback())
    return false;
  end
  if not IsSubclassOf(widgetCls, UIWidget) then
    LogError(widgetCls.__cname .. " not the subclass of UIWidget"..debug.traceback())
    return false;
  end
  return true;
end

function UIWidgetContainer:EnumerateAllWidgets(func)
  for _, widget in ipairs(self.m_widgets) do
    func(widget);
  end
end