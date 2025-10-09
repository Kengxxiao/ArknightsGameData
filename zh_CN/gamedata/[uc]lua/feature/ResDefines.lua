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

local i18nTextMeta = {
  __index = function (_, key)
    return luaUtils.GetI18NText(key)
  end,
  __newindex = function ()
    
  end
}
I18NTextRes = {}
setmetatable(I18NTextRes, i18nTextMeta)