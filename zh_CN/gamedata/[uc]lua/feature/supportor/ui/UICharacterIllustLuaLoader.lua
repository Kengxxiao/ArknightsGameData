local eutil = CS.Torappu.Lua.Util




local UICharacterIllustLuaLoader = Class("UICharacterIllustLuaLoader")



function UICharacterIllustLuaLoader:Initialize(root)
  self.m_assets = eutil.CreateLuaAssets(root:GetInstanceID());
end

function UICharacterIllustLuaLoader:Dispose()
  eutil.UnloadLuaAssets(self.m_assets);
end




function UICharacterIllustLuaLoader:ControllerOnlyLoadChrIllust(skin, content)
  return eutil.LuaControllerOnlyLoadChrIllust(skin, self.m_assets, content);
end

return UICharacterIllustLuaLoader;