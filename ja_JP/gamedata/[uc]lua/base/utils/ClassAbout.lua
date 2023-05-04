
function Class(classname, super)
  local superType = type(super)
  local cls

  if superType ~= "function" and superType ~= "table" then
    superType = nil
    super = nil
  end

  if superType == "function" or(super and super.__ctype == 1) then
    
    cls = { }

    if superType == "table" then
      
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
      
      for k, v in pairs(cls) do instance[k] = v end
      instance.class = cls
      instance:ctor(...)
      return instance
    end

  else
    
    if super then
      cls = { }
      setmetatable(cls, { __index = super })
      cls.super = super
    else
      cls = { ctor = function() end }
    end

    cls.__cname = classname
    cls.__ctype = 2
    
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

function IsSubclassOf(sub, super)
  local basecls = sub.super;
  while basecls do
    if basecls == super then
      return true;
    else
      basecls = basecls.super;
    end
  end
  return false;
end
  

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

function CreatEnumTable(tbl, index) 
    local enumtbl = {} 
    local enumindex = index or 0 
    for k, v in ipairs(tbl) do 
        enumtbl[v] = enumindex + k
    end 
    return enumtbl 
end 