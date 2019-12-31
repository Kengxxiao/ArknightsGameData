--[[
  base class
  e.q.: local classExample = class("classExample")
      local classExample2 = class("classExample2",classExample)
]]
function Class(classname, super)
  local superType = type(super)
  local cls

  if superType ~= "function" and superType ~= "table" then
    superType = nil
    super = nil
  end

  if superType == "function" or(super and super.__ctype == 1) then
    -- inherited from native C++ Object
    cls = { }

    if superType == "table" then
      -- copy fields from super
      for k, v in pairs(super) do cls[k] = v end
      cls.__create = super.__create
      cls.super = super
    else
      cls.__create = super
      cls.ctor = function() end
    end

    cls.__cname = classname
    cls.__ctype = 1

    function cls.new(...)
      local instance = cls.__create(...)
      -- copy fields from class to native object
      for k, v in pairs(cls) do instance[k] = v end
      instance.class = cls
      instance:ctor(...)
      return instance
    end

  else
    -- inherited from Lua Object
    if super then
      cls = { }
      setmetatable(cls, { __index = super })
      cls.super = super
    else
      cls = { ctor = function() end }
    end

    cls.__cname = classname
    cls.__ctype = 2
    -- lua
    cls.__index = cls

    function cls.new(...)
      local instance = setmetatable( { }, cls)
      instance.class = cls
      instance:ctor(...)
      return instance
    end
  end
  return cls
end

  
--[[
  e.q.  ： clean all meta info in lua
]]
function CleanClass(cs, classPath)
  if cs == nil then return end
  if type(cs) ~= "table" then
    cs = nil
    return
  end
  setmetatable(cs, nil)
  for k,v in pairs(cs) do
    cs[k] = nil
  end
  if classPath ~= nil then
    package.loaded[classPath] = nil
  end
end


---set the table as readonly
---@param t {} @any table
---@param deep boolean @if recursion set
function Readonly(t, deep)
  if deep then
    for k, v in pairs(t) do
      if type(t) == 'table' then
        t[k] = Readonly(v, deep);
      end
    end
  end

  local meta = 
  {
    __index = t,
    __newindex = function()
      assert(false, 'table is readonly\n');
    end
  }
  local ret = {};
  setmetatable(ret, meta);
  return ret;
end