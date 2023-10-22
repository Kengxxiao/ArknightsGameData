




local V043Hotfixer = Class("V043Hotfixer", HotfixBase)

local function _FixOnStoryCommitted(self, isOk, output)
  local evt = CS.Torappu.AVG.AVGController.Event.ON_END_SUCCEED
  local cachedStory = self.m_story
  local evtKey = evt:GetHashCode()
  local eventsMap = self.eventPool.eventsMap
  local keyExists = false
  local evtValue = nil
  if eventsMap ~= nil then
    keyExists, evtValue = eventsMap:TryGetValue(evtKey)
    eventsMap:Remove(evtKey)
  end

  self:OnStoryCommitted(isOk, output)

  if keyExists then
    local emptyValue = nil
    keyExists, emptyValue = eventsMap:TryGetValue(evtKey)
    if keyExists then
      emptyValue:Reset()
      CS.Torappu.EventPoolInternal.EventPoolBase.s_unusedSet:Add(emptyValue)
      eventsMap:Remove(evtKey)
    end
    eventsMap:Add(evtKey, evtValue)
  end
  if isOk and evtValue ~= nil then
    evtValue:Emit(cachedStory)
  end
end

function V043Hotfixer:OnInit()
  
  xlua.private_accessible(CS.Torappu.EventPoolInternal.EventPoolBase)
  xlua.private_accessible(CS.Torappu.AVG.AVGController)
  self:Fix_ex(CS.Torappu.AVG.AVGController, "OnStoryCommitted", function(self, isOk, output)
    local ok, ret = xpcall(_FixOnStoryCommitted, debug.traceback, self, isOk, output)
    if not ok then
      LogError("[OnStoryCommitted] fix " .. ret)
    end
  end)

  
end

function V043Hotfixer:OnDispose()
end

return V043Hotfixer