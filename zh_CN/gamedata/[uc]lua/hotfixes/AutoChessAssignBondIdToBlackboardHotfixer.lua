local Nodes = CS.Torappu.Battle.Action.Nodes
local AssignBondIdNode = Nodes.AutoChessAssignBondIdToBlackboard
local AutoChessBattleUtil = CS.Torappu.Battle.AutoChess.AutoChessBattleUtil
local eutil = CS.Torappu.Lua.Util
local characterType = typeof(CS.Torappu.Battle.Character)


local AutoChessAssignBondIdToBlackboardHotfixer = Class("AutoChessAssignBondIdToBlackboardHotfixer", HotfixBase)

local function _Execute(node, blackboard, sourceType, snapshot)
  local target = Nodes.GetActionTarget(snapshot, node._target)
  if target == nil or not characterType:IsInstanceOfType(target) then
    return false, snapshot
  end

  local bondIds = AutoChessBattleUtil.GetCharBondIds(target)
  if bondIds == nil or bondIds.Count == 0 then
    return false, snapshot
  end

  local ids = {}
  for i = 0, bondIds.Count - 1 do
    ids[i + 1] = bondIds[i]
  end
  local bondIdsStr = table.concat(ids, ",")
  blackboard:Assign(node._blackboardKey, bondIdsStr)
  return true, snapshot
end

function AutoChessAssignBondIdToBlackboardHotfixer:OnInit()
  xlua.private_accessible(AssignBondIdNode)
  self:Fix_ex(AssignBondIdNode, "Execute", function(node, blackboard, sourceType, snapshot)
    local ok, result, updatedSnapshot = xpcall(_Execute, debug.traceback, node, blackboard, sourceType, snapshot)
    if not ok then
      eutil.LogHotfixError("[AutoChessAssignBondIdToBlackboardHotfixer] Execute: " .. result)
      return node:Execute(blackboard, sourceType, snapshot)
    end
    return result, updatedSnapshot
  end)
end

function AutoChessAssignBondIdToBlackboardHotfixer:OnDispose()
end

return AutoChessAssignBondIdToBlackboardHotfixer
