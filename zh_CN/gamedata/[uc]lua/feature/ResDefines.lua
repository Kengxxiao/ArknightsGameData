local luaUtils = CS.Torappu.Lua.Util


local strResMeta = {
  __index = function (table, key)
    return luaUtils.GetStringRes(key)
  end,
  __newIndex = function() 
    
  end
}
StringRes = {}
setmetatable(StringRes, strResMeta)