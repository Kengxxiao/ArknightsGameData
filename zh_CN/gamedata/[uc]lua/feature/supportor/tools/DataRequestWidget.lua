










local luaUtils = CS.Torappu.Lua.Util







DataRequestWidget = Class("DataRequestWidget")



function DataRequestWidget:Initialize(config)
  
  self.m_serviceMappings = {}
  self.m_pendingRequests = {}
  self.m_requestStates = {}
  self.m_cache = {}
  self.m_cacheTimestamps = {}
  
  
  if config and config.serviceMappings then
    self:_SetServiceMappings(config.serviceMappings)
  end
end



function DataRequestWidget:_SetServiceMappings(serviceMappings)
  for id, serviceConfig in pairs(serviceMappings) do
      
      if serviceConfig.cacheExpireTime == nil then
        serviceConfig.cacheExpireTime = -1
      end
      self.m_serviceMappings[id] = serviceConfig
  end
end




function DataRequestWidget:_IsCacheValid(id)
  local serviceConfig = self.m_serviceMappings[id]
  if not serviceConfig or serviceConfig.cacheExpireTime <= 0 then
    return false
  end
  
  if not self.m_cache[id] then
    return false
  end
  
  local timestamp = self.m_cacheTimestamps[id]
  if not timestamp then
    return false
  end
  
  local currentTime = luaUtils.GetCurrentTs()
  return (currentTime - timestamp) < serviceConfig.cacheExpireTime
end




function DataRequestWidget:_GetCachedData(id)
  if self:_IsCacheValid(id) then
    return self.m_cache[id]
  end
  return nil
end




function DataRequestWidget:_SetCachedData(id, data)
  local serviceConfig = self.m_serviceMappings[id]
  if serviceConfig and serviceConfig.cacheExpireTime > 0 then
    self.m_cache[id] = data
    self.m_cacheTimestamps[id] = luaUtils.GetCurrentTs()
  end
end



function DataRequestWidget:ClearCache(id)
  if id then
    self.m_cache[id] = nil
    self.m_cacheTimestamps[id] = nil
  else
    self.m_cache = {}
    self.m_cacheTimestamps = {}
  end
end





function DataRequestWidget:RequestData(id, callback, forceRefresh)
  if not id or not callback then
    return
  end
  
  
  if not forceRefresh then
    local cachedData = self:_GetCachedData(id)
    if cachedData then
      callback:Call(cachedData)
      return
    end
  end
  
  
  if self.m_requestStates[id] then
    
    local pendingRequest = self.m_pendingRequests[id]
    if not pendingRequest then
      pendingRequest = {}
      self.m_pendingRequests[id] = pendingRequest
    end
    table.insert(pendingRequest, callback)
    return
  end
  
  
  local serviceConfig = self.m_serviceMappings[id]
  if not serviceConfig or not serviceConfig.serviceFunc then
    
    callback:Call(nil)
    return
  end
  
  
  self.m_requestStates[id] = true
  
  
  local internalCallback = Event.Create(self, self._OnResponse, id, callback)
  
  
  serviceConfig.serviceFunc:Call(internalCallback)
end





function DataRequestWidget:_OnResponse(response, id, callback)
  
  self.m_requestStates[id] = false
  
  
  if response then
    self:_SetCachedData(id, response)
  end

  if callback ~= nil then
    callback:Call(response)
  end
  
  
  if self.m_pendingRequests[id] then
    for _, callback in ipairs(self.m_pendingRequests[id]) do
      callback:Call(response)
    end
    self.m_pendingRequests[id] = nil
  end
end




function DataRequestWidget:IsRequestPending(id)
  return self.m_requestStates[id] == true
end


function DataRequestWidget:CancelAllRequests()
  self.m_requestStates = {}
  self.m_pendingRequests = {}
end


function DataRequestWidget:CleanExpiredCache()
  local idsToRemove = {}
  
  for id, _ in pairs(self.m_cache) do
    if not self:_IsCacheValid(id) then
      table.insert(idsToRemove, id)
    end
  end
  
  for _, id in ipairs(idsToRemove) do
    self:ClearCache(id)
  end
end


function DataRequestWidget:Dispose()
  self:CancelAllRequests()
  self:ClearCache(nil)
  
  
  self.m_serviceMappings = nil
  self.m_pendingRequests = nil
  self.m_requestStates = nil
  self.m_cache = nil
  self.m_cacheTimestamps = nil
end 