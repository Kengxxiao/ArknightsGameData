


UILayoutDimensionAdapter = Class("UILayoutDimensionAdapter")



function UILayoutDimensionAdapter:Initialize(listener)
  self.m_bridge = CS.Torappu.UI.UILayoutDimensionListener.CSharpInterface.BindToListener(self, listener)
  self.m_doOnceOnPostLayout = nil
end


function UILayoutDimensionAdapter:Dispose()
  local bridge = self.m_bridge
  self.m_bridge = nil
  if bridge ~= nil then
    bridge:DisposeFromLua()
  end
end


function UILayoutDimensionAdapter:ExportOnPostLayout()
  local eventList= self.m_doOnceOnPostLayout
  if eventList == nil then
    return
  end
  self.m_doOnceOnPostLayout = nil
  for _,event in ipairs(eventList) do
    event:Call()
  end
end


function UILayoutDimensionAdapter:DoOnceOnPostLayout(event)
  if self.m_doOnceOnPostLayout == nil then
    self.m_doOnceOnPostLayout = {}
  end
  for _,existing in ipairs(self.m_doOnceOnPostLayout) do
    if existing == event then
      return
    end
  end
  table.insert(self.m_doOnceOnPostLayout, event)
end