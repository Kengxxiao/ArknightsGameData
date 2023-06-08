
string.split = function(s, p)
  local rt = { }
  string.gsub(s, '[^' .. p .. ']+', function(w) table.insert(rt, w) end)
  return rt
end

string.formatWithThousand = function(num)
  return CS.Torappu.FormatUtil.FormatNumWithThousand(num);
end




string.isNullOrEmpty = function(str)
  return str == nil or str == ""
end