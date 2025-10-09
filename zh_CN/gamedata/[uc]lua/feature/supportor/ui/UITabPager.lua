


























local BRIDGE_CLS = CS.Torappu.UI.LuaTabPagerBridge.CallFromLua







UITabPager = Class("UITabPager")





function UITabPager:Initialize(host, tabConfigs, options)
  self.m_host = host
  self.m_tabConfigs = tabConfigs or {}

  self.m_defaultTab = options and options.defaultTabId or ""
  self.m_cameras = options and options.cameras or {}
  
  
  local bridge = BRIDGE_CLS()
  self.m_bridge = bridge
  
  
  local tabPager = options and options.tabPager
  local dlgHost = options and options.dlgHost
  local cameras = options and options.cameras
  bridge:Init(self, tabPager, dlgHost, cameras)
end


function UITabPager:Dispose()
  local bridge = self.m_bridge
  if bridge ~= nil then
    bridge:Dispose()
  end
  self.m_bridge = nil
  self.m_host = nil
  self.m_tabConfigs = nil
end





function UITabPager:CSTabCount()
  return #self.m_tabConfigs
end



function UITabPager:CSDefaultTab()
  return self.m_defaultTab
end




function UITabPager:CSTabId(indexFrom1)
  local config = self.m_tabConfigs[indexFrom1]
  return config and config.tabId or ""
end




function UITabPager:CSTabResPath(indexFrom1)
  local config = self.m_tabConfigs[indexFrom1]
  return config and config.resPath or ""
end




function UITabPager:CSTabDialogType(indexFrom1)
  local config = self.m_tabConfigs[indexFrom1]
  return config and config.dialogType or nil
end




function UITabPager:CSTabInput(indexFrom1)
  local config = self.m_tabConfigs[indexFrom1]
  local inputFunc = config and config.inputFunc
  if not inputFunc then
    return nil
  end
  return self.m_host and inputFunc(self.m_host)
end





function UITabPager:CSCallback(indexFrom1, output)
  local config = self.m_tabConfigs[indexFrom1]
  local callback = config and config.onTabCallback
  if not callback then
    return nil
  end
  return self.m_host and callback(self.m_host, output)
end





function UITabPager:SelectTab(tabId)
  if not self.m_bridge then
    return
  end
  
  self.m_bridge:SelectTab(tabId)
end



function UITabPager:GetSelectTabId()
  if not self.m_bridge then
    return nil
  end
  
  return self.m_bridge:GetSelectTabId()
end



function UITabPager:IsStable()
  if not self.m_bridge then
    return true
  end
  
  return self.m_bridge:IsStable()
end


function UITabPager:ClearSelection()
  if not self.m_bridge then
    return
  end
  
  self.m_bridge:ClearSelection()
end


function UITabPager:ReloadData()
  if not self.m_bridge then
    return
  end
  
  self.m_bridge:ReloadData()
end



function UITabPager:GetUITabPagerTabs()
  return self.m_tabConfigs
end




function UITabPager:GetUITabPagerTab(indexFrom1)
  return self.m_tabConfigs[indexFrom1]
end