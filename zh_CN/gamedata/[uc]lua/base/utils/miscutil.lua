--[[
  value is the string to check whether number
  base is the [integer base] Normal Decimal
]]
function CheckNumber(value, base)
  return tonumber(value, base) or 0
end


--[[
  check if value can be a int
]]
function Checkint(value)
  return math.round(checknumber(value))
end

--[[
  value will be false only if value = nil or false
]]
function Checkbool(value)
  return(value ~= nil and value ~= false)
end

--[[
  return value if is a table
]]
function Checkta2ble(value)
  if type(value) ~= "table" then value = { } end
  return value
end

--[[
  use to print complex table
]]
function Print_r(root)
  if root == nil then return end
  local cache = { [root] = "." }
  local function _dump(t, space, name)
    local temp = { }
    if type(t) == "table" then
      for k, v in pairs(t) do
        local key = tostring(k)
        if cache[v] then
          table.insert(temp, "+" .. key .. " {" .. cache[v] .. "}")
        elseif type(v) == "table" then
          local new_key = name .. "." .. key
          cache[v] = new_key
          table.insert(temp, "+" .. key .. _dump(v, space ..(next(t, k) and "|" or " ") .. string.rep(" ", #key), new_key))
        else
          table.insert(temp, "+" .. key .. " [" .. tostring(v) .. "]")
        end
      end
    end
    return table.concat(temp, "\n" .. space)
  end
  print(_dump(root, "", ""))
end

--[[
  e.q. : FindChildByPath(transform, "container/item/text")
]]
function FindChildByPath(transform, path)
  -- body
  local childList = string.split(path,"/")
  local result = transform
  for  _,v in pairs(childList) do
    result = CS.Torappu.Lua.Util.FindChild(result,v)
    if (result == nil) then
      return nil
    end
  end
  return result
end

--- convert C# List<T> to lua array
---@param list List<T>
function ToLuaArray(list)
  local array = {};
  for _, v in pairs(list) do
    table.insert(array, v);
  end
  return array;
end