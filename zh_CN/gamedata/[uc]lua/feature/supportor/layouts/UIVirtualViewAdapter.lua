local eutil = CS.Torappu.Lua.Util











UIVirtualViewAdapter = Class("UIVirtualViewAdapter")







function UIVirtualViewAdapter:Initialize(host, layout, viewDefineTable, updateViewFunc)
  self.m_host = host
  
  
  local viewTypes = {}
  for viewType,config in pairs(viewDefineTable) do
    local copyConfig = {}
    for k,v in pairs(config) do
      copyConfig[k] = v
    end
    viewTypes[viewType] = copyConfig
  end
  self.m_viewTypes = viewTypes
  self.m_updateViewFunc = updateViewFunc

  self.m_dataList = {}
  self.m_widgetMap = {}
  self.m_widgetContainer = UIWidgetContainer.new(self)
  
  
  local bridge = CS.Torappu.UI.LuaVirtualViewAdapter.CSharpInterface.BindAdapterToLayout(self, layout)
  self.m_bridge = bridge
  for viewType,define in pairs(viewTypes) do
    bridge:AddViewTypeDefine(viewType, define.prefab)    
  end
end

function UIVirtualViewAdapter:Dispose()
  local bridge = self.m_bridge
  if bridge ~= nil then
    bridge:DisposeFromLua()
  end
  self.m_bridge = nil
  self.m_host = nil
  local widgets = self.m_widgetContainer
  if widgets ~= nil then
    widgets:Clear()
  end
end






function UIVirtualViewAdapter:ExportBindView(viewType, index, layout, widgetId)
  local data = self.m_dataList[index]
  if data == nil then
    return
  end
  
  local widget = self.m_widgetMap[widgetId]
  if widget == nil then
    local viewTypeConfig = self.m_viewTypes[viewType]
    if viewTypeConfig == nil then
      eutil.LogError("[UIVirtualViewAdapter] ViewType is not configed : "..viewType)
      return
    end
    widget = self.m_widgetContainer:CreateWidgetByGO(viewTypeConfig.cls, layout)
    self.m_widgetMap[widgetId] = widget
  end
  
  local updateViewFunc = self.m_updateViewFunc
  local host = self.m_host
  if updateViewFunc ~= nil and host ~= nil then
    updateViewFunc(host, viewType, widget, data)
  end
end



function UIVirtualViewAdapter:_CheckIfConfigValid(config)
  local viewType = config.viewType
  if viewType == nil then
    eutil.LogError("[VirtualViewAdapter] A valid viewType must be provied.")
    return false
  end
  local viewConfig = self.m_viewTypes[viewType]
  if viewConfig == nil or viewConfig.prefab == nil then
    eutil.LogError("[VirtualViewAdapter] viewType ["..viewType.."] is not found in view definitions.")
    return false
  end
  return true
end



function UIVirtualViewAdapter:InsertView(index, config)
  local bridge = self.m_bridge
  if bridge == nil then
    return
  end
  if not self:_CheckIfConfigValid(config) then
    return
  end
  table.insert(self.m_dataList, index, config.data)
  bridge:InsertView(index, config.viewType, config.size)
end


function UIVirtualViewAdapter:AddView(config)
  local bridge = self.m_bridge
  if bridge == nil then
    return
  end
  if not self:_CheckIfConfigValid(config) then
    return
  end
  table.insert(self.m_dataList, config.data)
  bridge:AddView(config.viewType, config.size)
end


function UIVirtualViewAdapter:AddViews(configList)
    local bridge = self.m_bridge
  if bridge == nil then
    return
  end
  local dataList = self.m_dataList
  local configIter = ipairs(configList)
  for _,config in configIter do
    if not self:_CheckIfConfigValid(config) then
      return
    end
  end
  for _,config in configIter do
    table.insert(dataList, config.data)
    bridge:AddView(config.viewType, config.size)
  end
end




function UIVirtualViewAdapter:RemoveView(index, triggerRefreshViews)
  local bridge = self.m_bridge
  if bridge == nil then
    return
  end
  local viewCount = #self.m_dataList
  if index < 1 or index > viewCount then
    return
  end
  table.remove(self.m_dataList, index)
  bridge:RemoveView(index)
end

function UIVirtualViewAdapter:NotifyRebuildAll()
  local bridge = self.m_bridge
  if bridge == nil then
    return
  end
  bridge:RebuildAllViews()
end

function UIVirtualViewAdapter:RemoveAllViews()
  local bridge = self.m_bridge
  if bridge == nil then
    return
  end
  bridge:RemoveAllViews()
end