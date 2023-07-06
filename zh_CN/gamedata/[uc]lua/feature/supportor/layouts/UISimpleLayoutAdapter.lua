








UISimpleLayoutAdapter = Class("UISimpleLayoutAdapter")








function UISimpleLayoutAdapter:Initialize(host, layout, createWidgetFunc, getCountFunc, updateViewFunc, overridePrefab)
  self.m_host = host
  self.m_createWidgetFunc = createWidgetFunc
  self.m_getCountFunc = getCountFunc
  self.m_updateViewFunc = updateViewFunc
  self.m_overridePrefab = overridePrefab;
  self.m_viewList = {}
  self:_BindToLayout(layout);
end

function UISimpleLayoutAdapter:Dispose()
  if self.m_bridge then
    self.m_bridge:DisposeFromLua()
    self.m_bridge = nil
  end
end


function UISimpleLayoutAdapter:_BindToLayout(simpleLayout)
  if not simpleLayout then
    return
  end
  local curAdapter = simpleLayout.adapter
  if curAdapter ~= nil and curAdapter == self.m_bridge then
    return
  end
  self.m_bridge = CS.Torappu.UI.LuaSimpleLayoutAdapter.BindAdapterToLayout(self, simpleLayout)
end

function UISimpleLayoutAdapter:GetCount()
  if not self.m_getCountFunc then
    return 0
  end
  return self.m_getCountFunc(self.m_host)
end



function UISimpleLayoutAdapter:UpdateView(index, gameObj)
  local view = self:_FindViewByObj(gameObj)
  if not view and self.m_createWidgetFunc then
    view = self.m_createWidgetFunc(self.m_host, gameObj)
    table.insert(self.m_viewList, {
      obj = gameObj,
      view = view
    })
  end
  if not view then
    return
  end
  if self.m_updateViewFunc then
    self.m_updateViewFunc(self.m_host, index, view)
  end
end


function UISimpleLayoutAdapter:GetOverridePrefab()
  return self.m_overridePrefab;
end

function UISimpleLayoutAdapter:NotifyDataSetChanged()
  if not self.m_bridge then
    return
  end
  self.m_bridge:NotifyDataSetChanged()
end


function UISimpleLayoutAdapter:FindViewByIndex(index)
  if not self.m_bridge then
    return nil
  end
  
  local obj = self.m_bridge:GetView(index)
  return self:_FindViewByObj(obj)
end


function UISimpleLayoutAdapter:_FindViewByObj(gameObj)
  for i, item in ipairs(self.m_viewList) do
    if item.obj == gameObj then
      return item.view
    end
  end
  return nil
end
