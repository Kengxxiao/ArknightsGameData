
string.split = function(s, p)
  local rt = { }
  string.gsub(s, '[^' .. p .. ']+', function(w) table.insert(rt, w) end)
  return rt
end