

UIPatchBase = Class("UIPatchBase", HotfixBase)

function UIPatchBase:_DoPatch(rootGO)
  local suc = 0;
  for _, mod in ipairs(self.m_list) do
    if ApplyUIHotPatch(rootGO, mod.path, mod.com, mod.property, mod.value) then
      suc = suc + 1;
    end
  end
  print(string.format("Patch applied: %d/%d", suc, #self.m_list));
end