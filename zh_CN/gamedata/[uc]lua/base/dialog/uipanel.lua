---@class UIPanel:UIWidget
---@field m_widgets UIWidgetContainer
UIPanel = Class("UIPanel", UIWidget);

---@private
function UIPanel:OnInitialize()
  self.m_widgets = UIWidgetContainer.new();
  self:OnInit();
end

---@private
function UIPanel:OnDispose()
  self:OnClose();
  self.m_widgets:Clear();
end

---由prefab创建一个窗口组件
---@generic T:Widget
---@param widgetCls T
---@param layout LuaLayout prefab
---@param parent Transfrom
function UIPanel:CreateWidgetByPrefab(widgetCls, layout, parent)
  return self.m_widgets:CreateWidgetByPrefab(widgetCls, layout, parent);
end

---由场景上对象创建一个窗口组件
---@generic T:Widget
---@param widgetCls T
---@param layout LuaLayout 场景上对象
function UIPanel:CreateWidgetByGO(widgetCls, layout)
  return self.m_widgets:CreateWidgetByGO(widgetCls, layout);
end

---override
function UIPanel:OnInit()
end

---override
function UIPanel:OnClose()
end

