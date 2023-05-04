local eutil = CS.Torappu.Lua.Util



HotfixProcesser = Class("HotfixProcesser")
HotfixProcesser.m_fixes = {}



function HotfixProcesser.Do(fixes)
  for _, v in pairs(fixes) do
    local cls = require(v)
    if cls ~= nil then
      local mo = cls.new();
      table.insert(HotfixProcesser.m_fixes, mo);
      local ok, error = xpcall(mo.Init, debug.traceback, mo);
      if not ok then
        eutil.LogHotfixError(mo.__cname ..":".. error);
      end
    end
  end
end

function HotfixProcesser.Dispose()
  for _,v in pairs(HotfixProcesser.m_fixes) do
    local ok, error = xpcall(v.Dispose, debug.traceback, v);
    if not ok then
      eutil.LogHotfixError(v.__cname ..":".. error);
    end
  end
  HotfixProcesser.m_fixes = {}
end