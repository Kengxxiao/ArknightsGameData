local eutil = CS.Torappu.Lua.Util
local BattleActionBase = require('Base/Battle/BattleActionBase')
local BattleAbilityBehaviourBase = require('Base/Battle/BattleAbilityBehaviourBase')






BattleMgr = ModelMgr.DefineModel("BattleMgr")




local function _CreateAbilityBehaviour(cls, uStub)
  local inst = cls.new()
  inst:Initialize(uStub)
  return inst
end


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





function BattleMgr:DefineAction(className, alias, baseType)
  local cls = Class(className, baseType or BattleActionBase)
  alias = alias or className
  self.m_actionNodeMap[alias] = cls.new()
  return cls
end





function BattleMgr:DefineAbilityBehaviour(className, alias, baseType)
  local cls = Class(className, baseType or BattleAbilityBehaviourBase)
  alias = alias or className
  self.m_abClsMap[alias] = cls
  return cls
end


function BattleMgr:ExportResetAll()
  for _,inst in pairs(self.m_abInsts) do
    inst:Destroy()
  end
  self.m_abInsts = {}
end






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
  
  return false, snapshot
end




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
  
  return nil
end



function BattleMgr:_ClearAll()
  self.m_actionNodeMap = {}
  self.m_abInsts = {}
end