

Event = Class("Event");

function Event.Create(callee, func, ...)
  return Event.new(func, callee, ...);
end

function Event.CreateStatic(func, ...)
  return Event.new(func, nil, ...);
end

function Event:ctor(func, callee, ...)
  self.m_func = func;
  self.m_self = callee;
  self.m_args = {...};
end

function Event:Call(...)
  local params = {...};
  if #params < 1 then
    params = self.m_args;
  elseif #self.m_args > 0 then
    for _, v in ipairs(self.m_args) do
      table.insert(params, v);
    end
  end

  
  if self.m_self then
    self.m_func(self.m_self, table.unpack(params));
  else
    self.m_func(table.unpack(params));
  end
end
