local util = require 'xlua.util'
local initRequestCls = CS.Torappu.UI.UISenderRequestHandler(CS.Torappu.Activity.ActMultiV3.ActMultiV3StartMatchResponse)
local queryRequestCls = CS.Torappu.UI.UISenderRequestHandler(CS.Torappu.Activity.ActMultiV3.ActMultiV3QueryMatchResponse)

local requestResult = nil


local LoopRequestSenderHotfixer = Class("LoopRequestSenderHotfixer", HotfixBase)

local function Fix_InitSendRequest(self)
  requestResult = nil
  return self:SendRequest()
end
local function Fix_QuerySendRequest(self)
  requestResult = self:SendRequest()
  return requestResult
end

local function Fix_CancelIfNeed(currTask)
  local routine = CS.Torappu.UI.LoopRequestSender._CancelIfNeed(currTask)
  return util.cs_generator(function()
    while requestResult ~= nil and requestResult.isRequesting
    do
      coroutine.yield(nil)
    end

    if requestResult == nil or not requestResult.isComplete then
      coroutine.yield(routine)
    end
  end)
end

local function Fix_CreateMatchQueryRequest(self, isCancel)
  local isCreateSucc, request, requestParam = self:_CreateMatchQueryRequest(isCancel)
  requestParam.concurrentType = CS.Torappu.UI.UISender.ConcurrentType.ENQUEUE
  return isCreateSucc, request, requestParam
end

local function Fix_CreateInitRequest(self)
  local isCreateSucc, request, requestParam = self:_CreateInitRequest()
  requestParam.concurrentType = CS.Torappu.UI.UISender.ConcurrentType.ENQUEUE
  return isCreateSucc, request, requestParam
end

local function Fix_LoadData(self, input)
  self:LoadData(input)

  local targetData = self:FindTargetData(input.actData, input.mapData, 0)
  if targetData ~= nil then
    self.desc = targetData.battleDesc
  end
end
function LoopRequestSenderHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Activity.ActMultiV3.ActMultiV3QuickMatchState)
  xlua.private_accessible(CS.Torappu.UI.LoopRequestSender)

  xlua.private_accessible(CS.Torappu.Activity.ActMultiV3.BattleFinish.BattleFinishNormalMapModel)
  self:Fix_ex(CS.Torappu.Activity.ActMultiV3.BattleFinish.BattleFinishNormalMapModel, "LoadData", function(self, input)
    local ok, errorInfo = xpcall(Fix_LoadData, debug.traceback, self, input)
    if not ok then
      LogError("Fix LoadData error" .. errorInfo)
    end
  end)

  xlua.private_accessible(CS.Torappu.Activity.ActMultiV3.BattleFinish.BattleFinishDefenceMapModel)
  self:Fix_ex(CS.Torappu.Activity.ActMultiV3.BattleFinish.BattleFinishDefenceMapModel, "LoadData", function(self, input)
    local ok, errorInfo = xpcall(Fix_LoadData, debug.traceback, self, input)
    if not ok then
      LogError("Fix LoadData error" .. errorInfo)
    end
  end)

  self:Fix_ex(CS.Torappu.Activity.ActMultiV3.ActMultiV3QuickMatchState, "_CreateInitRequest", function(self)
    local ok, ret1, ret2, ret3 = xpcall(Fix_CreateInitRequest, debug.traceback, self)
    if not ok then
      LogError("fix _CreateInitRequest error" .. ret1)
      return self:_CreateInitRequest()
    end
    return ret1, ret2, ret3
  end)

  self:Fix_ex(CS.Torappu.Activity.ActMultiV3.ActMultiV3QuickMatchState, "_CreateMatchQueryRequest", function(self, isCancel)
    local ok, ret1, ret2, ret3 = xpcall(Fix_CreateMatchQueryRequest, debug.traceback, self, isCancel)
    if not ok then
      LogError("fix _CreateMatchQueryRequest error" .. ret1)
      return self:_CreateMatchQueryRequest(isCancel)
    end
    return ret1, ret2, ret3
  end)

  self:Fix_ex(CS.Torappu.UI.LoopRequestSender, "_CancelIfNeed", function(currTask)
    local ok, ret = xpcall(Fix_CancelIfNeed, debug.traceback, currTask)
    if not ok then
      LogError("fix LoopRequestSender _CancelIfNeed error" .. ret)
      return CS.Torappu.UI.LoopRequestSender._CancelIfNeed(currTask)
    end
    return ret
  end)

  self:Fix_ex(initRequestCls, "SendRequest", function(self)
    local ok, ret = xpcall(Fix_InitSendRequest, debug.traceback, self)
    if not ok then
      LogError("fix InitRequestHandler SendRequest error" .. ret)
      return self:SendRequest()
    end
    return ret
  end)

  self:Fix_ex(queryRequestCls, "SendRequest", function(self)
    local ok, ret = xpcall(Fix_QuerySendRequest, debug.traceback, self)
    if not ok then
      LogError("fix QueryRequestHandler SendRequest error" .. ret)
      return self:SendRequest()
    end
    return ret
  end)
end

return LoopRequestSenderHotfixer