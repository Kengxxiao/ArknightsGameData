local eutil = CS.Torappu.Lua.Util
local BattleActionBase = require('Base/Battle/BattleActionBase')
local BattleAbilityBehaviourBase = require('Base/Battle/BattleAbilityBehaviourBase')

---@class BattleMgr model to manage battle related logic and instances
---@field me BattleMgr
---@field private m_actionNodeMap BattleActionBase instance map
---@field private m_abClsMap BattleAbilityBehaviourBase class map
---@field private m_abInsts BattleAbilityBehaviourBase instance list
BattleMgr = ModelMgr.DefineModel("BattleMgr")

---Create AbilityBehaviour instance from cls and uStub
---@param cls type class type of this ability behaviour
---@param uStub CS.LuaAbilityBehaviourStub stub from unity
local function _CreateAbilityBehaviour(cls, uStub)
  local inst = cls.new()
  inst:Initialize(uStub)
  return inst
end

---Constructor
function BattleMgr:ctor()
  self.m_actionNodeMap = {}
  self.m_abClsMap = {}
  self.m_abInsts = {}
end

function BattleMgr:OnInit()
  CS.Torappu.Lua.LuaBattleMgr.LuaOnlyBindCallback(self)
end

function BattleMgr:OnDispose()
  CS.Torappu.Lua.LuaBattleMgr.LuaOnlyBindCallback(nil)
  self:_ClearAll()
end

---Define a class based on BattleActionBase and register it into this BattleMgr
---@param className string
---@param alias string alias name of this Action. If it's nil, uses className instead
---@param baseType type of base class. If it's nil, uses BattleActionBase
function BattleMgr:DefineAction(className, alias, baseType)
  local cls = Class(className, baseType or BattleActionBase)
  alias = alias or className
  self.m_actionNodeMap[alias] = cls.new()
  return cls
end

---Define a class based on BattleAbilityBehaviourBase and register it into this BattleMgr
---@param className string
---@param alias string alias name of this Behaviour. If it's nil, uses className instead
---@param baseType type of base class. If it's nil, uses BattleAbilityBehaviourBase
function BattleMgr:DefineAbilityBehaviour(className, alias, baseType)
  local cls = Class(className, baseType or BattleAbilityBehaviourBase)
  alias = alias or className
  self.m_abClsMap[alias] = cls
  return cls
end

---Don't invoke in lua, exported to Unity
function BattleMgr:ExportResetAll()
  for _,inst in pairs(self.m_abInsts) do
    inst:Destroy()
  end
  self.m_abInsts = {}
end

---Don't invoke in lua, exported to Unity
---@param actionName string name of lua action node
---@param blackboard CS.Blackboard
---@param sourceType CS.ActionNode.SourceType
---@param snapshot CS.Context.Snapshot
function BattleMgr:ExportRunAction(actionName, blackboard, sourceType, snapshot)
  local nodeMap = self.m_actionNodeMap or {}
  local node = nodeMap[actionName]
  if node ~= nil then
    local ok, result = xpcall(node.Execute, debug.traceback, node, blackboard, sourceType, snapshot)
    if ok then
      return result, snapshot
    else
      eutil.LogError(result)
    end
  end
  --fallback
  return false, snapshot
end

---Don't invoke in lua, exported to Unity
---@param name string name of lua ability behaviour
---@param uStub CS.LuaAbilityBehaviourStub stub from unity
function BattleMgr:ExportCreateAbilityBehaviour(name, uStub)
  local behaviourMap = self.m_abClsMap or {}
  local cls = behaviourMap[name]
  if cls ~= nil then
    local ok, result = xpcall(_CreateAbilityBehaviour, debug.traceback, cls, uStub)
    if ok then
      table.insert(self.m_abInsts, result)
      return result
    else
      eutil.LogError(result)
    end
  end
  --fallback
  return nil
end

---@private
---Clear all internal resources
function BattleMgr:_ClearAll()
  self.m_actionNodeMap = {}
  self.m_abInsts = {}
end