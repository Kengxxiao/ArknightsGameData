-- local BaseHotfixer = require ("Module/Core/BaseHotfixer")
-- local eutil = CS.Torappu.Lua.Util
local xutil = require('xlua.util')
---@class BattleControllerHotfixer:HotfixBase
local BattleControllerHotfixer = Class("BattleControllerHotfixer", HotfixBase)

local isHotFixed = false

local function SetTargetOptions(self)
  local targetOptions = self._targetOptions
  targetOptions:SetSourceTypeAndConvertTargetType(CS.Torappu.Battle.SideType.ALLY);
  self._targetOptions = targetOptions
end

local function Execute(self, blackboard, sourceType, snapshot)
  local ok = xpcall(SetTargetOptions, debug.traceback, self)
  return self:Execute(blackboard, sourceType, snapshot)
end

local function TouchAOEHeal()
  if isHotFixed == false then
    -- We do this just for touch AOEHeal's instance, to fix this bug for xlua
    --https://github.com/Tencent/xLua/issues/622
    local ret, buff = CS.Torappu.Battle.BuffDB.instance:TryGetTemplate("breeze_range")
    local action = buff.eventToActions[CS.Torappu.Battle.Buff.Event.ON_BUFF_START]
    local temp = action.Value[0]

    xutil.hotfix_ex(CS.Torappu.Battle.Action.Nodes.AOEHeal, "Execute", function(self, blackboard, sourceType, snapshot)
      return Execute(self, blackboard, sourceType, snapshot)
    end)
    isHotFixed = true
  end
end

local function StartGame(self)
  local ok = xpcall(TouchAOEHeal, debug.traceback)
  self:StartGame()
end

function BattleControllerHotfixer:OnInit()
  self:Fix_ex(CS.Torappu.Battle.BattleController, "StartGame", function(self)
    return StartGame(self)
  end)
end

function BattleControllerHotfixer:OnDispose()
  xlua.hotfix(CS.Torappu.Battle.Action.Nodes.AOEHeal, "Execute", nil)
  isHotFixed = false
end

return BattleControllerHotfixer