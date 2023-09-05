

UIRecycleAdapterBase = Class("UIRecycleAdapterBase")


function UIRecycleAdapterBase:Initialize(gobj, parent)
  self.m_layout = gobj:GetComponent("Torappu.UI.LuaRecycleLoopScrollAdpater");
  self.m_parent = parent;

  local this = self
  self.m_layout:TraverseCtrlDefines(function(name, ctrl)
    this["_"..name] = ctrl;
  end);
  self.m_layout:BindLayoutEventListener(self);
  self.m_objDict = {}
end

function UIRecycleAdapterBase:Dispose()
  self.m_layout:BindLayoutEventListener(nil);
  self.m_layout.OnScrollLayoutUpdated = nil;
  if self.m_widgets then
    self.m_widgets:Clear();
  end
end






function UIRecycleAdapterBase:CreateWidgetByPrefab(widgetCls, layout, parent)
  if not self.m_widgets then
    self.m_widgets = UIWidgetContainer.new(self);
  end
  return self.m_widgets:CreateWidgetByPrefab(widgetCls, layout, parent);
end

function UIRecycleAdapterBase:AddObj(uiWidget,obj)
  local pair = {}
  pair.obj = obj
  pair.widget = uiWidget
  table.insert(self.m_objDict,pair)
end

function UIRecycleAdapterBase:GetWidget(obj)

  for i,v in pairs (self.m_objDict)do
    
    if (v.obj == obj) then
      return v.widget
    end
  end
end

function UIRecycleAdapterBase:NotifyRebuild()
  self.m_layout:NotifyRebuild()
end


function UIRecycleAdapterBase:NotifyDataChanged()
  self.m_layout:NotifyDataChanged()
end

function UIRecycleAdapterBase:NotifyDataSourceChanged()
  self.m_layout:NotifyDataSourceChanged()
end


function UIRecycleAdapterBase:NotifyRebuildWithIndex(index)
  self.m_layout:NotifyRebuildWithIndexWithCountChange(index)
end


function UIRecycleAdapterBase:ListenScrollUpdatedEvent(evt)
  if evt then
    self.m_layout.OnScrollLayoutUpdated = function()
      evt:Call();
    end
  else
    self.m_layout.OnScrollLayoutUpdated = nil;
  end
end