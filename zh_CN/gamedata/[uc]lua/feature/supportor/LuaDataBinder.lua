local CSLuaDataBinder = CS.Torappu.DataBind.LuaDataBinder





LuaDataBinder = Class("LuaDataBinder")


function LuaDataBinder:Initialize(onValueChanged)
  self.m_csBinder = CSLuaDataBinder(self)
  self.m_onValueChanged = onValueChanged
end

function LuaDataBinder:Dispose()
  self.m_onValueChanged = nil
  if self.m_csBinder ~= nil then
    self.m_csBinder:Dispose()
    self.m_csBinder = nil
  end
end



function LuaDataBinder:OnValueChanged(value)
  if self.m_onValueChanged ~= nil then
    self.m_onValueChanged:Call(value)
  end
end


function LuaDataBinder:BindToProperty(property)
  if self.m_csBinder == nil then
    return
  end
  self.m_csBinder:BindToProperty(property)
end