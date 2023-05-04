local rapidjson = require("rapidjson")




UISender = ModelMgr.DefineModel("UISender")

local ConcurrentType = CS.Torappu.UI.UISender.ConcurrentType









local function _GenDefaultOptions()
  local options = CS.Torappu.Lua.LuaSender.Options()
  options.useInvisibleMask = true
  options.concurrentType = ConcurrentType.ENQUEUE
  return options
end

function UISender:OnInit()
  CS.Torappu.Lua.LuaSender.LuaOnlyBindCallback(self)
  self.m_callbacks = {}
end

function UISender:OnDispose()
  CS.Torappu.Lua.LuaSender.LuaOnlyBindCallback(nil)
  self.m_callbacks = nil
end










function UISender:SendGet(url, param, config)
  local useMask = false
  if config ~= nil and config.useMask ~= nil then
    useMask = config.useMask
  end

  local requestId = CS.Torappu.Lua.LuaSender.SendGet(url, param, useMask)

  local callback = {}
  if config ~= nil then
    callback.onProceed = config.onProceed
    callback.onBlock = config.onBlock
    callback.onFinal = config.onFinal
  end
  if self.m_callbacks == nil then
    self.m_callbacks = {}
  end
  self.m_callbacks[requestId] = callback
end












function UISender:SendRequest(serviceCode, body, config)
  local options = _GenDefaultOptions()
  
  options.serviceCode = serviceCode
  options.body = rapidjson.encode(body)
  if config ~= nil then
    if config.showLoadingMask then
      options.useInvisibleMask = false
    end
    if config.abortIfBusy then
      options.concurrentType = ConcurrentType.ABORT
    end
  end
  if config ~= nil then
    options.headers = config.headers
    options.overrideUrl = config.url
  end

  local requestId = CS.Torappu.Lua.LuaSender.SendRequest(options)
  
  local callback = {}
  if config ~= nil then
    callback.onProceed = config.onProceed
    callback.onBlock = config.onBlock
    callback.onFinal = config.onFinal
  end
  if self.m_callbacks == nil then
    self.m_callbacks = {}
  end
  self.m_callbacks[requestId] = callback
end




function UISender:ExportOnProceed(requestId, response)
  local callback = self:_GetCallback(requestId)
  if callback == nil or callback.onProceed == nil then 
    return
  end
  callback.onProceed:Call(response)
end









function UISender:ExportOnBlock(requestId, error)
  local callback = self:_GetCallback(requestId)
  if callback == nil or callback.onBlock == nil then 
    return false 
  end
  local ret = callback.onBlock:Call(error)
  if ret == nil then 
    ret = false
  end
  return ret
end


function UISender:ExportOnFinal(requestId)
  local callback = self:_GetCallback(requestId)
  if callback == nil or callback.onFinal == nil then 
    return
  end
  callback.onFinal:Call();
end

function UISender:_GetCallback(requestId)
  if self.m_callbacks == nil then
    return nil
  end
  return self.m_callbacks[requestId]
end

function UISender:ExportRemoveRequest(requestId)
  if self.m_callbacks ~= nil then
    self.m_callbacks[requestId] = nil 
  end
end


function UISender:ExportResetNetwork()
  self.m_callbacks = {}
end