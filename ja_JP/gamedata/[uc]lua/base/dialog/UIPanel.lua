

UIPanel = Class("UIPanel", UIWidget);


function UIPanel:OnInitialize()
  self.m_widgets = UIWidgetContainer.new(self);
  self:OnInit();
end


function UIPanel:OnDispose()
  self:OnClose();
  self.m_widgets:Clear();
end






function UIPanel:CreateWidgetByPrefab(widgetCls, layout, parent)
  return self.m_widgets:CreateWidgetByPrefab(widgetCls, layout, parent);
end





function UIPanel:CreateWidgetByGO(widgetCls, layout)
  return self.m_widgets:CreateWidgetByGO(widgetCls, layout);
end


function UIPanel:OnInit()
end


function UIPanel:OnClose()
end

