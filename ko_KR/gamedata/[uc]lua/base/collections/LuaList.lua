
LuaList = Class("LuaList");
LuaList.m_count = 0;



function LuaList:Add(element)
  self.m_count = self.m_count + 1;
  self[self.m_count] = element;
end



function LuaList:AddList(array)
  for _,elem in ipairs(array) do
    self:Add(elem);
  end
end



function LuaList:At(idx)
  return self[idx];
end




function LuaList:Set(idx, elem)
  if idx <= 0 or idx > self.m_count then
    return;
  end
  self[idx] = elem;
end



function LuaList:Remove(element)
  self:RemoveIf(function(elem)
    return elem == element;
  end);
end



function LuaList:RemoveIf(func)
  local validPos = 0;
  for idx = 1, self:Count() do
    if not func(self:At(idx)) then
      validPos = validPos + 1;
      self[validPos] = self[idx];
    end
  end
  for idx = validPos+1, self:Count() do
    self[idx] = nil;
  end
  self.m_count = validPos;
end



function LuaList:Count()
  return self.m_count;
end



function LuaList:IndexOf(element)
  for idx = 1, self:Count() do
    if self:At(idx) == element then
      return idx;
    end
  end
  return -1;
end



function LuaList:ToArray()
  local ret = {};
  for idx = 1, self:Count() do
    table.insert(ret, self:At(idx));
  end
  return ret;
end