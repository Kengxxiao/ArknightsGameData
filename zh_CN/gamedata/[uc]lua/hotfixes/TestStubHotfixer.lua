





local TestStubHotfixer = Class("TestStubHotfixer", HotfixBase)

function TestStubHotfixer:OnInit()
  if HOTFIX_ENABLE then
    self:Fix_ex(CS.Torappu.HotfixTestStub, "GenerateDevInfo", function(devVersion, dataVer)
      local info = GlobalConfig.CUR_FUNC_VER .. "_HOTFIX_ENABLE"
      return info
    end)
  end
end

return TestStubHotfixer