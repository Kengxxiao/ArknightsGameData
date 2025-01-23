
local CheckTheLeftSameDeployedTokenHotFixer = Class("CheckTheLeftSameDeployedTokenHotFixer", HotfixBase)

local function _CheckTheLeftSameDeployedTokenExecute(self, blackboard, sourceType, snapshot)
  local snapshotBuff = snapshot.buff
  local target = nil
  local host = nil
  if snapshotBuff ~= nil then
    target = snapshotBuff.owner
  end
  if target == nil or target.tokenOrHostUid == 0 or not target.isToken then
    return false, snapshot
  end
  if snapshotBuff ~= nil then
    host = snapshotBuff.source
  end
  if host == nil or host.isToken then
    return false, snapshot
  end
  
  local foundCnt = 0
  local minCnt = blackboard:GetIntOrDefault("cnt", self._minCnt)
  local units = CS.Torappu.Battle.BattleController.instance.unitManager.allUnits
  
  for i = 0, units.count - 1 do 
    local token = units[i]
    if token ~= nil and (token:GetType() == typeof(CS.Torappu.Battle.Character) or token:GetType() == typeof(CS.Torappu.Battle.Token)) then
      if token.data ~= nil and token.alive and host.tokenOrHostUid == token.data.uniqueId and token.instanceUid ~= target.instanceUid then
        foundCnt = foundCnt + 1
      end
    end
  end
  return foundCnt >= minCnt, snapshot
end

function CheckTheLeftSameDeployedTokenHotFixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.Action.Nodes.CheckTheLeftSameDeployedToken)
  self:Fix_ex(CS.Torappu.Battle.Action.Nodes.CheckTheLeftSameDeployedToken, "Execute", function(self, blackboard, sourceType, snapshot)
    local ok, ret, snapshot = xpcall(_CheckTheLeftSameDeployedTokenExecute, debug.traceback, self, blackboard, sourceType, snapshot)
    if not ok then
      LogError("[Hotfix] failed to fix CheckTheLeftSameDeployedToken : " .. ret)
    end
    return ret, snapshot
  end)
end

return CheckTheLeftSameDeployedTokenHotFixer