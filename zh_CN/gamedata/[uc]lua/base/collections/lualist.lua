---@class LuaList 一个数组类容器,索引从1开始
LuaList = Class("LuaList");
LuaList.m_count = 0;

---@public 添加一个元素
---@param element any
function LuaList:Add(element)
  self.m_count = self.m_count + 1;
  self[self.m_count] = element;
end

---@public 将数组中所有元素依次添加到容器
---@param array any[]
function LuaList:AddList(array)
  for _,elem in ipairs(array) do
    self:Add(elem);
  end
end

---@public 获取索引处元素
---@param idx number @[1, Count]
function LuaList:At(idx)
  return self[idx];
end

---@public 设置元素
---@param idx number @位置[1, Count]
---@param elem any 元素
function LuaList:Set(idx, elem)
  if idx <= 0 or idx > self.m_count then
    return;
  end
  self[idx] = elem;
end

---@public 删除指定元素
---@param element any
function LuaList:Remove(element)
  self:RemoveIf(function(elem)
    return elem == element;
  end);
end

---@public 删除满足func为true的元素
---@param func fun(elem:any):bool
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

---@public 窗口中元素数量
---@return number
function LuaList:Count()
  return self.m_count;
end

---@public 查找元素索引
---@return number 元素所在位置，或者-1
function LuaList:IndexOf(element)
  for idx = 1, self:Count() do
    if self:At(idx) == element then
      return idx;
    end
  end
  return -1;
end

---@public 转成Primitive Array
---@return any[] 返回一个同内容的primitive array
function LuaList:ToArray()
  local ret = {};
  for idx = 1, self:Count() do
    table.insert(ret, self:At(idx));
  end
  return ret;
end