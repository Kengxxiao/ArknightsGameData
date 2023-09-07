RandomUtil = {};


function RandomUtil.Range(min, max)
  return CS.Torappu.Lua.Util.Range(min, max);
end



function RandomUtil.RangeFloat(min, max)
  return CS.Torappu.Lua.Util.RangeFloat(min, max);
end
Readonly(RandomUtil);