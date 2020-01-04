local rapidjson = require("rapidjson")

---@class UISender
---@field me UISender
---@field private m_callbacks table<string,table<string,Event>> e.g. m_callback[requestId].onProceed
UISender = ModelMgr.DefineModel("UISender")

---Generate a default option to send request
---@return userdata The request options for C# interface
---   @param serviceCode string
---   @param headers Dictionary<string,string>
---   @param useInvisibleMask bool
---   @param body string
---   @param overrideUrl string
local function _GenDefaultOptions()
  local options = CS.Torappu.Lua.LuaSender.Options()
  options.useInvisibleMask = false
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

---Send an HTTP GET service
---@param url string
---@param param string HTTP GET param which would be concated to url
---@param config table Optional configs as below
---   @param onProceed Event Succeed callback: function(response) end
---       @param resposne table<string,string> Use response.text to read GET content
---   @param onBlock Event Fail callback: function(error:userdata) return overrideDefault:boolean end
---   @param onFinal Event Final callback: function() end
---   @param useMask boolean whether to block UI during GET. By default this is false
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

---Send game service. This is different from normal POST requests.
---@param serviceCode string
---@param body table request content
---@param config table Optional configs as below
---   @param onProceed Event Succeed callback: function(response:table) end
---   @param onBlock Event Fail callback: function(error:userdata) return overrideDefault:boolean end
---   @param onFinal Event Final callback: function() end
---   @param hideMask boolean If true, an invisible loading mask would be applied instead of a visible one
---   @param headers table<string, string> Additional header items. Note that some headers couldn't be overrided by this
---   @param url string Url to override default game server host and port
function UISender:SendRequest(serviceCode, body, config)
  local options = _GenDefaultOptions()
  ---Set configs
  options.serviceCode = serviceCode
  options.body = rapidjson.encode(body)
  if options.hideMask ~= nil then
    options.useInvisibleMask = options.hideMask
  end
  if config ~= nil then
    options.headers = config.headers
    options.overrideUrl = config.url
  end

  local requestId = CS.Torappu.Lua.LuaSender.SendRequest(options)
  ---Generate callbacks
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

---Don't invoke in lua
---@param requestId string
---@param response table the response content without player data delta
function UISender:ExportOnProceed(requestId, response)
  local callback = self:_GetCallback(requestId)
  if callback == nil or callback.onProceed == nil then 
    return
  end
  callback.onProceed:Call(response)
end

---Don't invoke in lua
---@param requestId string
---@param error userdata 
---   @param code number http response status code
---   @param error string
---   @param message string
---   @param isTimeout boolean
---   @param isCanceled boolean
function UISender:ExportOnBlock(requestId, error)
  local callback = self:_GetCallback(requestId)
  if callback == nil or callback.onBlock == nil then 
    return false --- By default don't override
  end
  local ret = callback.onBlock:Call(error)
  if ret == nil then 
    ret = false
  end
  return ret
end

---Don't invoke in lua
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

---When this is invoked all pending requests should be aborted
function UISender:ExportResetNetwork()
  self.m_callbacks = {}
end