




ReleaseCollection = Class(ReleaseCollection);
ReleaseCollection.AUTO_GC_COUNT = 10;



function ReleaseCollection.Build(deadChecker, killFunc)
  local collection = ReleaseCollection.new();
  collection.m_deadChecker = deadChecker;
  collection.m_killFunc = killFunc;
  collection.m_itemList = {};
  return collection;
end



function ReleaseCollection:Collect(item)
  self:_TryGC(false);
  table.insert(self.m_itemList, item);
end



function ReleaseCollection:Release(item)
  self.m_killFunc(item);
  self:_TryGC(true);
end


function ReleaseCollection:ReleaseAll()
  local cnt = #self.m_itemList;
  for idx, item in ipairs(self.m_itemList) do
    self.m_killFunc(item);
    self.m_itemList[idx] = nil;
  end
  return cnt;
end

function ReleaseCollection:_TryGC(force)
  if force or #self.m_itemList > self.AUTO_GC_COUNT then
    RemoveIf(self.m_itemList, self.m_deadChecker);
  end
end